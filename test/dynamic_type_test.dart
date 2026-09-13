import 'package:afterword/app/app.dart';
import 'package:afterword/data/database.dart';
import 'package:afterword/data/providers.dart';
import 'package:afterword/data/repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Largest Dynamic Type on the smallest screen: every surface must lay out
/// without a RenderFlex overflow. The app clamps the scaler at 1.6, so a 3x
/// request from iOS still has to render cleanly.
void main() {
  testWidgets('all surfaces survive max dynamic type on a small phone',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532); // iPhone 16e
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    await tester.runAsync(() async {
      await repo.addBook(
          title: 'Piranesi', author: 'Susanna Clarke', source: BookSource.manual);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const AfterwordApp(),
      ),
    );
    await settle(tester);

    // Onboarding, all three pages.
    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await settle(tester);
    await tester.tap(find.text('Next'));
    await settle(tester);
    await tester.tap(find.text('Start tonight'));
    await settle(tester);
    _expectNoOverflow(tester, 'onboarding');

    // Shelf, Settings, Add.
    expect(find.text('Piranesi'), findsWidgets);
    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    expect(find.text('Export as JSON'), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    await tester.tap(find.text('Add a book'));
    await settle(tester);
    expect(find.text('Search'), findsOneWidget);
    await tester.tap(find.text('Add it by hand instead'));
    await settle(tester);
    expect(find.text('Put it on the shelf'), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    _expectNoOverflow(tester, 'shelf/settings/add');

    // Book → Reflect → Card.
    await tester.tap(find.text('Piranesi').last);
    await settle(tester);
    await tester.tap(find.text('Finished'));
    await settle(tester);
    expect(find.text('What stayed with you?'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'You. Atmosphere over plot.');
    await tester.tap(find.text('Next'));
    await settle(tester);
    await tester.tap(find.text('Skip'));
    await settle(tester);
    await settle(tester);
    expect(find.text('Send it'), findsOneWidget);
    _expectNoOverflow(tester, 'book/reflect/card');

    await tearDownApp(tester, db);
  });
}

/// Fails with the full Flutter diagnostics (including the widget creator
/// chain) so an overflow points at the file that caused it.
void _expectNoOverflow(WidgetTester tester, String where) {
  final e = tester.takeException();
  if (e == null) return;
  final text = e is FlutterError
      ? e.diagnostics.map((d) => d.toStringDeep()).join('\n')
      : e.toString();
  fail('$where overflowed:\n$text');
}
