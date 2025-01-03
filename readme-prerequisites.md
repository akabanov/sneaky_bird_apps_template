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
a [CLI suite](https://github.com/codemagic-ci-cd/cli-tools/tree/master)
they use to manage many common CI/CD tasks.

Some of them are used in project scripts.

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

In order for `nuke` script to work, the CLI must be authorised to `delete_repo`.

## Slack

Slack is a real-time messaging platform that, among other things,
integrates with CI/CD tools (Codemagic, Fastlane) to provide instant notifications
about app's build status, test results, and deployments.

Free tier provides message retention for 90 days and allows integration with up to 10 applications,
which is suitable for the purpose CI/CD notifications.

[Create a Slack account](https://slack.com/get-started).

Install local Slack app (and maybe mobile app as well):

```shell
sudo snap install slack
```

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

### Integrations

Make sure you have "Codemagic CI/CD" app in your [GitHub Applications](https://github.com/settings/installations).

Go to [your account setting](https://codemagic.io/teams) and set up
**Slack** and **(Apple) Developer Portal** integrations.

**Important:** name the Apple integration key `CICD`, this name is used in `codemagic.yaml`.
Note, that Chrome AdBlock plugin may interfere with the key upload form.

Create an env variable with your Codemagic API key:

```shell
export CM_API_TOKEN=...
```

### Code signing - iOS

Generate iOS code signing certificate (same page, "codemagic.yaml settings -> code signing identities").

Most teams working with CI/CD only need the **Distribution** certificate
for their iOS app builds. This applies to both internal and external TestFlight testing.
You'd only need a Development certificate if you have a specific requirement
for installing builds directly on devices outside of TestFlight (like through direct download
or third-party distribution platforms).

Note that TestFlight functions as your delivery mechanism regardless of whether you're
using internal testers (members of your App Store Connect team) or external beta testing groups.

Name it `distribution_certificate` in case you'd need advanced signing configuration later.

Note the reference name, password, and download the certificate.

You can find the generated certificates at your Apple Dev Account
[Certificates page](https://developer.apple.com/account/resources/certificates/list).

### Code signing - Android

**TODO**

## Git SSH authentication key

Generate an SSH key pair in your terminal:

```bash
# Use the email associated with your GitHub account
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Press Enter to accept the default location, usually `~/.ssh/id_ed25519`.
A passphrase is optional but recommended for security.

View your public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the entire output and paste it into a [new GitHub SSH auth key](https://github.com/settings/ssh/new).

While you still remember the passphrase:

```shell
ssh -T git@github.com
```

Create new env variables for integration with Codemagic:

```shell
export GITHUB_SSH_KEY_BASE64=$(cat "$HOME/.ssh/id_ed25519.pub" | base64 -w0)
export GITHUB_SSH_KEY_PASS=...
```

## Google Cloud

Integration with Google Cloud is needed if you are going to use any of their services,
for example, Firebase Test Lab.

[Create a billing account](https://console.cloud.google.com/billing) if you don't have a suitable one.

Place your billing account to `GCLOUD_BILLING_ACCOUNT_ID` if you want
the project setup script to use it as a fallback option.

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
