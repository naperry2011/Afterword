import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/theme.dart';
import 'router.dart';

class AfterwordApp extends ConsumerWidget {
  const AfterwordApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Afterword',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: router,
      // Honour Dynamic Type up to a point. Past 1.6x the pixel display face
      // stops fitting the screens we designed; body copy stays readable.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(maxScaleFactor: 1.6),
          ),
          child: child!,
        );
      },
    );
  }
}
