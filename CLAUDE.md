# Afterword

A private, reflection-first reading journal with shareable recommendation cards. Flutter, iOS first, Android deferred. Local-only, no account, no server.

**The one sentence:** a person adds the book they're reading, marks it finished, answers three questions in under ninety seconds, and texts a friend a card that makes that friend want to read it. Everything else exists to protect that sentence.

## Documents

- `docs/afterword-build-spec.md` is the working spec. It wins over the PDF if they disagree.
- `docs/reading-log-build-plan.pdf` is the original brief and reasoning.
- `docs/decisions.md` is the dated decision log. Add to it, never rewrite history.
- `docs/design/` holds the landing page (web-only atmosphere: grain, rain, lamp bleed) and screenshots. Do not port the nook scene into the app.

## Dates that are not ours to move

| Date | Milestone |
|---|---|
| Sept 10 | Polish pass: no placeholders, no default icon, every empty state designed, no unreleased-feature copy in the binary |
| Sept 11 | QA on both simulators in release mode: airplane mode, small screen, largest dynamic type, fresh install, upgrade over previous build |
| Sept 12 | Store metadata: icon, screenshots, privacy URL live, support URL live, description, keywords, App Privacy |
| Sept 13 | Signed release build in App Store Connect, installed via TestFlight by an external tester |
| **Sept 14** | **Submit** |
| Sept 15–16 | Answer any rejection same day. Blocking fixes only |
| Sept 17 | Live |

Apple Developer enrollment is active (confirmed 2026-09-08).

## Stack

| Need | Choice |
|---|---|
| DB | `drift` + `drift_flutter`. Schema in `lib/data/database.dart`, generated code committed. Bump `schemaVersion` and add a case to `_upgrade` for every schema change. |
| State | `flutter_riverpod` 3, plain providers in `lib/data/providers.dart`. No riverpod codegen. |
| Navigation | `go_router`, routes in `lib/app/router.dart` |
| HTTP | `http`, Open Library client in `lib/data/open_library.dart` |
| Covers | `cached_network_image` with the typographic fallback in `lib/widgets/cover.dart` |
| Card | `RepaintBoundary.toImage` at 2x of a 540x675 logical card → `share_plus` |
| Export | JSON envelope via `share_plus`; import via `file_picker` |
| Fonts | Pixelify Sans and Nunito bundled in `assets/fonts/` (variable TTFs, OFL) |

Bundle id `com.nickperry.afterword`. iOS deployment target 15.0.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after editing database.dart
flutter analyze
flutter test
flutter run -d "iPhone 17 Pro"      # simulators: "iPhone 17 Pro", "iPhone 16e" (small-screen QA)
flutter build ios --release          # Sept 13
```

No physical iPhone is available (2026-09-13). QA runs on the simulators in release mode; TestFlight external testers are the real-device check.

## Layout

```
lib/
  main.dart            seeds debug data, boots the app
  app/                 AfterwordApp, router
  theme/               tokens (colours, spine palette), text, shapes, ThemeData
  widgets/             PixelPanel, PixelButton, DashedRule, DitherFill, spines, BookCover, EmptyState
  data/                drift schema, prompts, Open Library, repository, seed, providers
  screens/             shelf, book, reflect, card, add, settings, onboarding
test/                  drift repository tests (in-memory), app smoke test
```

## Standing rules (from the spec, enforced in review)

- Reflection is the path of least resistance. Marking finished or abandoned opens Reflect automatically.
- Skip is always visible and never guilted.
- Zero border radius. 3px `Tokens.outline` borders. Offset shadows, no blur.
- Stepped motion or no motion. No smooth easing anywhere.
- Pixelify Sans for headings, labels, buttons, counts. Nunito for anything you read. Never the reverse.
- No blank text fields: every prompt carries its example.
- No feature in the binary that isn't shipped. No coming-soon copy, no greyed tabs.
- Nothing leaves the device except a card or an export the user sends.
- Prompts are stored by key (`stayed`, `who`, `changed`, `stopped`), never by index or wording.
- Spine colour and geometry come from the book id and must stay stable.
- Search failure shows a message and a manual-entry button, never an unresolved spinner.

## Cut order if Sept 10 arrives and it isn't polish-ready

1. Auth / remote storage (already gone)
2. Progress → already a single slider; next step is removing it
3. Card theming → one theme (already one)
4. Abandon status
5. Manual entry, only if Open Library coverage tested well

**Never cut:** the reflection prompts, the share card, the shelf.

## Before the Sept 10 polish pass

- Set `kSeedDummyData = false` in `lib/data/seed.dart` (or delete the file and its call in `main.dart`).
- Replace the default launcher icon.
- Rewrite onboarding copy in `lib/screens/onboarding_screen.dart`.
- Test the reflect flow on three real people with a book they actually finished.
