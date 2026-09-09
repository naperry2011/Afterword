import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Where a book record came from.
enum BookSource { api, manual }

enum SessionStatus { reading, finished, abandoned }

/// Immutable reference data. Cacheable, replaceable.
class Books extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  TextColumn get coverRef => text().nullable()();
  TextColumn get openLibraryKey => text().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get source => textEnum<BookSource>()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One book can have many sessions. Rereads are real.
class ReadingSessions extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().references(Books, #id)();
  TextColumn get status => textEnum<SessionStatus>()();
  DateTimeColumn get started => dateTime()();
  DateTimeColumn get ended => dateTime().nullable()();

  /// Single "how far in are you" value, 0..100. No history (decision 2026-09-08).
  IntColumn get progress => integer().withDefault(const Constant(0))();
  TextColumn get abandonReason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per prompt answered. Adding a prompt later is data, not a migration.
class Reflections extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(ReadingSessions, #id)();
  TextColumn get promptKey => text()();
  TextColumn get response => text()();
  DateTimeColumn get created => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sharing is a view over reflections, never a copy of them.
@DataClassName('CardRecord')
class Cards extends Table {
  TextColumn get sessionId => text().references(ReadingSessions, #id)();
  TextColumn get theme => text()();

  /// JSON-encoded list of reflection ids.
  TextColumn get reflectionIds => text()();
  DateTimeColumn get generatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {sessionId};
}

/// Small key/value store for app flags (onboarding seen, seed applied).
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Books, ReadingSessions, Reflections, Cards, AppMeta])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  /// Bump this and add a case to [_upgrade] for every schema change.
  /// Never edit an existing table definition without a migration step.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: _upgrade,
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _upgrade(Migrator m, int from, int to) async {
    // Apply migrations in order so any old version reaches [to].
    for (var v = from + 1; v <= to; v++) {
      switch (v) {
        // case 2:
        //   await m.addColumn(books, books.someNewColumn);
        //   break;
        default:
          break;
      }
    }
  }

  static QueryExecutor _open() => driftDatabase(name: 'afterword');
}
