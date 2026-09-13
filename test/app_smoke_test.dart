import 'package:afterword/app/app.dart';
import 'package:afterword/data/database.dart';
import 'package:afterword/data/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('app boots to onboarding on a fresh install', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const AfterwordApp(),
      ),
    );
    await settle(tester);
    expect(find.text('Read one more book than last year'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tearDownApp(tester, db);
  });
}
