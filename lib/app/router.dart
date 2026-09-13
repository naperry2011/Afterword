import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../screens/add_screen.dart';
import '../screens/book_screen.dart';
import '../screens/card_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/reflect_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shelf_screen.dart';

/// Overridden in main for debug screenshot runs. Always '/' in release.
final initialLocationProvider = Provider<String>((_) => '/');

/// Four surfaces. Shelf → Book → Reflect → Card, plus Add and Settings.
final routerProvider = Provider<GoRouter>((ref) {
  final seen = ref.watch(onboardingSeenProvider);
  return GoRouter(
    initialLocation: ref.watch(initialLocationProvider),
    redirect: (context, state) {
      final done = seen.asData?.value;
      if (done == null) return null; // still loading, stay put
      final onOnboarding = state.matchedLocation == '/onboarding';
      if (!done && !onOnboarding) return '/onboarding';
      if (done && onOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const ShelfScreen(),
        routes: [
          GoRoute(
            path: 'book/:sessionId',
            builder: (_, s) =>
                BookScreen(sessionId: s.pathParameters['sessionId']!),
            routes: [
              GoRoute(
                path: 'reflect',
                builder: (_, s) =>
                    ReflectScreen(sessionId: s.pathParameters['sessionId']!),
              ),
              GoRoute(
                path: 'card',
                builder: (_, s) =>
                    CardScreen(sessionId: s.pathParameters['sessionId']!),
              ),
            ],
          ),
          GoRoute(path: 'add', builder: (_, _) => const AddScreen()),
          GoRoute(path: 'settings', builder: (_, _) => const SettingsScreen()),
        ],
      ),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    ],
  );
});
