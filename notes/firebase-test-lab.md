# Firebase Test Lab Integration

**Note**: [set up your GCloud account first](gcloud.md)

## Configure permissions

Do this once per Google account.

See https://firebase.google.com/docs/test-lab/android/iam-permissions-reference

```shell
export GC_ACCOUNT=$(gcloud config get-value account)
echo "Google cloud account: $GC_ACCOUNT"

gcloud projects add-iam-policy-binding flutter-skeleton-app-2ee87 \
    --member="user:$GC_ACCOUNT" \
    --role="roles/cloudtestservice.testAdmin"

gcloud projects add-iam-policy-binding flutter-skeleton-app-2ee87 \
    --member="user:$GC_ACCOUNT" \
    --role="roles/firebase.analyticsViewer"
```

## Running Android tests in Test Lab

Check out the [using the gcloud CLI reference](https://firebase.google.com/docs/test-lab/android/command-line).

Make sure a JDK is installed, `JAVA_HOME` is set and `java` is on the `PATH`.

Build test artifacts:

```shell
pushd ../android
flutter build apk
./gradlew app:assembleAndroidTest
./gradlew app:assembleDebug -Ptarget=integration_test/main_test.dart
popd
```

Run the Test Lab tests:

```shell
pushd ..
gcloud --quiet config set project flutter-skeleton-app-2ee87
gcloud firebase test android run --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --timeout 2m \
  --results-bucket=gs://flutter-skeleton-app-2ee87 \
  --results-dir=test-lab-results-$(date +%Y%m%d-%H%M)
popd 
```

## Running iOS tests in Test Lab

TODO; [integration-test package reference](https://github.com/flutter/flutter/tree/main/packages/integration_test)

