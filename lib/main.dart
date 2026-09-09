import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'data/providers.dart';
import 'data/seed.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await applySeedIfEmpty(container.read(repositoryProvider));
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AfterwordApp(),
    ),
  );
}
