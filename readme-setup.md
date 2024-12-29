# Project setup instruction

This instruction is for Ubuntu users.

## Prerequisites

Make sure JDK is installed, `JAVA_HOME` is set and `java` is on the `PATH`.

Also make sure you have `git`, `sed` and `curl`

## Environment setup

Make sure

Add aliases once per OS user:

```shell
cat << EOF >> ~/.bashrc
# Aliases for Flutter dev - begin
alias ba='dart run build_runner build && git add -A .'
alias fa='flutter pub add '
alias ft='flutter test'
alias fit='flutter drive --driver=test_driver/integration_test.dart --target=integration_test/all_tests.dart'
alias frl='flutter run -d "linux"'
# Aliases for Flutter dev - end
EOF
```

These are my personal ones:

```shell
cat << EOF >> ~/.bashrc
# Personal aliases for Flutter dev - begin
alias frm='flutter run -d "moto g24"'
# Personal aliases for Flutter dev - end
EOF
```

### GitHub CLI

Install GitHub [command line utility](https://github.com/cli/cli/blob/trunk/docs/install_linux.md).
It's [quite useful](https://cli.github.com/); the setup script uses it to create project repo on GitHub.

### Google Cloud

Integration with Google Cloud is needed if you are going to use any of their services,
for example, Firebase Test Lab.

[Create a billing account](https://console.cloud.google.com/billing) if you don't have a suitable one yet.
The setup script will ask the billing account ID to use for the project.

Place your billing account to `GCLOUD_BILLING_ACCOUNT_ID` if you want to reuse it in different projects.
The setup script will use it as a fallback value.

Install dependencies:

```shell
sudo apt-get install apt-transport-https ca-certificates gnupg curl
```

Import Google Cloud public key:

```shell
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
```

Add Google Cloud SDK distribution URL:

```shell
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
  sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
```

Install the tool:

```shell
sudo apt-get update && sudo apt-get install google-cloud-cli
```

Init the tool:

```shell
gcloud init
```

### Shorebird

Shorebird is a tool that enables over-the-air (OTA) code updates for Flutter apps,
allowing developers to patch their production apps without going through the app store review process.

[Create a dev account with Shorebird](https://console.shorebird.dev/login) if you haven't yet.

Install [Shorebird](https://docs.shorebird.dev/) (per OS user).

One option is to use the installer. This installs it to `~/.shorebird`

```shell
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
```

Alternatively, clone the repo (add ~/tools/shorebird/bin to the PATH manually in ~/.bash_profile):

```shell
git clone -b stable https://github.com/shorebirdtech/shorebird.git ~/tools/shorebird
```

## Flutter Packages

Useful optional packages.

### Routing

```shell
flutter pub add go_router
```

### Mocktail

```shell
flutter pub add dev:mocktail
```

### Freezed

```shell
flutter pub add freezed_annotation
flutter pub add dev:build_runner
flutter pub add dev:freezed
```

### JSON serialisation

```shell
flutter pub add json_annotation
flutter pub add dev:json_serializable
```

### Test data generation

```shell
flutter pub add dev:random_name_generator
```

### Device preview

[Device preview package:](https://pub.dev/packages/device_preview/score)

```shell
flutter pub add device_preview
```
