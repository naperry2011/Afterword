import 'package:afterword/app/app.dart';
import 'package:afterword/data/database.dart';
import 'package:afterword/data/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots to onboarding on a fresh install', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    debugPrint('pumping');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const AfterwordApp(),
      ),
    );
    debugPrint('pumped once');
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    debugPrint('pumped 20 frames');
    expect(find.text('Read one more book than last year'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 90)));
}
