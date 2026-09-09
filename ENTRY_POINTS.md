# ENTRY_POINTS

Generated: 2026-09-08 | commit 723a953 | by /code-map

## App Main

Path: lib/main.dart
Responsibility: Initialise bindings, create the ProviderContainer, apply debug seed data, run the app.
Invokes: `applySeedIfEmpty` (lib/data/seed.dart), `AfterwordApp` (lib/app/app.dart)
Depends On: lib/data/providers.dart

## Router

Path: lib/app/router.dart
Responsibility: Declares every route and the onboarding redirect.
Invokes: All screens under lib/screens/
Depends On: onboardingSeenProvider (lib/data/providers.dart)

Routes:
* `/` ShelfScreen
* `/book/:sessionId` BookScreen
* `/book/:sessionId/reflect` ReflectScreen
* `/book/:sessionId/card` CardScreen
* `/add` AddScreen
* `/settings` SettingsScreen
* `/onboarding` OnboardingScreen

## Drift Code Generation

Path: `dart run build_runner build --delete-conflicting-outputs`
Responsibility: Regenerates lib/data/database.g.dart after schema edits.
Invokes: drift_dev
Depends On: lib/data/database.dart

## Tests

Path: `flutter test`
Responsibility: Repository tests on an in-memory database and an app boot smoke test.
Invokes: test/database_test.dart, test/app_smoke_test.dart
Depends On: lib/data/database.dart, lib/data/repository.dart, lib/app/app.dart

## iOS Runner

Path: ios/Runner/
Responsibility: Native host for the Flutter engine. Display name "Afterword".
Invokes: Flutter engine → lib/main.dart
Depends On: ios/Runner.xcodeproj, generated Swift package under ios/Flutter/ephemeral/

## Android Runner

Path: android/app/
Responsibility: Generated Android host. Not in use for the current release window.
Invokes: Flutter engine → lib/main.dart
Depends On: android/build.gradle.kts
