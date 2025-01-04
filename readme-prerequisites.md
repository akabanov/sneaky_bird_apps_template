# Prerequisites

These are configured once (not per project).

## Tools

[Install Flutter and Android Studio](https://docs.flutter.dev/get-started/install/linux/android),
if you haven't done it yet.

Make sure you have installed:

```shell
sudo apt-get install curl sed git ruby python3 python-is-python3 pipx openjdk-17-jdk
```

Make sure you have correctly set `JAVA_HOME`:

```shell
# ~/.bash_profile
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

## Codemagic CLI suite

[Codemagic](https://codemagic.io/start/) provides
a [CLI suite](https://github.com/codemagic-ci-cd/cli-tools/tree/master) to manage CI/CD tasks.

```shell
pipx install codemagic-cli-tools
pipx ensurepath
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
gem install fastlane
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

Enroll to [Apple Developer Program](https://developer.apple.com/programs/enroll/) membership, if you haven't yet.

Create and download [App Store Connect API (team) key](https://appstoreconnect.apple.com/access/integrations/api)
for CI/CD integration. Use [App Manager](https://developer.apple.com/help/account/manage-your-team/roles/) role
(or Admin if feeling lucky). Take note of the Issuer ID and the Key ID.

Set env variables:

```shell
export APP_STORE_CONNECT_ISSUER_ID=...
export APP_STORE_CONNECT_KEY_IDENTIFIER=...
export APP_STORE_CONNECT_PRIVATE_KEY=$(cat /path/to/your/AuthKey.p8)
```

## Codemagic

Go to [your account setting](https://codemagic.io/teams) and enable **Slack** integration.

Create an env variable with Codemagic API token:

```shell
export CM_API_TOKEN=...
```

Create secret files and register SSH key in GitHub account:

```shell
mkdir -p $HOME/.secrets/codemagic
uuidgen > $HOME/.secrets/codemagic/github_id_ed25519.pass
ssh-keygen -t ed25519 -f $HOME/.secrets/codemagic/github_id_ed25519 \
    -P $(cat $HOME/.secrets/codemagic/github_id_ed25519.pass) \
    -C "$(gh api user --jq '.login')"
gh ssh-key add $HOME/.secrets/codemagic/github_id_ed25519.pub --title 'Codemagic'
```

You can find the keys [here](https://github.com/settings/keys).

Create env variables:

```shell
export CM_GITHUB_SSH_KEY_BASE64=$(cat "$HOME/.secrets/codemagic/github_id_ed25519" | base64 -w0)
export CM_GITHUB_SSH_KEY_PASS=$(cat "$HOME/.secrets/codemagic/github_id_ed25519.pass")
```

## Google Cloud

[Create a billing account](https://console.cloud.google.com/billing) if you don't have a suitable one.

Place your fallback billing account to `GCLOUD_BILLING_ACCOUNT_ID` for the project setup script.

Then follow official `gcloud` CLI [installation instructions](https://cloud.google.com/sdk/docs/install-sdk#deb).

## Shorebird

Shorebird is a tool that enables over-the-air (OTA) code updates for Flutter apps,
allowing developers to patch their production apps without going through the app store review process.

[Create a dev account with Shorebird](https://console.shorebird.dev/login) if you haven't yet.

[Install Shorebird CLI](https://docs.shorebird.dev/).

## Shell aliases

Here are some aliases you may find useful.
Add them to your `~/.bashrc`:

```shell
alias ba='dart run build_runner build && git add -A .'
alias fa='flutter pub add '
alias ft='flutter test'
alias fit='flutter drive --driver=test_driver/integration_test.dart --target=integration_test/all_tests.dart'
alias frl='flutter run -d "linux"'
```

My personal:

```shell
alias frm='flutter run -d "moto g24"'
```
