# Post-setup references and snippets

## Quick access

* [Google console](https://console.cloud.google.com/welcome/)
* [Google resources manager](https://console.cloud.google.com/cloud-resource-manager?organizationId=0)
* [Google project console](https://console.cloud.google.com/welcome/new?project=flutter-app-template-445902)
* [Shorebird console](https://console.shorebird.dev/)

## Google

### Firebase Test Lab

#### Android

Build test artifacts:

```shell
pushd android
flutter build apk
./gradlew app:assembleAndroidTest
./gradlew app:assembleDebug -Ptarget=integration_test/all_tests.dart
popd
```

Run the Test Lab tests:

```shell
gcloud --quiet config set project flutter-app-template-445902
gcloud firebase test android run --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --timeout 2m \
  --results-bucket=gs://flutter-app-template-445902-test \
  --results-dir=test-lab-results-$(date +%Y%m%d-%H%M)
```

#### iOS

TODO; [integration-test package reference](https://github.com/flutter/flutter/tree/main/packages/integration_test)

### Cloud

General

* [CLI installation](https://cloud.google.com/sdk/docs/install-sdk)
* [Create project using CLI - reference](https://cloud.google.com/sdk/gcloud/reference/projects/create)

Storage

* [Storage CLI reference](https://cloud.google.com/sdk/gcloud/reference/storage)
* [Storage access keys manager](https://console.cloud.google.com/storage/settings;tab=interoperability?project=flutter-app-template-445902)

Test Lab

* [Build and run tests](readme-reference.md)
* [IAM Permissions Reference](https://firebase.google.com/docs/test-lab/android/iam-permissions-reference)

Switching CLI tool back to this project:

```shell
gcloud config set project flutter-app-template-445902
```

Checking the bucket list:

```shell
gcloud storage buckets list
```

### Play Store

## Apple

### App Store

