import 'package:afterword/data/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drift streams and go_router redirects need a few frames; pumpAndSettle
/// can spin forever on the text cursor blink, so pump a bounded number.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Once drift streams exist in the fake zone, mixing in runAsync deadlocks.
/// Pump frames instead so fake timers fire and the future completes.
Future<T> drive<T>(WidgetTester tester, Future<T> future) async {
  var done = false;
  T? result;
  Object? error;
  future.then((v) {
    result = v;
    done = true;
  }, onError: (Object e) {
    error = e;
    done = true;
  });
  for (var i = 0; i < 40 && !done; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  if (!done) throw StateError('future did not complete under fake time');
  if (error != null) throw error!;
  return result as T;
}

/// Unmount the tree so riverpod disposes the drift streams, pump once so
/// drift's zero-duration close timer fires, then close the database.
Future<void> tearDownApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
  await drive(tester, db.close());
}
