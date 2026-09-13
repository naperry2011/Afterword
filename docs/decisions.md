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
