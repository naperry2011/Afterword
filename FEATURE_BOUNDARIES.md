# FEATURE_BOUNDARIES

Generated: 2026-09-13 | commit 2b07e5d | by /code-map

## Theme (lib/theme/)

Owns: Colour tokens, text styles, shape and shadow constants, ThemeData, page transitions, spine colour hashing.
Does NOT Own: Any widget layout or data.
Communicates With: Every screen and widget (imported, never imports back).
Isolation Level: Strong

## Widgets (lib/widgets/)

Owns: Reusable pixel-styled primitives, spine rendering, cover with fallback, empty state, onboarding illustrations (onboarding_art.dart). Covers and card-like pictures pin their own text scale.
Does NOT Own: Data access, navigation, prompt copy.
Communicates With: lib/theme/ only. Screens compose these.
Isolation Level: Strong

## Database (lib/data/database.dart, database.g.dart)

Owns: Table definitions, enums, schema version, migration steps, executor opening.
Does NOT Own: Queries beyond raw table access, JSON shape, business rules.
Communicates With: Repository (sole consumer in app code), tests.
Isolation Level: Strong

## Repository (lib/data/repository.dart)

Owns: All reads and writes the UI is allowed to make, shelf ordering, reflection upsert rules, export/import envelope, app_meta flags.
Does NOT Own: Widgets, navigation, prompt copy, network search.
Communicates With: Database; consumed by providers, screens, seed, tests.
Isolation Level: Moderate (every screen depends on it)

## Prompts (lib/data/prompts.dart)

Owns: Prompt keys, titles, example copy, which prompts apply per status.
Does NOT Own: Storage of responses (Repository) or rendering (ReflectScreen).
Communicates With: ReflectScreen, BookScreen labels.
Isolation Level: Strong

## Open Library Client (lib/data/open_library.dart)

Owns: Search request, result parsing, cover URL construction, typed failure.
Does NOT Own: Persisting a chosen hit (Repository), cover caching (widgets/cover.dart).
Communicates With: AddScreen via openLibraryProvider.
Isolation Level: Strong

## Providers (lib/data/providers.dart)

Owns: Riverpod wiring: database, repository, Open Library, shelf and session streams, onboarding flag.
Does NOT Own: Any logic.
Communicates With: Screens, router, main.
Isolation Level: Moderate (central wiring point)

## Router (lib/app/router.dart)

Owns: Route table, onboarding redirect.
Does NOT Own: Screen content.
Communicates With: onboardingSeenProvider, all screens.
Isolation Level: Strong

## Screens (lib/screens/)

Owns: Layout and local UI state for one surface each.
Does NOT Own: Persistence rules, theme values, network parsing.
Communicates With: Repository via providers, router via go_router context calls, widgets, theme.
Isolation Level: Moderate. Cross-screen coupling is by route string only. Book pushes Reflect; Reflect replaces itself with Card; Add replaces itself with Book.

## Seed and Screenshot Harness (lib/data/seed.dart)

Owns: Opt-in dummy data (`AFTERWORD_SEED`) and the debug start route (`AFTERWORD_START`), both behind `kDebugMode`.
Does NOT Own: Anything in release builds; navigation itself (hands a location to `initialLocationProvider`).
Communicates With: Repository, main, router.
Isolation Level: Strong

## Marketing Site (docs/site/)

Owns: Landing page, privacy policy, support page, their deploy workflow.
Does NOT Own: Any app code. Shares only the colour palette and copy.
Communicates With: GitHub Pages. The app links nowhere; the store listing links here.
Isolation Level: Strong

## Platform Hosts (ios/, android/)

Owns: Native project settings, bundle id, deployment target, generated plugin registration.
Does NOT Own: Dart code.
Communicates With: Flutter engine.
Isolation Level: Strong
