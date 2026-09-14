# DATA_FLOW

Generated: 2026-09-13 | commit 2b07e5d | by /code-map

All storage is on device. No network call other than Open Library search and cover fetches.

## Book Search

Source: AddScreen text field
Transport: HTTPS GET to openlibrary.org/search.json (lib/data/open_library.dart)
Processor: `OpenLibrary.search` → `SearchSuccess` or `SearchFailure`
Storage: none until the user picks a hit
Downstream Consumers: AddScreen result list, manual-entry fallback on failure

## Add Book

Source: AddScreen (search hit or manual form)
Transport: in-process call
Processor: `Repository.addBook` (transaction: books + reading_sessions)
Storage: SQLite via drift
Downstream Consumers: shelfProvider stream → ShelfScreen; BookScreen via pushReplacement

## Cover Images

Source: coverRef URL stored on the book row
Transport: HTTPS GET to covers.openlibrary.org
Processor: cached_network_image (lib/widgets/cover.dart)
Storage: image cache on disk (managed by the package)
Downstream Consumers: BookCover in Book, Add, and Card screens; typographic fallback when absent

## Status and Progress

Source: BookScreen status chips and slider
Transport: in-process call
Processor: `Repository.setStatus`, `Repository.setProgress`
Storage: reading_sessions row
Downstream Consumers: sessionProvider stream → BookScreen; shelfProvider → spine fill; status change to finished or abandoned pushes ReflectScreen

## Reflections

Source: ReflectScreen text fields, one per prompt key
Transport: in-process call
Processor: `Repository.saveReflections` (upsert per key, empty responses deleted); `setAbandonReason` for the `stopped` key
Storage: reflections rows; reading_sessions.abandonReason
Downstream Consumers: BookScreen reflection tiles; CardScreen (`who` key)

## Share Card

Source: CardScreen RepaintBoundary at 540×675 logical
Transport: `toImage(pixelRatio: 2)` → PNG bytes → temp file (path_provider)
Processor: `Repository.recordCard` then share_plus
Storage: cards row (session id, reflection ids); PNG in temp dir
Downstream Consumers: system share sheet

## Export

Source: SettingsScreen
Transport: `Repository.exportJson` → temp file → share_plus
Processor: JSON envelope `{app, schema, exportedAt, books, sessions, reflections, cards}`
Storage: temp dir only
Downstream Consumers: whatever the user shares to

## Import

Source: file_picker (JSON)
Transport: bytes → utf8 → `Repository.importJson`
Processor: validates `app == afterword` and schema ≤ current; insertOnConflictUpdate per table
Storage: SQLite
Downstream Consumers: shelfProvider stream

## App Flags

Source: OnboardingScreen, seed.dart (seed guard, debug start route marks onboarding seen)
Transport: `Repository.setMeta` / `getMeta`
Processor: none
Storage: app_meta key/value table
Downstream Consumers: onboardingSeenProvider → router redirect; seed guard

## Site Publish

Source: docs/site/ on main
Transport: GitHub Actions (.github/workflows/pages.yml)
Processor: upload-pages-artifact, deploy-pages
Storage: GitHub Pages
Downstream Consumers: App Store listing (privacy and support URLs), landing page visitors
