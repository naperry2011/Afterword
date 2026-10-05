# Decision log

Dated. Append only. If a decision is reversed, add a new entry that says so.

## 2026-09-08 · Environment night

- **Progress logging is a single slider.** One `progress` integer (0–100) per reading session, no history. This pays for the shelf view that the design direction added on top of the locked scope. Fills the in-progress spine partially.
- **Bundle identifier is `com.nickperry.afterword`.**
- **Apple Developer enrollment is active.** The Sept 13 signed build is not blocked.
- **Android setup is skipped for now.** No AVD created tonight. An existing Pixel 7 AVD (`heartlink_pixel`, android-35) is on this machine for the daily build check when wanted.
- **Packages locked:** drift + drift_flutter, flutter_riverpod 3 (no codegen), go_router, http, cached_network_image, share_plus, path_provider, file_picker, build_runner 2.15 (2.16 conflicts with flutter_test's meta pin on Flutter 3.44), drift_dev, flutter_lints.
- **Fonts are bundled as variable TTFs** (Pixelify Sans, Nunito + italic) from google/fonts under OFL. No `google_fonts` package, no runtime fetch.
- **Generated drift code is committed** so a clean checkout builds without running codegen.
- **iOS deployment target is 15.0.**
- **Card output is 1080×1350** (540×675 logical at 2x), independent of device.
- **The `stopped` reflection also populates `abandonReason`** on the session so the field has a source without a second form.
- **A small `app_meta` key/value table** was added to the schema for flags (onboarding seen, seed applied). It is not for user data.

## 2026-09-13 · No physical iPhone

- **Repo moved to `~/dev/Afterword`.** iCloud Desktop & Documents sync re-stamped Finder metadata on `build/` and codesign rejected the Flutter framework. Any Xcode project under `~/Documents` on this Mac will fail the same way.
- **There is no physical iPhone available.** Device QA and the clean-device TestFlight install are replaced by: release-mode simulator runs on iPhone 17 Pro and iPhone 16e, and TestFlight external testers (the same three people testing the reflect prompts) as the first real-device coverage. Archive and upload happen from the Mac, which needs no device.
- **`watchSession` now joins books and reflections** so drift re-emits on any change. Watching the session row alone left the Card showing "No card yet" straight after reflecting.

## 2026-10-05 · Android is active, split by machine

- **Android is no longer deferred.** This reverses "Android setup is skipped for now" from 2026-09-08.
- **Each platform has its own machine.** Android builds on the Windows PC, which has more storage and power. iOS stays on the MacBook, because Xcode only runs on macOS. The Windows checkout lives under OneDrive; if sync interferes with Gradle builds, move it out of the synced tree.
- **Both platforms share one version.** `pubspec.yaml` `version:` drives both store builds. Each platform's progress is tracked in the "Machines and platform status" table in `CLAUDE.md`, updated after every build or store change.
- **The Windows checkout moved to `C:\dev\Afterword`.** Under `OneDrive\Documents`, `flutter pub get` failed every time: it could not delete `ios/Flutter/ephemeral/Packages/.packages` while OneDrive held it. The same commands pass from `C:\dev`. Keep Flutter repos on this PC out of OneDrive, and keep paths short: a deeply nested copy broke the generated SwiftPM paths on the 260-character Windows path limit.
- **Flutter is pinned to 3.44.2 on both machines,** the version the project was created with and the one `build_runner` 2.15 was pinned for. Upgrade both machines together.

## 2026-10-05 · Responsive layouts for tall screens

- **One sizing helper, `Fit` in `lib/theme/layout.dart`.** `heroScale` is usable height / 780 (a 16e), clamped 1.0 to 1.25. It scales hero elements only: onboarding shelf art, shelf spine height, the book cover, and the gaps around them. Type stays on the fixed `pix()`/`body()` scale. iPhones up to the 17 Pro get 1.0; the 17 Pro Max and tall Android phones get about 1.1.
- **Spine widths stay fixed per book id.** Only height follows the shelf, so the standing rule on stable spine geometry holds.
- **Outlines snap to whole device pixels (`PixelGrid`)** so 3px borders stay crisp at Android's 2.625 density. The share card's cover opts out, so the PNG is still identical on every device.
- **Onboarding sits above centre** (spacer flex 2 above, 3 below) instead of centred. **Reflect's answer field grows into spare height** (5 to 12 lines) instead of leaving a gap above Skip/Next.
- **System bars:** transparent with light icons on both platforms; Android launch and window backgrounds are the room colour instead of white.
- **The repo is now `dart format`ted** (Dart 3.12 tall style). It had never been formatted; this was a one-time pass, so later diffs stay small if the formatter is run on each change.
