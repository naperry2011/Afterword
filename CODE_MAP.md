# CODE_MAP

Generated: 2026-09-08 | commit 723a953 | by /code-map

Flutter app, iOS first. Single package, no backend. All source under `lib/`.

## App Shell and Navigation

Category: UI

Primary Files:
* lib/main.dart
* lib/app/app.dart
* lib/app/router.dart

Supporting Files:
* lib/data/providers.dart (routerProvider reads onboardingSeenProvider)

External Integrations:
* none

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
* assets/fonts/ (Pixelify Sans, Nunito, OFL licences)
* pubspec.yaml (font declarations)

External Integrations:
* none

## Persistence

Category: Service

Primary Files:
* lib/data/database.dart (drift tables, enums, AppDatabase, migration strategy)
* lib/data/database.g.dart (generated, committed)
* lib/data/repository.dart (Repository, ShelfEntry, SessionDetail, export/import)

Supporting Files:
* lib/data/ids.dart (`newId()`)
* lib/data/seed.dart (debug-only dummy data, `kSeedDummyData`)
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

Category: Page

Primary Files:
* lib/screens/shelf_screen.dart

Supporting Files:
* lib/widgets/spine.dart (SolidSpine, ProgressSpine, EmptySlot, `spineGeometry`)
* lib/data/repository.dart (`watchShelf`)

Entry Points:
* route `/`

## Book Detail

Category: Page

Primary Files:
* lib/screens/book_screen.dart

Supporting Files:
* lib/data/repository.dart (`watchSession`, `setStatus`, `setProgress`, `deleteSession`)
* lib/data/prompts.dart (labels for stored reflections)
* lib/widgets/cover.dart

Entry Points:
* route `/book/:sessionId`

## Reflect Flow

Category: Page

Primary Files:
* lib/screens/reflect_screen.dart
* lib/data/prompts.dart (Prompt, `promptsFor`, `promptsByKey`)

Supporting Files:
* lib/data/repository.dart (`saveReflections`, `setAbandonReason`)

Entry Points:
* route `/book/:sessionId/reflect` (pushed automatically by Book on finish or abandon)

## Share Card

Category: Page

Primary Files:
* lib/screens/card_screen.dart (`kCardSize`, RepaintBoundary capture, share)

Supporting Files:
* lib/data/repository.dart (`recordCard`)
* lib/widgets/cover.dart
* lib/widgets/dashed_rule.dart

External Integrations:
* System share sheet via share_plus
* Temp directory via path_provider

Entry Points:
* route `/book/:sessionId/card`

## Add Book

Category: Page

Primary Files:
* lib/screens/add_screen.dart (search, failure state, manual entry)

Supporting Files:
* lib/data/open_library.dart
* lib/data/repository.dart (`addBook`)

Entry Points:
* route `/add`

## Settings

Category: Page

Primary Files:
* lib/screens/settings_screen.dart (export, import, privacy, about)

Supporting Files:
* lib/data/repository.dart (`exportJson`, `importJson`)

External Integrations:
* share_plus (export), file_picker (import), path_provider

Entry Points:
* route `/settings`

## Onboarding

Category: Page

Primary Files:
* lib/screens/onboarding_screen.dart

Supporting Files:
* lib/data/providers.dart (onboardingSeenProvider, `onboardingSeenKey`)
* lib/data/repository.dart (`getMeta`, `setMeta`)

Entry Points:
* route `/onboarding` (router redirect on fresh install)

## Tests

Category: Other

Primary Files:
* test/database_test.dart (repository against in-memory drift)
* test/app_smoke_test.dart (boot to onboarding)

## Platform Projects

Category: Infra

Primary Files:
* ios/ (bundle id com.nickperry.afterword, deployment target 15.0)
* android/ (generated, deferred)

## Documentation

Category: Other

Primary Files:
* CLAUDE.md (stack, rules, schedule, cut order)
* docs/afterword-build-spec.md (working spec)
* docs/decisions.md (decision log)
* docs/reading-log-build-plan.pdf
* docs/design/ (landing page HTML and screenshots, web-only)
