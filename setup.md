# Project setup instruction

## Environment setup

Make sure a JDK is installed, `JAVA_HOME` is set and `java` is on the `PATH`.

Add aliases (per OS user):

```shell
# ~/.bashrc

# (re)generate code and git-add new files
alias ba='dart run build_runner build && git add -A .'
alias fa='flutter pub add '
alias ft='flutter test'
alias fit='flutter drive --driver=test_driver/integration_test.dart --target=integration_test/all_tests.dart'
alias frm='flutter run -d "moto g24"'
alias frl='flutter run -d "linux"'
```

### Google Cloud

This instruction is for Ubuntu.

Integration with Google Cloud is needed if you are going to use any of their services,
for example, Firebase Test Lab.

[Create a billing account](https://console.cloud.google.com/billing) if you don't have a suitable one yet. \
Then, [create a project in Google Cloud](https://console.cloud.google.com/projectcreate).

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

Install the tool itself:

```shell
sudo apt-get update && sudo apt-get install google-cloud-cli
```

Init the tool; this doesn't integrate it with the project yet:

```shell
gcloud init
```

Enable required APIs:

```shell
gcloud services enable testing.googleapis.com
gcloud services enable toolresults.googleapis.com
gcloud services enable billingbudgets.googleapis.com
```

Find the billing account to use:

```shell
gcloud billing accounts list
```

Make it available (`.bash_profile` is ok);

```shell
export GCLOUD_BILLING_ACCOUNT_ID="XXX"
```

Setup billing account for the project:

```shell
gcloud billing projects link flutter-app-template-445902 \
    --billing-account=$GCLOUD_BILLING_ACCOUNT_ID
```

Create the project bucket for Test Lab results:

```shell
gcloud storage buckets create gs://flutter-app-template-445902-test --location US-WEST1 --public-access-prevention --uniform-bucket-level-access
```

Configure Test Lab permissions:

```shell
export GC_ACCOUNT=$(gcloud config get-value account)
echo "Google cloud account: $GC_ACCOUNT"

gcloud projects add-iam-policy-binding flutter-app-template-445902 \
    --member="user:$GC_ACCOUNT" \
    --role="roles/cloudtestservice.testAdmin"

gcloud projects add-iam-policy-binding flutter-app-template-445902 \
    --member="user:$GC_ACCOUNT" \
    --role="roles/firebase.analyticsViewer"
```

#### Reference material

General

* [Project console](https://console.cloud.google.com/welcome/new?project=flutter-app-template-445902)
* [CLI installation](https://cloud.google.com/sdk/docs/install-sdk)
* [Create project using CLI - reference](https://cloud.google.com/sdk/gcloud/reference/projects/create)
* [`gcloud` CLI Tool reference](https://cloud.google.com/sdk/gcloud/reference)

Storage

* [Storage CLI reference](https://cloud.google.com/sdk/gcloud/reference/storage)
* [Storage access keys manager](https://console.cloud.google.com/storage/settings;tab=interoperability?project=flutter-app-template-445902)

Test Lab

* [Build and run tests](notes/firebase-test-lab.md)
* [IAM Permissions Reference](https://firebase.google.com/docs/test-lab/android/iam-permissions-reference)

Switching CLI tool back to this project:

```shell
gcloud config set project flutter-app-template-445902
```

Checking the bucket list:

```shell
gcloud storage buckets list
```

### Shorebird

[Create a dev account with Shorebird](https://console.shorebird.dev/login) if you haven't yet.

Install [Shorebird](https://docs.shorebird.dev/) (per OS user):

```shell
# Using the installer, installs to ~/.shorebird
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
```

```shell
# ALTERNATIVELY, clone the repo (add ~/tools/shorebird/bin to the PATH manually in ~/.bash_profile):
git clone -b stable https://github.com/shorebirdtech/shorebird.git ~/tools/shorebird
```

```shell
# Login:
shorebird login
```

Integrate Shorebird with the project:

```shell
shorebird init
```

## Dependencies

Useful optional dependencies.

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
