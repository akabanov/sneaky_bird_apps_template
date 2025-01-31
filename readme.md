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
- Run the `setup` script and follow the prompts

The newly initialised project will have Fastlane targets
to publish test builds both to App Store Connect and Google Play Console.

See the Roadmap section below for what's missing.

## Resources

Local reference files:

- [Prerequisites: tools, accounts and environment setup](readme-prerequisites.md)
- [Project setup](readme-setup.md)
- [Useful Flutter packages](readme-packages.md)
- [Frequently used shell snippets](readme-shell-snippets.md)
- [Graphic design guidelines and resources](readme-graphic-design.md)

External links:

- [Project console in GCloud](https://console.cloud.google.com/welcome/new?project=project-id-placeholder).

## Roadmap

- Implement master app icon scale down (is there a Flutter package for that?).
Meanwhile, use [Graphic design guidelines and resources](readme-graphic-design.md)

- Implement lanes to launch tests on Test Lab.
Meanwhile, use [Frequently used shell snippets](readme-shell-snippets.md)

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

- See if any of these Fastlane plugins is useful:
  - badge: https://github.com/HazAT/fastlane-plugin-badge
  - appicon (apple only): https://github.com/fastlane-community/fastlane-plugin-appicon
  - changelog: https://github.com/pajapro/fastlane-plugin-changelog

- See how an automatic translation service can be added (or built via an AI API)
