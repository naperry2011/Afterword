import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'data/providers.dart';
import 'data/seed.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var container = ProviderContainer();
  await applySeedIfEmpty(container.read(repositoryProvider));
  final start = await debugStartRoute(container.read(repositoryProvider));
  if (start != null) {
    final db = container.read(databaseProvider);
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      initialLocationProvider.overrideWithValue(start),
    ]);
  }
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AfterwordApp(),
    ),
  );
}
