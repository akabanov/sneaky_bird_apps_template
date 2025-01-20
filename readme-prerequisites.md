# Prerequisites

These are configured once (not per project).

## Tools

[Install Flutter and Android Studio](https://docs.flutter.dev/get-started/install/linux/android),
if you haven't done it yet.

Make sure you have installed:

```shell
sudo apt-get install curl sed git ruby python3 python-is-python3 pipx uuidgen openjdk-17-jdk
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

## GitHub CLI

Install [GitHub CLI](https://github.com/cli/cli/blob/trunk/docs/install_linux.md).

Login and add permissions:

```shell
gh auth login
gh auth refresh -h github.com -s delete_repo -s admin:public_key
```

Create personal authentication key:

```shell
ssh-keygen -t ed25519 -P "" -C "$(gh api user --jq '.login')"
gh ssh-key add $HOME/.ssh/id_ed25519.pub --title 'Personal'
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

Create and download [App Store Connect API (team) key](https://appstoreconnect.apple.com/access/integrations/api)
for CI/CD integration. Use [App Manager](https://developer.apple.com/help/account/manage-your-team/roles/) role
(or Admin if feeling lucky). Take note of the Issuer ID and the Key ID.

Set env variables:

```shell
# ~/.bashrc
# codemagic cli
export APP_STORE_CONNECT_ISSUER_ID=
export APP_STORE_CONNECT_KEY_IDENTIFIER=
export APP_STORE_CONNECT_PRIVATE_KEY_PATH=
# fastlane cli
# export APP_STORE_CONNECT_API_KEY_PATH="$HOME/.secrets/apple/fastlane-api-key.json"
# echo '{
#   "key_id": "'"$APP_STORE_CONNECT_KEY_IDENTIFIER"'",
#   "issuer_id": "'"$APP_STORE_CONNECT_ISSUER_ID"'",
#   "key": "'$(cat "$APP_STORE_CONNECT_PRIVATE_KEY_PATH" | base64 -w0)'",
#   "is_key_content_base64": true,
#   "in_house": false
# }' > "$APP_STORE_CONNECT_API_KEY_PATH"
```

## Codemagic

Go to [your account setting](https://codemagic.io/teams) and enable **Slack** integration.

Save Codemagic API token to `$HOME/.secrets/codemagic/auth-token` and add env variable:

```shell
# ~/.bashrc
export CM_API_TOKEN_PATH="$HOME/.secrets/codemagic/auth-token"
```

Create and submit SSH authentication key for accessing GitHub private repositories from Codemagic:

```shell
mkdir -p $HOME/.secrets/codemagic
openssl rand -base64 16 > $HOME/.secrets/codemagic/github_id_ed25519.pass
ssh-keygen -t ed25519 -f $HOME/.secrets/codemagic/github_id_ed25519 \
    -P "$(cat $HOME/.secrets/codemagic/github_id_ed25519.pass)" \
    -C "$(gh api user --jq '.login')"
gh ssh-key add $HOME/.secrets/codemagic/github_id_ed25519.pub --title 'Codemagic'
```

You can find existing keys [here](https://github.com/settings/keys).

Create env variables:

```shell
# ~/.bashrc
export CM_GITHUB_SSH_KEY_PATH="$HOME/.secrets/codemagic/github_id_ed25519"
export CM_GITHUB_SSH_KEY_PASS="$(cat "$HOME/.secrets/codemagic/github_id_ed25519.pass")"
```

Install [Codemagic CLI suite](https://github.com/codemagic-ci-cd/cli-tools/tree/master):

```shell
pipx install codemagic-cli-tools
pipx ensurepath
```

## Sentry

Register with [Sentry](https://sentry.io/welcome/).

Create two auth tokens in [User Auth Tokens](https://sneakybird-apps.sentry.io/settings/account/api/auth-tokens/),
and save them in `$HOME/.secrets/sentry` directory:

- `api-token-projects`: Projects: Admin; Organisation: Read (used locally for initial project setup)
- `api-token-ci`: Release: Admin; Organisation: Read (used locally and on CI server)

Add variables:

```shell
# ~/.bashrc
export SENTRY_PROJECTS_ADMIN_TOKEN_PATH="$HOME/.secrets/sentry/api-token-projects"
export SENTRY_CI_TOKEN_PATH="$HOME/.secrets/sentry/api-token-ci"
export SENTRY_ORG="{organization-slug}"
export SENTRY_TEAM="{default-team-slug}"
```

[Install](https://docs.sentry.io/product/releases/setup/release-automation/) GitHub integration.

[//]: # (curl -sL https://sentry.io/get-cli/ | SENTRY_CLI_VERSION="2.40.0" INSTALL_DIR="$HOME/tools/sentry" sh)

## Google Cloud

[Create a billing account](https://console.cloud.google.com/billing) if you don't have a suitable one.

Place your fallback billing account to `GCLOUD_BILLING_ACCOUNT_ID` for the project setup script.

Then follow official `gcloud` CLI [installation instructions](https://cloud.google.com/sdk/docs/install-sdk#deb).

## Shorebird

Shorebird is a tool that can patch production apps without going through the app store review process.

[Create a dev account with Shorebird](https://console.shorebird.dev/login).

[Install Shorebird CLI](https://docs.shorebird.dev/).

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
