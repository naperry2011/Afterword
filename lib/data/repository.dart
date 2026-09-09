import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';
import 'ids.dart';

/// A session joined to its book, as the shelf sees it.
class ShelfEntry {
  const ShelfEntry({required this.session, required this.book});
  final ReadingSession session;
  final Book book;
}

/// Everything the Book screen needs.
class SessionDetail {
  const SessionDetail({
    required this.session,
    required this.book,
    required this.reflections,
  });
  final ReadingSession session;
  final Book book;
  final List<Reflection> reflections;

  Reflection? byKey(String key) {
    for (final r in reflections) {
      if (r.promptKey == key) return r;
    }
    return null;
  }
}

/// The export envelope. Bump [exportSchema] with the DB schema.
const int exportSchema = 1;

class Repository {
  Repository(this.db);
  final AppDatabase db;

  // ---- Shelf -------------------------------------------------------------

  /// Reading first, then finished, then abandoned. Newest first within each.
  Stream<List<ShelfEntry>> watchShelf() {
    final q = db.select(db.readingSessions).join([
      innerJoin(db.books, db.books.id.equalsExp(db.readingSessions.bookId)),
    ]);
    return q.watch().map((rows) {
      final entries = rows
          .map((r) => ShelfEntry(
                session: r.readTable(db.readingSessions),
                book: r.readTable(db.books),
              ))
          .toList();
      entries.sort((a, b) {
        final sa = _statusRank(a.session.status);
        final sb = _statusRank(b.session.status);
        if (sa != sb) return sa.compareTo(sb);
        final ea = a.session.ended ?? a.session.started;
        final eb = b.session.ended ?? b.session.started;
        return eb.compareTo(ea);
      });
      return entries;
    });
  }

  int _statusRank(SessionStatus s) => switch (s) {
        SessionStatus.reading => 0,
        SessionStatus.finished => 1,
        SessionStatus.abandoned => 2,
      };

  // ---- Sessions ----------------------------------------------------------

  Stream<SessionDetail?> watchSession(String sessionId) {
    final sessionQ = db.select(db.readingSessions)
      ..where((s) => s.id.equals(sessionId));
    final reflQ = db.select(db.reflections)
      ..where((r) => r.sessionId.equals(sessionId))
      ..orderBy([(r) => OrderingTerm.asc(r.created)]);

    return sessionQ.watchSingleOrNull().asyncMap((session) async {
      if (session == null) return null;
      final book = await (db.select(db.books)
            ..where((b) => b.id.equals(session.bookId)))
          .getSingle();
      final reflections = await reflQ.get();
      return SessionDetail(
          session: session, book: book, reflections: reflections);
    });
  }

  Future<SessionDetail?> getSession(String sessionId) =>
      watchSession(sessionId).first;

  /// Creates the book and a reading session. Returns the session id.
  Future<String> addBook({
    required String title,
    required String author,
    required BookSource source,
    String? coverRef,
    String? openLibraryKey,
    int? year,
  }) async {
    final now = DateTime.now();
    final bookId = newId();
    final sessionId = newId();
    await db.transaction(() async {
      await db.into(db.books).insert(BooksCompanion.insert(
            id: bookId,
            title: title.trim(),
            author: author.trim(),
            coverRef: Value(coverRef),
            openLibraryKey: Value(openLibraryKey),
            year: Value(year),
            source: source,
            createdAt: now,
          ));
      await db.into(db.readingSessions).insert(ReadingSessionsCompanion.insert(
            id: sessionId,
            bookId: bookId,
            status: SessionStatus.reading,
            started: now,
          ));
    });
    return sessionId;
  }

  Future<void> setStatus(String sessionId, SessionStatus status) async {
    final ended = status == SessionStatus.reading ? null : DateTime.now();
    await (db.update(db.readingSessions)..where((s) => s.id.equals(sessionId)))
        .write(ReadingSessionsCompanion(
      status: Value(status),
      ended: Value(ended),
      progress: status == SessionStatus.finished
          ? const Value(100)
          : const Value.absent(),
    ));
  }

  Future<void> setProgress(String sessionId, int progress) async {
    await (db.update(db.readingSessions)..where((s) => s.id.equals(sessionId)))
        .write(ReadingSessionsCompanion(progress: Value(progress.clamp(0, 100))));
  }

  Future<void> setAbandonReason(String sessionId, String? reason) async {
    await (db.update(db.readingSessions)..where((s) => s.id.equals(sessionId)))
        .write(ReadingSessionsCompanion(abandonReason: Value(reason)));
  }

