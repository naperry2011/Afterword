import 'package:afterword/app/app.dart';
import 'package:afterword/data/database.dart';
import 'package:afterword/data/providers.dart';
import 'package:afterword/data/repository.dart';
import 'package:afterword/theme/layout.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Every surface must lay out without a RenderFlex overflow, on the smallest
/// iPhone and on a tall Android phone. The app clamps the scaler at 1.6, so a
/// 3x request still has to render cleanly.
void main() {
  const iphone16e = _Screen(
    'iPhone 16e',
    physicalSize: Size(1170, 2532),
    ratio: 3,
    padding: FakeViewPadding(top: 141, bottom: 102),
  );
  // Medium Phone API 37: 411x914 at density 2.625, gesture nav.
  const tallAndroid = _Screen(
    'tall Android',
    physicalSize: Size(1080, 2400),
    ratio: 2.625,
    padding: FakeViewPadding(top: 63, bottom: 63),
  );

  for (final (screen, scale) in [
    (iphone16e, 3.0),
    (tallAndroid, 3.0),
    (tallAndroid, 1.0),
  ]) {
    testWidgets(
      'all surfaces fit on ${screen.name} at ${scale}x text',
      (tester) => _walkEverySurface(tester, screen, scale),
    );
  }
}

class _Screen {
  const _Screen(
    this.name, {
    required this.physicalSize,
    required this.ratio,
    required this.padding,
  });
  final String name;
  final Size physicalSize;
  final double ratio;
  final FakeViewPadding padding;
}

Future<void> _walkEverySurface(
  WidgetTester tester,
  _Screen screen,
  double scale,
) async {
  tester.view.physicalSize = screen.physicalSize;
  tester.view.devicePixelRatio = screen.ratio;
  tester.view.padding = screen.padding;
  tester.view.viewPadding = screen.padding;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  PixelGrid.init(screen.ratio);
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.view.resetPadding();
    tester.view.resetViewPadding();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    PixelGrid.init(3);
  });

  final db = AppDatabase(NativeDatabase.memory());
  final repo = Repository(db);
  await tester.runAsync(() async {
    await repo.addBook(
      title: 'Piranesi',
      author: 'Susanna Clarke',
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
