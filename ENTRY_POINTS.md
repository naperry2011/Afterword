# ENTRY_POINTS

Generated: 2026-09-13 | commit 2b07e5d | by /code-map

## App Main

Path: lib/main.dart
Responsibility: Initialise bindings, create the ProviderContainer, apply opt-in seed data, resolve the debug start route, run the app.
Invokes: `applySeedIfEmpty`, `debugStartRoute` (lib/data/seed.dart), `AfterwordApp` (lib/app/app.dart)
Depends On: lib/data/providers.dart, `initialLocationProvider` (lib/app/router.dart)

## Screenshot Harness (debug only)

Path: `flutter build ios --simulator --debug --dart-define=AFTERWORD_SEED=true --dart-define=AFTERWORD_START=<route>`
Responsibility: Boots straight to a chosen surface with demo data for store screenshots. Routes: `onboarding:0..2`, `shelf`, `book:reading|finished`, `reflect:finished`, `card:finished`. Ignored in release.
Invokes: lib/data/seed.dart
Depends On: `kDebugMode`

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
* `/onboarding?page=N` OnboardingScreen

## Drift Code Generation

Path: `dart run build_runner build --delete-conflicting-outputs`
Responsibility: Regenerates lib/data/database.g.dart after schema edits.
Invokes: drift_dev
Depends On: lib/data/database.dart

## Tests

Path: `flutter test`
Responsibility: Repository tests, boot smoke test, end-to-end reflect flow, Dynamic Type overflow guard.
Invokes: test/database_test.dart, test/app_smoke_test.dart, test/reflect_flow_test.dart, test/dynamic_type_test.dart
Depends On: test/helpers.dart, lib/data/database.dart, lib/data/repository.dart, lib/app/app.dart

## Release Archive

Path: `flutter build ipa`
Responsibility: Signed App Store archive and IPA in build/ios/ipa/. Automatic signing with team PGVTN7X3HQ.
Invokes: Xcode archive and export
Depends On: ios/Runner.xcodeproj, Xcode account for perry.ai2011@gmail.com

## Site Deploy

Path: .github/workflows/pages.yml
Responsibility: Publishes docs/site to GitHub Pages on push to main when docs/site changes.
Invokes: actions/upload-pages-artifact, actions/deploy-pages
Depends On: GitHub Pages enabled with workflow build type

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
