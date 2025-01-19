# Versioning

This file documents versioning: concepts and strategy.

## Versions

Here's a good article about versioning on App and Play stores:
https://docs.codemagic.io/knowledge-codemagic/build-versioning/

TBD: What are conventions for git tag names?

### iOS

All builds for the same release of your app, will have the same **version number**.

#### Version number (CFBundleShortVersionString)

https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleshortversionstring

Is used to associate the build with the app and version record in App Store Connect.

_It's typically incremented each time you publish your app to the App Store.
This is the version that is visible on the "Version" section for the App Store page of your application._

This key is a **user-visible** string for the version of the bundle.

The required format is **three period-separated integers**

This key is used throughout the system to identify the version of the bundle.

The collection of all the builds submitted for a particular version
is referred to as the 'release train' for that version.

#### Build number (CFBundleVersion)

https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleversion

Uniquely identifies the build throughout the system.

It **does not overlap** with the version number.

_This is typically incremented on each iteration of internal release._

This key is a **machine-readable** string.

**One to three period-separated integers** (major.minor.maintenance).

You can also abbreviate the build version; missing integers in the format are interpreted as zeros (1 == 1.0.0).

You can include more integers but the system ignores them.

For **iOS**, build version number **can be reused** across different release version numbers while
for macOS, build version number **must be unique** across all release version numbers.

#### Submitting a build

You'll need to choose a **build** from those you've uploaded for a **version**.

You can **associate only one build** with an **app version**.

You can **change** the build **until you submit** the version to App Review.

### Android

Release and build versions are `versionName` and `versionCode` accordingly (found in `build.gradle`).

`versionName` is a text displayed to users and visible in Google Play. There are no restrictions for `versionName`.

`versionCode` is an internal version that must be between `1` and `2100000000`.

### Flutter

Version number in Flutter is in the `version` attribute of `pubspec.yaml`.

It may also have a build number (`+number` syntax: 1.0.0+36, where 36 is build number).

This can be overridden on the command line:

```shell
flutter build ipa --release \
    --build-name=1.0.0 \
    --build-number=36
```

Alternatively, by setting `FLUTTER_BUILD_NAME` and `FLUTTER_BUILD_NUMBER` env vars.

## Integration

### Sentry releases

Sentry release names are global per organization.
If you want the releases in different projects to be treated as separate entities,
make the **Sentry version name unique across the organization**.

The recommendation for mobile devices is to
use `package-name@version-number` or `package-name@version-number+build-number`.

**Release** version and **build** number map to Sentry `SENTRY_RELEASE` (`release`) and `SENTRY_DIST` (`dist`).

_Release name doesn't contain: newlines, tabs, /, or \\. Not a `'.'`, `'..'`, or `' '` (one space). 200 chars max._

Binding SDK with a release:

```dart
// or define SENTRY_RELEASE via Dart environment variable (--dart-define) if you are using Flutter Web.
// TBD: does the variable work for ios/android?
SentryFlutter.init((options) {
  ...
  options.release = 'my-project-name@2.3.12+12';
};
```

Ponder: `dist={ios|android}-{build number}-{shorebird patch}`
([getting the patch number](https://pub.dev/packages/shorebird_code_push))

Livecycle:

- `sentry-cli releases new`: creates _unreleased_ release. \
  Also, can be created automatically, for example upon uploading a source map

- Finalizing a release means that we populate a second timestamp on the release record \
  You can also choose to finalize the release when you've made the release live (enabled in the App store, etc.).

#### Sentry Flutter plugin

```shell
# install for project:
flutter pub add dev:sentry_dart_plugin

# run with Dart:
dart run sentry_dart_plugin

# run with Flutter:
flutter packages pub run sentry_dart_plugin
```

#### Commit integration

https://docs.sentry.io/cli/releases/#commit-integration

1. Configure repository for the project
2. Use `--auto` flag when running `sentry-cli` in git repo root dir.

### Shorebird

#### A patch vs a release?

Common strategies:

1. Push a patch immediately to update all existing users, while also simultaneously submitting a release 
to the stores so that new users to their product will get the latest code on first launch after a store install.

2. Use patching as a mechanism to ship changes on a high frequency (e.g. daily or weekly)
and only go through a full release process on a lower cadence (e.g. monthly).

3. Continue to only use releases for shipping code changes,
and only patch to fix critical bugs or make other emergency changes.

## Numbering strategies

### Opinion 01

Avoid "1.0" as a developer and as a user.

Start with "1.1" and keep the "build" the same as the "version" but with an extra .X at the end.

For the soon-to-be version 1.2: submit new development builds with Version number "1.2"
and Build numbers 1.2.1 and 1.2.2 all the way up to the final perfect 1.2.36
which you submit for approval with a Version number 1.2.

### Opinion 02

For other apps you might want to use simply a date-time value in ISO 8601 standard format style (`YYYYMMDDHHMM`).
For example, `201606070620`. That order of year-month-date-hour-minute renders an ever-increasing number,
always the same length due to padding zero, that when sorted alphabetically is also chronological.

_Alex: This doesn't work well with Google `versionCode` which can't be bigger than `2100000000`.
Can use `YEAR - 2020` though instead of the full year. Alternatively, the amount of minutes since some anchor._

### Opinion 03

https://spin.atomicobject.com/version-fastlane/

Maintain release version number in `VERSION` file

Load it with `increment_version_number`

```ruby
# iOS
increment_version_number(
  xcodeproj: project,
  version_number: File.read("../VERSION")
)

# android
increment_version_name(
  gradle_file_path: gradle_file_path,
  version_name: File.read("../VERSION")
)
```

Use `latest_testflight_build_number` and `google_play_track_version_codes` for build number

```ruby
# iOS
previous_build_number = latest_testflight_build_number(
  app_identifier: app_id,
  api_key: api_key,
)

current_build_number = previous_build_number + 1

increment_build_number(
  xcodeproj: project,
  build_number: current_build_number
)

# android
previous_build_number = google_play_track_version_codes(
  package_name: app_id,
  track: "internal",
  json_key: json_key_file_path,
)[0]

current_build_number = previous_build_number + 1

increment_version_code(
  gradle_file_path: gradle_file_path,
  version_code: current_build_number
)
```

[Tag](https://docs.fastlane.tools/actions/add_git_tag/) the build commit with `add_git_tag`

```ruby
add_git_tag(
  grouping: "builds",
  includes_lane: false,
  prefix: "ios | android",
  build_number: current_build_number,
  force: true,
)
```

Build numbers in App and Play store can diverge.

Relevant action: `last_git_tag(pattern: "release/v1.0/")`

## integration

**TBD**

Learn how shorebird and sentry manage release and build versions.

Learn what happens there if ios and android build versions clash, and learn how to avoid this if this is an issue:

- Should I add a suffix to the full version?
- Should I create separate projects for iOS and Android?

How do shorebird patch versions fit in all this (including Sentry)?

Am I overthinking and can just use full version (version + build number)?

How do I link Sentry releases with dsym files and git commits?

## Resources

Fix auto-versioning:
: https://stackoverflow.com/questions/54357468/how-to-set-build-and-version-number-of-flutter-app

Get app version at runtime:
: https://pub.dev/packages/package_info_plus
