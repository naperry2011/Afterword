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

Future<void> applySeedIfEmpty(Repository repo) async {
  if (!kDebugMode || !kSeedDummyData) return;
  if (await repo.getMeta(_metaKey) == 'true') return;
  final existing = await repo.db.select(repo.db.readingSessions).get();
  if (existing.isNotEmpty) return;

  for (final (title, author, year) in _finished) {
    final id = await repo.addBook(
      title: title,
      author: author,
      year: year,
      source: BookSource.manual,
    );
    await repo.setStatus(id, SessionStatus.finished);
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
