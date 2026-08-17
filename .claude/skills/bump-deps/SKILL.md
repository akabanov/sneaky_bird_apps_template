---
name: bump-deps
description: Update this template's dependencies — Dart packages, native build config, Ruby/fastlane, CI tooling — and verify the result still builds. Use when asked to bump, update, or refresh dependencies, or to check what's outdated.
---

# Dependency bump

One pass, one commit. Work through the phases in order and **stop to talk to the
user** the moment something breaks, resolves oddly, or needs a judgement call.
Do not silently drop a package, relax a constraint, or "work around" a failure.

## Hard constraints

These are properties of this project, not preferences. Violating them produces a
template that cannot be built by its owner.

1. **Flutter is capped at 3.38.x.** `codemagic.yaml` pins `flutter: 3.38.8`.
   The cap exists because Flutter 3.41 makes UIScene the default and 3.44 makes
   Swift Package Manager the default; both rewrite `ios/Runner.xcodeproj`, and
   the only Mac available for maintaining that project is a 2014 Mac Mini on an
   old Xcode. **Never raise the pin** without asking. If a package now requires
   a newer Flutter, that package does not get upgraded — report it and move on.
2. **Corollary — the Dart floor.** Flutter 3.38 ships Dart 3.10. No resolved
   package may require Dart > 3.10. This is easy to violate accidentally,
   because the local SDK is newer than the CI pin (see "Local SDK divergence").
3. **Never type a version number from memory.** Every version comes from a
   command or an API. A plausible-looking hand-written constraint that happens
   to resolve is the most likely way to break this repo.

## Local SDK divergence

The local Flutter SDK is usually *newer* than the 3.38.x pin, so `pub get`
succeeding locally does **not** prove CI will resolve. After any resolution
change, verify the floors explicitly (Phase 2, step 3). If `fvm` is available,
prefer resolving under a real 3.38.x SDK instead.

## Phase 1 — Survey (read-only, no edits)

Gather facts from commands, not recall:

```bash
flutter pub outdated --json          # Dart packages: source of truth
(cd ios && bundle outdated)          # fastlane and friends
(cd android && bundle outdated)
gh api repos/shorebirdtech/shorebird/releases/latest --jq .tag_name
gh api repos/invertase/flutterfire_cli/releases/latest --jq .tag_name
```

Also read, and note current values:

- `codemagic.yaml` — `flutter:` pin, image, `dart pub global activate flutterfire_cli`
- `android/settings.gradle.kts` — AGP, Kotlin
- `android/gradle/wrapper/gradle-wrapper.properties` — Gradle
- `android/app/build.gradle.kts` — `targetSdk` (currently hard-coded), `minSdk`
- `ios/Podfile` — `platform :ios` (currently 15.0)
- `ios/OneSignalNotificationServiceExtension` — the NSE pod version must track
  `onesignal_flutter`'s native SDK, or push silently breaks on iOS

Present the survey to the user before changing anything. Flag anything blocked
by the Flutter cap separately from what's freely upgradable.

## Phase 2 — Upgrade

1. **Try everything at once first.** Pub's solver handles the co-dependency
   case better than a hand-rolled sequence — if package A pins an old B, an
   all-at-once run finds the combination that works, where one-at-a-time hits a
   false conflict:

   ```bash
   flutter pub upgrade --major-versions
   ```

   If it resolves, keep it. If it fails or holds packages back, read the
   solver's explanation, then retry excluding the specific blocker(s) rather
   than falling back to full serialisation.

2. `flutter pub get` — regenerates `.flutter-plugins-dependencies` and rewrites
   the plugin registrants.

3. **Verify the SDK floors** of everything now in `pubspec.lock`, against
   Flutter 3.38 / Dart 3.10. Read `environment:` from each locked package's
   pubspec in `~/.pub-cache/hosted/pub.dev/<name>-<version>/pubspec.yaml`.
   Any package above the floor must be reverted and reported — do not raise
   the pin to accommodate it.

4. Non-Dart surfaces, each a deliberate decision, not an automatic bump:
   `bundle update` in `ios/` and `android/`; AGP/Kotlin/Gradle; `targetSdk`
   per the Play requirements page; flutterfire_cli and shorebird in
   `codemagic.yaml`.

## Phase 3 — What does *not* auto-heal

Generated plugin registrants regenerate themselves from the lockfile and need no
attention. Everything below is native config that a package bump can *require*
but never updates, and that `flutter analyze` will not catch:

- **`minSdk` / `compileSdk`** — a plugin raising its floor breaks the Gradle build
- **`platform :ios` in `ios/Podfile`** + the Xcode deployment target — Firebase
  raises this regularly, and raising it here means editing the Xcode project
- **AGP / Kotlin / Gradle wrapper** versions demanded by a newer plugin
- **New permissions or entitlements** (`Info.plist`, `AndroidManifest.xml`) —
  these fail at *runtime*, not build time; the nastiest class, so check the
  changelogs of any permission-adjacent package (`permission_handler`,
  `onesignal_flutter`) rather than trusting a green build
- **`Podfile.lock`** — regenerated by `pod install --repo-update`, not `pub get`

Note which registrant diffs appear: `linux/`, `macos/`, `windows/` are tracked
and will show in `git status`; **`android/` and `ios/` registrants are
gitignored**, so an Android/iOS-only plugin change produces zero visible diff.
Never use `git status` as evidence that nothing changed.

## Phase 4 — Verify

```bash
flutter analyze
flutter test -x screenshots
flutter build apk --flavor dev -t lib/main_dev.dart --dart-define-from-file=.env.runtime.dev
```

Analyze and unit tests do not exercise the native side. The Android build is the
cheapest proof that Gradle, minSdk and the Android registrant survived.

**iOS cannot be verified locally.** It builds on Codemagic:

```bash
./codemagic.sh ios-beta dev true
```

That costs build minutes and takes ~15 minutes, so **ask the user** before
running it, and always run it before considering an upgrade that touched
Firebase, OneSignal, Sentry or `permission_handler` finished.

In a fresh clone of this template `lib/firebase_options_*.dart` are placeholders
that throw at runtime — a *build* proves compilation, never launch the app to
verify. That is expected, not a regression.

## Phase 5 — Land it

- One commit for the whole pass, message summarising what moved and what was
  held back by the cap.
- Add a `Changed` entry under `## [Unreleased]` in `CHANGELOG.md` (Keep a
  Changelog format).
- Report to the user: upgraded / blocked-by-cap / needs-native-work / not
  verified on iOS.

## Watch list

Surface these when relevant — they are dated, external, and will eventually
force the Flutter cap to be reconsidered:

- **Firebase stops publishing to CocoaPods in October 2026**; the CocoaPods
  registry becomes read-only on **2 December 2026**. FlutterFire is affected.
  After that, staying on CocoaPods means freezing Firebase at its last
  CocoaPods release — which is compatible with the 3.38.x cap, but permanent.
- SPM support in the current dependency set: `firebase_core` yes,
  `onesignal_flutter` yes (5.5.0+, opt-in), `permission_handler` yes.
  None of it activates below Flutter 3.44, so it is inert under the cap.

If a bump is blocked by the cap and the blockage is starting to matter, say so
plainly and let the user decide. Do not route around it.
