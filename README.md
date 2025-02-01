# New Flutter project template

This is a template for the upcoming https://sneakybird.app applications.

## Audience

I'm crafting this project for personal use with two objectives in mind:

- To be able to kick-start new Flutter projects with all the required integrations and boilerplate ready out of the box
- Learn the production and maintenance process end-to-end

The snippets and the setup script are designed for Ubuntu 24.04.
While some of these many may work in other environments, others may require tweaking.

I don't have a Mac, so the iOS building and publishing runs on Codemagic.
I have configured Fastlane to run both on Codemagic and locally, but haven't tested the latter.

## Licence

This template is available [UNLICENSED](LICENSE).

## Status

The template is ready to use:

- Make sure you have all the [prerequisites](readme-prerequisites.md)
- Use this template to create your repo
- Run the `setup` script and follow the prompts \
_allow up to an hour: you'll need to manually add a Play Store App and upload the initial build_

The newly initialised project will have Fastlane targets
to publish test builds both to App Store Connect and Google Play Console.

See the Roadmap section below for what's missing.

## Quick actions

Release to Internal Google Play Console track:

```shell
bundle exec fastlane android internal
```

Release to Apple Test Flight (on Codemagic):

```shell
./ci.sh ios-beta
```

Quick release (no tests, no Shorebird) to Apple Test Flight (on Codemagic):

```shell
./ci.sh ios-beta true
```

Build Android app locally and submit to Test Lab to run integration tests:

```shell
pushd android
bundle exec fastlane android test_lab
popd
```

Set current project for `gcloud` tool:

```shell
gcloud config set project project-id-placeholder
```

Backup the source code:

```shell
mkdir -p ~/.backups
zip -r ~/.backups/$(basename "$PWD")-$(date +"%Y%m%d%H%M%S").zip ./
```

## Application icon

In order to change the app launch icon, create a master png icon, 1024 x 1024 px,
save it as `assets/dev/master_app_icon.png`, and run:

```shell

dart run flutter_launcher_icons
cp -r web/icons/Icon-512.png android/fastlane/metadata/android/en-US/images/icon.png
# Reverts AppIcon back to wider-scoped YES
sed -i 's/ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = AppIcon;/ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;/' ios/Runner.xcodeproj/project.pbxproj
```

## Resources

Local reference files:

- [Prerequisites: tools, accounts and environment setup](readme-prerequisites.md)
- [Useful Flutter packages](readme-packages.md)
- [Graphic design guidelines and resources](readme-graphics-design.md)

External links:

- [Project console in GCloud](https://console.cloud.google.com/welcome/new?project=project-id-placeholder).

## Roadmap

- Check if the App display name substitution works for Android (uncomment `update_app_label` in the `Fastfile` first)
 
- Prerequisites document:
  - Move to this page
  - Formalise secrets management
  - Add a template with all relevant environment variables

- Document:
  - Fastlane targets
  - App display name update
  - Adding permissions, capabilities and entitlements

- Add flavours setup (only after I do a real project that uses them)
  - Check if [badge](https://github.com/HazAT/fastlane-plugin-badge) plugin is useful

- Add integrations:
  - OneSignal (push notifications): setting up and certs generation/distribution
  - Firebase Remote config

- Add metadata files for Android (now that I only have an 'internal' build in Play Console, `fastlane supply init` just fails)

- Screenshots generation framework:
  - Implement device frames in screenshot generator
  - Improve working with fonts
  - Move from discontinued `golden_toolkit`
    - https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Writing-a-golden-file-test-for-package-flutter.md or
    - https://pub.dev/packages/alchemist

- [Fix obsolete Java warning](https://stackoverflow.com/questions/79102777/how-to-resolve-source-value-8-is-obsolete-warning-in-android-studio)

- Self-checkin service for beta testers, for both Android and iOS, 
  like [Boarding](https://github.com/fastlane/boarding),
  but more [stable](https://github.com/fastlane/boarding/issues)

- See how an automatic translation service can be added (or built via an AI API)