  Future<void> deleteSession(String sessionId) async {
    await db.transaction(() async {
      final session = await (db.select(db.readingSessions)
            ..where((s) => s.id.equals(sessionId)))
          .getSingleOrNull();
      if (session == null) return;
      await (db.delete(db.cards)..where((c) => c.sessionId.equals(sessionId)))
          .go();
      await (db.delete(db.reflections)
            ..where((r) => r.sessionId.equals(sessionId)))
          .go();
      await (db.delete(db.readingSessions)..where((s) => s.id.equals(sessionId)))
          .go();
      final others = await (db.select(db.readingSessions)
            ..where((s) => s.bookId.equals(session.bookId)))
          .get();
      if (others.isEmpty) {
        await (db.delete(db.books)..where((b) => b.id.equals(session.bookId)))
            .go();
      }
    });
  }

  // ---- Reflections -------------------------------------------------------

  /// Upserts one row per answered prompt. Empty responses are removed.
  Future<void> saveReflections(
      String sessionId, Map<String, String> responses) async {
    final now = DateTime.now();
    await db.transaction(() async {
      for (final entry in responses.entries) {
        final key = entry.key;
        final text = entry.value.trim();
        final existing = await (db.select(db.reflections)
              ..where((r) => r.sessionId.equals(sessionId) & r.promptKey.equals(key)))
            .getSingleOrNull();
        if (text.isEmpty) {
          if (existing != null) {
            await (db.delete(db.reflections)..where((r) => r.id.equals(existing.id)))
                .go();
          }
          continue;
        }
        if (existing == null) {
          await db.into(db.reflections).insert(ReflectionsCompanion.insert(
                id: newId(),
                sessionId: sessionId,
                promptKey: key,
                response: text,
                created: now,
              ));
        } else {
          await (db.update(db.reflections)..where((r) => r.id.equals(existing.id)))
              .write(ReflectionsCompanion(response: Value(text)));
        }
      }
    });
  }

  // ---- Cards -------------------------------------------------------------

  Future<void> recordCard(String sessionId, List<String> reflectionIds,
      {String theme = 'cream'}) async {
    await db.into(db.cards).insertOnConflictUpdate(CardsCompanion.insert(
          sessionId: sessionId,
          theme: theme,
          reflectionIds: jsonEncode(reflectionIds),
          generatedAt: DateTime.now(),
        ));
  }

  // ---- Meta --------------------------------------------------------------

  Future<String?> getMeta(String key) async {
    final row = await (db.select(db.appMeta)..where((m) => m.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setMeta(String key, String value) =>
      db.into(db.appMeta).insertOnConflictUpdate(
            AppMetaCompanion.insert(key: key, value: value),
          );

  // ---- Export / import ---------------------------------------------------

  Future<String> exportJson() async {
    final books = await db.select(db.books).get();
    final sessions = await db.select(db.readingSessions).get();
    final reflections = await db.select(db.reflections).get();
    final cards = await db.select(db.cards).get();
    final payload = {
      'app': 'afterword',
      'schema': exportSchema,
      'exportedAt': DateTime.now().toIso8601String(),
      'books': books.map((b) => b.toJson()).toList(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'reflections': reflections.map((r) => r.toJson()).toList(),
      'cards': cards.map((c) => c.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Merges by id. Existing rows with the same id are replaced.
  /// Returns the number of sessions imported.
  Future<int> importJson(String source) async {
    final json = jsonDecode(source) as Map<String, dynamic>;
    if (json['app'] != 'afterword') {
      throw const FormatException('Not an Afterword export.');
    }
    final schema = json['schema'] as int? ?? 0;
    if (schema > exportSchema) {
      throw FormatException(
          'This export is from a newer version of Afterword (schema $schema).');
    }
    final books = (json['books'] as List<dynamic>? ?? const [])
        .map((b) => Book.fromJson(b as Map<String, dynamic>))
        .toList();
    final sessions = (json['sessions'] as List<dynamic>? ?? const [])
        .map((s) => ReadingSession.fromJson(s as Map<String, dynamic>))
        .toList();
    final reflections = (json['reflections'] as List<dynamic>? ?? const [])
        .map((r) => Reflection.fromJson(r as Map<String, dynamic>))
        .toList();
    final cards = (json['cards'] as List<dynamic>? ?? const [])
        .map((c) => CardRecord.fromJson(c as Map<String, dynamic>))
        .toList();

    await db.transaction(() async {
      for (final b in books) {
        await db.into(db.books).insertOnConflictUpdate(b);
      }
      for (final s in sessions) {
        await db.into(db.readingSessions).insertOnConflictUpdate(s);
      }
      for (final r in reflections) {
        await db.into(db.reflections).insertOnConflictUpdate(r);
      }
      for (final c in cards) {
        await db.into(db.cards).insertOnConflictUpdate(c);
      }
    });
    return sessions.length;
  }
}
