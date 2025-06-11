# New Flutter project template

This is a template for the upcoming https://sneakybird.app applications.

## Audience

I'm crafting this project for personal use with two goals in mind:

- To be able to kick-start new Flutter projects with all the required integrations and boilerplate ready out of the box
- Learn the production and maintenance process end-to-end

The snippets and the setup script are designed for Ubuntu 24.04.
While some of these many may work in other environments, others may require tweaking.

I have an old Mac Mini, so I mostly use Codemagic to run iOS-specific Fastlane builds.
So the scripts may fail if run locally.

## Licence

This template is available [UNLICENSED](LICENSE).

## Status

The template is ready to use:

- Make sure you have all the [prerequisites](#Prerequisites)
- Use this template to create your app GitHub repository
- Run the `setup` script and follow the prompts \
_allow up to an hour: you'll need to manually add a Play Store App and upload the initial build_

The newly initialised project will have Fastlane targets
to publish test builds both to App Store Connect and Google Play Console.

See the Roadmap section below for what's to come.

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

## Application screen label

Application screen label (the text under the app icon) is set in `APP_LABEL_SCREEN` in the project's `.env` file.
Just update this value and run:

```shell
pushd ios
bundle exec fastlane ios update_app_screen_label
popd
pushd android
bundle exec fastlane android update_app_screen_label
popd
```

## Application icon

Save the original base icon as `assets/dev/app_icon.prod.png`,
tweak `scripts/app_icon_flavours.dart` to your liking, and run:

```shell
echo create flavoured icons
dart run scripts/app_icon_flavours.dart

echo generate smaller icons from the original one
dart run flutter_launcher_icons

echo revert the unnecessary changes made by 'flutter_launcher_icons' plugin
sed -i 's/ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = AppIcon;/ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;/' ios/Runner.xcodeproj/project.pbxproj

echo make a copy for the app page assets in Google Store 
cp -r web/icons/Icon-512.png assets/dev/android/en-US/images/icon.png
```

## Permissions, capabilities and entitlements

The checklist for adding a new permission:

- Update Xcode project
- Uncomment the permission in [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml)
- Enable corresponding preprocessor in [`ios/Podfile`'s](ios/Podfile) `GCC_PREPROCESSOR_DEFINITIONS`

_If you don't have a Mac, also do manually (good luck with that):_

- Enable the capability at the [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list)
- Update [`ios/Runner/Info.plist`](ios/Runner/Info.plist) and corresponding language files
  (e.g. [`ios/Runner/ru.lproj/InfoPlist.strings`](ios/Runner/ru.lproj/InfoPlist.strings) for Russian language)
  ([Specification](https://developer.apple.com/documentation/bundleresources/information-property-list))
- Update [`ios/Runner/Runner.entitlements`](ios/Runner/Runner.entitlements)
  ([Specification](https://developer.apple.com/documentation/bundleresources/entitlements))

## Resources

Local reference files:

- [Useful Flutter packages](readme-packages.md)
- [Graphic design guidelines and resources](readme-graphics-design.md)

## Prerequisites

These are configured once (not per project).

**Note:** This instruction uses a convention of storing the secrets in `.secrets` directory in user's `$HOME`.
The files layout is as follows:

- `~/.secrets/{service-or-product}/{secret-file}` for generic secrets (such as access tokens and passwords)
- `~/.secrets/app/{app_name}/{secret-file}` for application secrets (such as push certificates)

All env variables from this document (except `PATH` and related) are defined in `~/.secrets/.bashrc_creds`.
Call it from your `.bashrc`. For example `source $HOME/.secrets/.bashrc_creds`.

Create the directory, an empty env variables file, the script for backing up secrets, and a password for backups:

```shell
mkdir -p ~/.secrets
pushd ~/.secrets

# Create an empty file for the env variables
[ ! -f ".bashrc_creds" ] && touch ".bashrc_creds"

# Create password for secrets backups
[ ! -f "backup-pass" ] && openssl rand -base64 8 > "backup-pass"

# Create a backup script
echo 'pushd ~/.secrets; zip -r -P "$(<backup-pass)" ~/.backups/secrets-$(date +"%Y%m%d%H%M%S").zip ./; popd' > backup.sh
chmod +x backup.sh
popd 
```

Note the password from `backup-pass` somewhere safe and use `backup.sh` to back up
your `~/.secrets` directory content to `~/.backups` directory as a password-protected zip file.

It is recommended to create a backup every time you add or update a secret.
Rehearse the restoration at least once.

**Do not change proposed variable names.**
Some tools, such as Fastlane and Sentry CLI, implicitly rely on some of them.

### Tools

[Install Flutter and Android Studio](https://docs.flutter.dev/get-started/install/linux/android),
if you haven't done it yet.

Make sure you have installed the following basic toolset:

```shell
sudo apt-get install curl sed jq yq git ruby python3 python-is-python3 pipx uuidgen openjdk-17-jdk
```

Make sure you have correctly set `JAVA_HOME` (the path may differ, make sure you have correct one):

```shell
# ~/.bash_profile
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

### Fastlane

Fastlane is a command-line tool written in Ruby that automates common tasks in iOS and Android development workflows,
such as building, testing, code signing, and deploying apps to the App Store and Play Store.

Make sure your Ruby gems live in your local user space to avoid unexpected file permission issues:

```shell
# ~/.bash_profile
export GEM_HOME="$HOME/.gems"
export PATH="$HOME/.gems/bin:$PATH"
```

Then install Fastlane

```shell
gem install bundler fastlane
```

### GitHub

Install [GitHub CLI](https://github.com/cli/cli/blob/trunk/docs/install_linux.md).

Login and add permissions:

```shell
gh auth login
gh auth refresh -h github.com -s delete_repo -s admin:public_key
```

Create your personal and CI/CD authentication keys:

```shell

# Personal
ssh-keygen -t ed25519 -P "" -C "$(gh api user --jq '.login')"
gh ssh-key add $HOME/.ssh/id_ed25519.pub --title 'Personal'

# CI/CD
mkdir -p $HOME/.secrets/github
ssh-keygen -t ed25519 -P "" -f $HOME/.secrets/github/cicd_id_ed25519 -C "$(gh api user --jq '.login')"
gh ssh-key add $HOME/.secrets/github/cicd_id_ed25519.pub --title 'CICD'
```

You can check your existing keys [here](https://github.com/settings/keys).

Create a repository to store code signing keys for App Store applications and a password to protect the keys:

```shell
gh repo create fastlane_match_secrets --private
mkdir -p "$HOME/.secrets/fastlane"
openssl rand -base64 8 >> "$HOME/.secrets/fastlane/match_secrets_password"
```

**Note:** backup the password somewhere safe.

Store the SSH auth key path, repo SSH URL, and the code signing keys password in the env variables:

```shell
# ~/.secrets/.bashrc_creds
export MATCH_GIT_URL="git@github.com:{YOUR_NAMESPACE}/fastlane_match_secrets.git"
export CICD_GITHUB_SSH_KEY_PATH="$HOME/.secrets/github/cicd_id_ed25519"
export MATCH_PASSWORD_PATH="$HOME/.secrets/fastlane/match_secrets_password"
```

### Slack

Slack is used to send build status notifications from Codemagic.

[Create an account](https://slack.com/get-started) and install Slack application:

```shell
sudo snap install slack
```

Create `#cicd-all` public channel.

### Apple

Assuming [Apple Developer Program membership](https://developer.apple.com/programs/enroll/) is active.

Get your "Team ID" from [Apple Developer Portal](https://developer.apple.com/account#MembershipDetailsCard).

Get your App Store Connect (former iTunes Connect - itc) team ID from
[App Store Connect](https://appstoreconnect.apple.com/access/users).

Create and download [App Store Connect API (team) key](https://appstoreconnect.apple.com/access/integrations/api)
for CI/CD integration. Use [App Manager](https://developer.apple.com/help/account/manage-your-team/roles/) role
(or Admin if feeling lucky). Take note of the Issuer ID and the Key ID.

Store the key as `$HOME/.secrets/apple/AuthKey_{YOUR_KEY_ID}.p8`

Some fastlane actions still require username/password authentication.
Save your iTunes password to `$HOME/.secrets/apple/itunes-pass` (in one line).

Set env variables:

```shell
# ~/.secrets/.bashrc_creds
export APPLE_DEV_TEAM_ID=...
export APP_STORE_CONNECT_TEAM_ID=...
export APP_STORE_CONNECT_ISSUER_ID=...
export APP_STORE_CONNECT_KEY_IDENTIFIER=...
export APP_STORE_CONNECT_PRIVATE_KEY_PATH="$HOME/.secrets/apple/AuthKey_${APP_STORE_CONNECT_KEY_IDENTIFIER}.p8"
# Your iTunes Id
export ITUNES_ID=...
export ITUNES_PASSWORD_PATH="$HOME/.secrets/apple/itunes-pass"
# This should be your full name if you are an individual developer
export APP_STORE_COMPANY_NAME=...
```

### Google

Make sure you have a suitable [Google Cloud billing account](https://console.cloud.google.com/billing).

[Install](https://cloud.google.com/sdk/docs/install-sdk#deb) `gcloud` CLI.

[Install](https://firebase.google.com/docs/cli) `firebase` CLI.

Install `flutterfire` tool:

```shell
dart pub global activate flutterfire_cli
```

If the Pub Bin is not on your PATH (you'll see the prompt after the `flutterfire` activation), fix that.

Create a Google Cloud service account and give it access to your Google Play Console
(use [this instruction](https://docs.fastlane.tools/getting-started/android/setup/#collect-your-google-credentials)).

_You can use your general administration Google Cloud project for the service account (not specific to the app)._

Save your JSON access key to `$HOME/.secrets/google/{YOUR_JSON_FILE_NAME}`.

Generate code signing key pair for apps uploads to Play Console:

```shell

mkdir -p "$HOME/.secrets/google"

openssl rand -base64 8 >> "$HOME/.secrets/google/play-upload-keystore-pass"

keytool -genkeypair \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload \
  -keystore "$HOME/.secrets/google/play-upload-keystore.jks" \
  -storepass $(cat "$HOME/.secrets/google/play-upload-keystore-pass") \
  -keypass $(cat "$HOME/.secrets/google/play-upload-keystore-pass")
```

Add env variables:

```shell
# ~/.secrets/.bashrc_creds
export GCLOUD_BILLING_ACCOUNT_ID=...
export SUPPLY_JSON_KEY="$HOME/.secrets/google/{YOUR_JSON_FILE_NAME}"
export PLAY_CONSOLE_UPLOAD_KEYSTORE="$HOME/.secrets/google/play-upload-keystore.jks"
export PLAY_CONSOLE_UPLOAD_KEYSTORE_PASS="$HOME/.secrets/google/play-upload-keystore-pass"
```

### OneSignal

[Register](https://onesignal.com/pricing) with OneSignal.

Do **not** create an app - the template setup script will do this for you.

Open you organisation in the [organisation dashboard](https://dashboard.onesignal.com/organizations?page=1), 
and copy the org ID from the URL (must be something like `a123456f-42cd-3e14-a360-123ab456cdef`).

Go to "Keys & IDs", create an API Key and store it in `$HOME/.secrets/onesignal/api-token` file.

Add env variables:

```shell
# ~/.secrets/.bashrc_creds
export ONESIGNAL_ORG_ID=...
export ONESIGNAL_API_KEY_PATH="$HOME/.secrets/onesignal/api-token"
```

### Codemagic

Go to [your account setting](https://codemagic.io/teams) and enable **Slack** integration.

Save Codemagic API token to `$HOME/.secrets/codemagic/auth-token` file and add env variable:

```shell
# ~/.secrets/.bashrc_creds
export CM_API_TOKEN_PATH="$HOME/.secrets/codemagic/auth-token"
```

Install [Codemagic CLI suite](https://github.com/codemagic-ci-cd/cli-tools/tree/master):

```shell
pipx install codemagic-cli-tools
pipx ensurepath
```

### Sentry

Register with [Sentry](https://sentry.io/welcome/).

Create two auth tokens in [User Auth Tokens](https://sentry.io/settings/account/api/auth-tokens/),
and save them in `$HOME/.secrets/sentry` directory:

- `api-token-dev` file; roles: _Projects: Admin; Organisation: Read (used locally for initial project setup)_
- `api-token-ci` file; roles: _Release: Admin; Organisation: Read (used locally and on CI server)_

Add variables:

```shell
# ~/.secrets/.bashrc_creds
export SENTRY_PROJECTS_ADMIN_TOKEN_PATH="$HOME/.secrets/sentry/api-token-dev"
export SENTRY_CI_TOKEN_PATH="$HOME/.secrets/sentry/api-token-ci"
export SENTRY_ORG="{organization-slug}"
export SENTRY_TEAM="{default-team-slug}"
```

[Install](https://docs.sentry.io/product/releases/setup/release-automation/) GitHub integration.

Install Sentry command line tool:

```shell
curl -sL https://sentry.io/get-cli/ | SENTRY_CLI_VERSION="2.40.0" INSTALL_DIR="$HOME/tools/sentry" sh
```

Add `$HOME/tools/sentry` to your `$PATH`.

### Shorebird

Shorebird is a service that allows patching production apps without going through the app store review process.

[Create a dev account with Shorebird](https://console.shorebird.dev/login).

[Install Shorebird CLI](https://docs.shorebird.dev/).

[Create](https://docs.shorebird.dev/ci/codemagic/) CI auth token:

```shell
shorebird login:ci
```

Save the token to your `$HOME/.secrets/shorebird/auth-token` and add an env variable:

```shell
# ~/.secrets/.bashrc_creds
export SHOREBIRD_TOKEN_PATH="$HOME/.secrets/shorebird/auth-token"
```

### Miscellaneous

Export your contact details for submission to App and Play store.
Also export the timezone for your build number timestamps.

```shell
# ~/.secrets/.bashrc_creds
export DEV_FIRST_NAME=...
export DEV_LAST_NAME=...
export DEV_PHONE=...
export DEV_EMAIL=...
export DEV_WEBSITE=...
export DEV_FULL_NAME=...
export DEV_ADDRESS_LINE_1=...
export DEV_ADDRESS_LINE_2=...
export DEV_CITY=...
export DEV_STATE=...
export DEV_COUNTRY=...
export DEV_ZIP=...

# Use the timezone string which is compatible with the `date` command
export TZ="Pacific/Auckland"
```

_That's it. Now you're ready to use the template to set up a project._

## Roadmap

- Finalize flavors support

- Add scaffolding:
  - basic 'lib' folder structure
  - force update plugin
  - main menu
  - feedback form
  - settings screen (a couple of fake settings paired with the local storage)
  - 'about' screen (product name and version, licensing information)

- Add integrations:
  - OneSignal (Firebase configuration: set up and generate/distribute certificates)
  - Firebase Remote config

- Add metadata files for Android (`fastlane supply init` currently fails)

- Screenshots generation framework:
  - Move from discontinued `golden_toolkit`
    - https://github.com/flutter/flutter/blob/master/docs/contributing/testing/Writing-a-golden-file-test-for-package-flutter.md or
    - https://pub.dev/packages/alchemist
  - Implement proper fonts loading (maybe it'll fix itself in Alchemist)
  - Implement device frames in screenshot generator

- [Fix obsolete Java warning](https://stackoverflow.com/questions/79102777/how-to-resolve-source-value-8-is-obsolete-warning-in-android-studio)

- Self-checkin service for beta testers, for both Android and iOS, 
  like [Boarding](https://github.com/fastlane/boarding),
  but more [stable](https://github.com/fastlane/boarding/issues)

- See how an automatic translation service can be added (or built via an AI API)
