import 'dart:io';

import 'package:flutter/foundation.dart';

import 'database.dart';
import 'repository.dart';

/// Debug-only dummy data for screenshots and development. Off by default.
/// Opt in with `flutter run --dart-define=AFTERWORD_SEED=true`. Release
/// builds ignore it entirely (see the kDebugMode guard below).
const bool kSeedDummyData = bool.fromEnvironment('AFTERWORD_SEED');

const _metaKey = 'seed.v1.applied';

/// Nine finished, one in progress. Matches the landing page count line.
const _finished = [
  ('Piranesi', 'Susanna Clarke', 2020),
  ('The Left Hand of Darkness', 'Ursula K. Le Guin', 1969),
  ('Stoner', 'John Williams', 1965),
  ('Giovanni\'s Room', 'James Baldwin', 1956),
  ('Convenience Store Woman', 'Sayaka Murata', 2016),
  ('The Remains of the Day', 'Kazuo Ishiguro', 1989),
  ('A Visit from the Goon Squad', 'Jennifer Egan', 2010),
  ('The Vegetarian', 'Han Kang', 2007),
  ('Sula', 'Toni Morrison', 1973),
];

/// Debug-only start route for screenshots. Pass it as
/// `--dart-define=AFTERWORD_START=card:finished` (an environment variable of
/// the same name also works where the launcher passes one through).
/// Forms: `shelf`, `book:reading`, `book:finished`, `reflect:finished`,
/// `card:finished`. Ignored outside debug builds.
Future<String?> debugStartRoute(Repository repo) async {
  if (!kDebugMode) return null;
  const fromDefine = String.fromEnvironment('AFTERWORD_START');
  final spec = Platform.environment['AFTERWORD_START'] ?? fromDefine;
  if (spec.isEmpty || spec == 'shelf') return null;
  final parts = spec.split(':');
  if (parts.length != 2) return null;
  final shelf = await repo.watchShelf().first;
  final want = parts[1] == 'reading'
      ? SessionStatus.reading
      : SessionStatus.finished;
  final entry = shelf.where((e) => e.session.status == want).firstOrNull;
  if (entry == null) return null;
  final id = entry.session.id;
  return switch (parts[0]) {
    'book' => '/book/$id',
    'reflect' => '/book/$id/reflect',
    'card' => '/book/$id/card',
    _ => null,
  };
}

Future<void> applySeedIfEmpty(Repository repo) async {
  if (!kDebugMode || !kSeedDummyData) return;
  if (await repo.getMeta(_metaKey) == 'true') return;
  final existing = await repo.db.select(repo.db.readingSessions).get();
  if (existing.isNotEmpty) return;

  await repo.setMeta('onboarding.seen', 'true');
  for (final (title, author, year) in _finished) {
    final id = await repo.addBook(
      title: title,
      author: author,
      year: year,
      source: BookSource.manual,
    );
    await repo.setStatus(id, SessionStatus.finished);
    if (title == 'Piranesi') {
      await repo.saveReflections(id, {
        'stayed': 'The tides. A house with an ocean in it, and the way he '
            'keeps a record of everything because nobody else will.',
        'who': 'You. You read for atmosphere more than plot and this is '
            'nothing but atmosphere. Also the tides. I\'m still thinking '
            'about the tides.',
      });
    }
  }
  final reading = await repo.addBook(
    title: 'The Dispossessed',
    author: 'Ursula K. Le Guin',
    year: 1974,
    source: BookSource.manual,
  );
  await repo.setProgress(reading, 60);
  await repo.setMeta(_metaKey, 'true');
}
