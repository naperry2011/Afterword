import 'package:afterword/app/app.dart';
import 'package:afterword/data/database.dart';
import 'package:afterword/data/providers.dart';
import 'package:afterword/data/repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// The one sentence, as a test: add a book, mark it finished, answer the
/// prompts, land on a card. Runs against the real widget tree and an
/// in-memory drift database. Share itself is a platform plugin and is not
/// exercised here.
void main() {
  testWidgets('shelf → book → finished → reflect → card', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    // Drift needs real async; the test binding runs under fake time.
    await tester.runAsync(() async {
      await repo.setMeta(onboardingSeenKey, 'true');
      await repo.addBook(
        title: 'Piranesi',
        author: 'Susanna Clarke',
        year: 2020,
        source: BookSource.manual,
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const AfterwordApp(),
      ),
    );
    await settle(tester);

    // Shelf shows the book in the list and the count line.
    expect(find.text('Piranesi'), findsWidgets);
    expect(find.textContaining('IN PROGRESS'), findsOneWidget);

    // Into the book.
    await tester.tap(find.text('Piranesi').last);
    await settle(tester);
    expect(find.text('STATUS'), findsOneWidget);
    expect(find.text('HOW FAR IN'), findsOneWidget);

    // Marking finished opens Reflect automatically.
    await tester.tap(find.text('Finished'));
    await settle(tester);
    expect(find.text('What stayed with you?'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('1 OF 3'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'The tides.');
    await tester.tap(find.text('Next'));
    await settle(tester);
    expect(find.text('Who should read this, and why them?'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.enterText(
        find.byType(TextField), 'You. You read for atmosphere, not plot.');
    await tester.tap(find.text('Next'));
    await settle(tester);
    expect(find.text('What did it change?'), findsOneWidget);
    expect(find.text('3 OF 3 · OPTIONAL'), findsOneWidget);

    // Skip the optional one. That finishes the flow: save, then replace the
    // route with the card, which then loads its own session stream.
    await tester.tap(find.text('Skip'));
    await settle(tester);
    await settle(tester);
    await settle(tester);

    // Card renders the `who` answer and offers the share button.
    expect(find.text('Send it'), findsOneWidget);
    expect(find.text('You. You read for atmosphere, not plot.'), findsOneWidget);
    expect(find.text('AFTERWORD'), findsOneWidget);

    // Back on the Book screen the saved answers show, the skipped optional
    // one does not, and the card button is offered.
    await tester.pageBack();
    await settle(tester);
    expect(find.text('WHAT STAYED WITH YOU?'), findsOneWidget);
    expect(find.text('The tides.'), findsOneWidget);
    expect(find.text('WHAT DID IT CHANGE?'), findsNothing);
    await tester.scrollUntilVisible(find.text('Send a card'), 120,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Send a card'), findsOneWidget);

    await tearDownApp(tester, db);
  });

  testWidgets('abandoning swaps the first prompt', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    await tester.runAsync(() async {
      await repo.setMeta(onboardingSeenKey, 'true');
      await repo.addBook(
          title: 'Stoner', author: 'John Williams', source: BookSource.manual);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const AfterwordApp(),
      ),
    );
    await settle(tester);
    await tester.tap(find.text('Stoner').last);
    await settle(tester);
    await tester.tap(find.text('Put down'));
    await settle(tester);
    expect(find.text('Where did you stop, and why?'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tearDownApp(tester, db);
  });
}
