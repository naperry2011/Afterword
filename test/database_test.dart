import 'package:afterword/data/database.dart';
import 'package:afterword/data/repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late Repository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = Repository(db);
  });

  tearDown(() => db.close());

  test('add a book, finish it, reflect, and read it back from the shelf',
      () async {
    final id = await repo.addBook(
      title: 'Piranesi',
      author: 'Susanna Clarke',
      year: 2020,
      source: BookSource.manual,
    );
    var shelf = await repo.watchShelf().first;
    expect(shelf, hasLength(1));
    expect(shelf.single.session.status, SessionStatus.reading);

    await repo.setProgress(id, 60);
    await repo.setStatus(id, SessionStatus.finished);
    await repo.saveReflections(id, {
      'stayed': 'The tides.',
      'who': 'You. You read for atmosphere.',
      'changed': '',
    });

    final detail = await repo.getSession(id);
    expect(detail!.session.status, SessionStatus.finished);
    expect(detail.session.progress, 100);
    expect(detail.reflections.map((r) => r.promptKey), ['stayed', 'who']);
    expect(detail.byKey('who')!.response, 'You. You read for atmosphere.');

    shelf = await repo.watchShelf().first;
    expect(shelf.single.session.status, SessionStatus.finished);
  });

  test('export then import into a fresh database round-trips', () async {
    final id = await repo.addBook(
      title: 'Stoner',
      author: 'John Williams',
      source: BookSource.manual,
    );
    await repo.setStatus(id, SessionStatus.abandoned);
    await repo.saveReflections(id, {'stopped': 'Page 40, too grey.'});
    final json = await repo.exportJson();

    final db2 = AppDatabase(NativeDatabase.memory());
    final repo2 = Repository(db2);
    final count = await repo2.importJson(json);
    expect(count, 1);
    final detail = await repo2.getSession(id);
    expect(detail!.book.title, 'Stoner');
    expect(detail.reflections.single.promptKey, 'stopped');
    await db2.close();
  });

  test('import rejects foreign JSON with a message', () async {
    expect(
      () => repo.importJson('{"hello":"world"}'),
      throwsA(isA<FormatException>()),
    );
  });
}
