# CODE_MAP

Generated: 2026-09-13 | commit 2b07e5d | by /code-map

Flutter app, iOS first. Single package, no backend. All source under `lib/`.

## App Shell and Navigation

Category: UI

Primary Files:
* lib/main.dart (seed, debug start route, provider container)
* lib/app/app.dart (MaterialApp.router, Dynamic Type clamp at 1.6x)
* lib/app/router.dart (routes, onboarding redirect, initialLocationProvider)

Supporting Files:
* lib/data/providers.dart (routerProvider reads onboardingSeenProvider)
* lib/data/seed.dart (`debugStartRoute`, debug-only screenshot harness)

Entry Points:
* `main()` in lib/main.dart

## Design System

Category: UI

Primary Files:
* lib/theme/tokens.dart (colours, spine palette, `spineColorFor`, `stableHash`)
* lib/theme/text.dart (`pix()` and `body()` text styles, TextTheme)
* lib/theme/shapes.dart (outline, offset shadow, zero radius)
* lib/theme/theme.dart (`buildTheme()`, stepped page transitions)

Supporting Files:
* lib/widgets/pixel_panel.dart
* lib/widgets/pixel_button.dart (PixelButton, QuietButton)
* lib/widgets/dashed_rule.dart
* lib/widgets/dither_fill.dart
* lib/widgets/empty_state.dart
* lib/widgets/onboarding_art.dart (MiniShelf, MiniPrompts, MiniCard)
* assets/fonts/ (Pixelify Sans, Nunito, OFL licences)
* pubspec.yaml (font declarations)

## Persistence

Category: Service

Primary Files:
* lib/data/database.dart (drift tables, enums, AppDatabase, migration strategy)
* lib/data/database.g.dart (generated, committed)
* lib/data/repository.dart (Repository, ShelfEntry, SessionDetail, export/import)

Supporting Files:
* lib/data/ids.dart (`newId()`)
* lib/data/seed.dart (opt-in dummy data via `--dart-define=AFTERWORD_SEED`, debug start route via `AFTERWORD_START`)
* lib/data/providers.dart (databaseProvider, repositoryProvider, shelfProvider, sessionProvider)

External Integrations:
* SQLite on device via drift_flutter

## Book Search

Category: Service

Primary Files:
* lib/data/open_library.dart (OpenLibrary client, BookHit, SearchResult)

Supporting Files:
* lib/data/providers.dart (openLibraryProvider)
* lib/widgets/cover.dart (BookCover with typographic fallback, cached_network_image)

External Integrations:
* Open Library search API (https://openlibrary.org/search.json)
* Open Library covers CDN (https://covers.openlibrary.org)

## Shelf

Category: Page · route `/`

Primary Files:
* lib/screens/shelf_screen.dart (shelf row, count line, empty state with prompt preview)

Supporting Files:
* lib/widgets/spine.dart (SolidSpine, ProgressSpine, EmptySlot, `spineGeometry`)
* lib/data/prompts.dart (empty-state preview)
* lib/data/repository.dart (`watchShelf`)

## Book Detail

Category: Page · route `/book/:sessionId`

Primary Files:
* lib/screens/book_screen.dart

Supporting Files:
* lib/data/repository.dart (`watchSession`, `setStatus`, `setProgress`, `deleteSession`)
* lib/data/prompts.dart (labels for stored reflections)
* lib/widgets/cover.dart

## Reflect Flow

Category: Page · route `/book/:sessionId/reflect` (pushed automatically by Book on finish or abandon)

Primary Files:
* lib/screens/reflect_screen.dart
* lib/data/prompts.dart (Prompt, `promptsFor`, `promptsByKey`)

Supporting Files:
* lib/data/repository.dart (`saveReflections`, `setAbandonReason`)

## Share Card

Category: Page · route `/book/:sessionId/card`

Primary Files:
* lib/screens/card_screen.dart (`kCardSize`, RepaintBoundary capture, share)

Supporting Files:
* lib/data/repository.dart (`recordCard`)
* lib/widgets/cover.dart
* lib/widgets/dashed_rule.dart

External Integrations:
* System share sheet via share_plus
* Temp directory via path_provider

## Add Book

Category: Page · route `/add`

Primary Files:
* lib/screens/add_screen.dart (search, failure state, manual entry)

Supporting Files:
* lib/data/open_library.dart
* lib/data/repository.dart (`addBook`)

## Settings

Category: Page · route `/settings`

Primary Files:
* lib/screens/settings_screen.dart (export, import, privacy, about)

Supporting Files:
* lib/data/repository.dart (`exportJson`, `importJson`)

External Integrations:
* share_plus (export), file_picker (import), path_provider

## Onboarding

Category: Page · route `/onboarding` (router redirect on fresh install)

Primary Files:
* lib/screens/onboarding_screen.dart (three pages, `initialPage` from `?page=`)

Supporting Files:
* lib/widgets/onboarding_art.dart
* lib/data/providers.dart (onboardingSeenProvider, `onboardingSeenKey`)
* lib/data/repository.dart (`getMeta`, `setMeta`)

## Platform Projects

Category: Infra

Primary Files:
* ios/ (bundle id com.nickperry.afterword, target 15.0, team PGVTN7X3HQ, iPhone only, portrait only)
* ios/Runner/Assets.xcassets/AppIcon.appiconset/ (pixel lamp icon)
* ios/Runner/Base.lproj/LaunchScreen.storyboard (plain room colour, no image)
* android/ (generated, deferred)

## Marketing Site

Category: Page

Primary Files:
* docs/site/index.html (landing page, lo-fi night)
* docs/site/privacy.html
* docs/site/support.html

Supporting Files:
* .github/workflows/pages.yml (deploys docs/site to GitHub Pages on push)

External Integrations:
* GitHub Pages at https://naperry2011.github.io/Afterword/
* Google Fonts (site only; the app bundles its fonts)

## Tests, Docs, Store Assets

Category: Other

* test/helpers.dart (`settle`, `drive`, `tearDownApp` for drift under fake async)
* test/database_test.dart, test/app_smoke_test.dart, test/reflect_flow_test.dart, test/dynamic_type_test.dart
* CLAUDE.md (stack, rules, schedule, cut order, harness commands)
* docs/afterword-build-spec.md (working spec), docs/decisions.md (decision log), docs/reading-log-build-plan.pdf
* docs/design/ (landing page source and design screenshots)
* docs/store/screenshots-6.9in/ (1320×2868 PNGs: shelf, reflect, card, book)
