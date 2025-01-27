# Prerequisites

These are configured once (not per project).

## Tools

[Install Flutter and Android Studio](https://docs.flutter.dev/get-started/install/linux/android),
if you haven't done it yet.

Make sure you have installed the following basic toolset:

```shell
sudo apt-get install curl sed jq yq git ruby python3 python-is-python3 pipx uuidgen openjdk-17-jdk
```

Make sure you have correctly set `JAVA_HOME`:

```shell
# ~/.bash_profile
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

## Fastlane

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

## GitHub

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

You can find existing keys [here](https://github.com/settings/keys).

Create a repository to store code signing keys for App Store applications and a password to protect the keys:

```shell
gh repo create fastlane_match_secrets --private
mkdir -p "$HOME/.secrets/fastlane"
openssl rand -base64 8 >> "$HOME/.secrets/fastlane/match_secrets_password"
```

**Note:** backup the password somewhere safe.

Store the SSH auth key path, repo SSH URL, and the code signing keys password in the env variables:

```shell
export MATCH_GIT_URL="git@github.com:{YOUR_NAMESPACE}/fastlane_match_secrets.git"
export CICD_GITHUB_SSH_KEY_PATH="$HOME/.secrets/github/cicd_id_ed25519"
export MATCH_PASSWORD_PATH="$HOME/.secrets/fastlane/match_secrets_password"
```

## Slack

Slack is used for CI/CD notifications.
[Create an account](https://slack.com/get-started) and install Slack application:

```shell
sudo snap install slack
```

Create `#cicd-all` public channel.

## Apple

Assuming [Apple Developer Program membership](https://developer.apple.com/programs/enroll/) is active.

Get your "Team ID" from [Apple Developer Portal](https://developer.apple.com/account#MembershipDetailsCard).

Get your Apple Connect (former iTunes Connect - itc) team ID from
[App Store Connect](https://appstoreconnect.apple.com/access/users).

Create and download [App Store Connect API (team) key](https://appstoreconnect.apple.com/access/integrations/api)
for CI/CD integration. Use [App Manager](https://developer.apple.com/help/account/manage-your-team/roles/) role
(or Admin if feeling lucky). Take note of the Issuer ID and the Key ID.

Save the key to `export APP_STORE_CONNECT_PRIVATE_KEY_PATH="$HOME/.secrets/apple/AuthKey_{YOUR_KEY_ID}.p8"`

Set env variables:

```shell
# ~/.bashrc
export APPLE_DEV_TEAM_ID=...
export APP_STORE_CONNECT_TEAM_ID=...
export APP_STORE_CONNECT_ISSUER_ID=...
export APP_STORE_CONNECT_KEY_IDENTIFIER=...
export APP_STORE_CONNECT_PRIVATE_KEY_PATH="$HOME/.secrets/apple/AuthKey_{YOUR_KEY_ID}.p8"
```

## Google

Create a [Google Cloud billing account](https://console.cloud.google.com/billing) if you don't have a suitable one.

Install `gcloud` CLI [installation instructions](https://cloud.google.com/sdk/docs/install-sdk#deb).

Use [this instruction](https://docs.fastlane.tools/getting-started/android/setup/#collect-your-google-credentials)
to create a service account and integrate it with Play Console (do nothing more from that instruction).

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
  -keypass $(cat "$HOME/.secrets/google/play-upload-keystore-pass") \
```

Add variables:

```shell
# ~/.bashrc
export GCLOUD_BILLING_ACCOUNT_ID=...
export SUPPLY_JSON_KEY="$HOME/.secrets/google/{YOUR_JSON_FILE_NAME}"
export PLAY_CONSOLE_UPLOAD_KEYSTORE="$HOME/.secrets/google/play-upload-keystore.jks"
export PLAY_CONSOLE_UPLOAD_KEYSTORE_PASS="$HOME/.secrets/google/play-upload-keystore-pass"
```

## Codemagic

Go to [your account setting](https://codemagic.io/teams) and enable **Slack** integration.

Save Codemagic API token to `$HOME/.secrets/codemagic/auth-token` file and add env variable:

```shell
# ~/.bashrc
export CM_API_TOKEN_PATH="$HOME/.secrets/codemagic/auth-token"
```

Install [Codemagic CLI suite](https://github.com/codemagic-ci-cd/cli-tools/tree/master):

```shell
pipx install codemagic-cli-tools
pipx ensurepath
```

## Sentry

Register with [Sentry](https://sentry.io/welcome/).

Create two auth tokens in [User Auth Tokens](https://sentry.io/settings/account/api/auth-tokens/),
and save them in `$HOME/.secrets/sentry` directory:

- `api-token-projects` file; roles: _Projects: Admin; Organisation: Read (used locally for initial project setup)_
- `api-token-ci` file; roles: _Release: Admin; Organisation: Read (used locally and on CI server)_

Add variables:

```shell
# ~/.bashrc
export SENTRY_PROJECTS_ADMIN_TOKEN_PATH="$HOME/.secrets/sentry/api-token-projects"
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

## Shorebird

Shorebird is a tool that can patch production apps without going through the app store review process.

[Create a dev account with Shorebird](https://console.shorebird.dev/login).

[Install Shorebird CLI](https://docs.shorebird.dev/).

[Create](https://docs.shorebird.dev/ci/codemagic/) CI auth token:

```shell
shorebird login:ci
```

Save the token to your `$HOME/.secrets/shorebird/auth-token` and add an env variable:

```shell
export SHOREBIRD_TOKEN_PATH="$HOME/.secrets/shorebird/auth-token"
```

## Shell aliases

Here are some aliases you may find useful.

```shell
# ~/.bashrc
alias ba='dart run build_runner build && git add -A .'
alias fa='flutter pub add '
alias ft='flutter test -x screenshots '
alias fscreens='flutter test --update-goldens --tags=screenshots'
alias fit='flutter drive --driver=test_driver/integration_test.dart --target=integration_test/all_tests.dart'
alias frl='flutter run -d "linux"'
```

Personal:

```shell
# ~/.bashrc
alias frm='flutter run -d "moto g24"'
```
