# Shell snippets

## Switch environment

Switch back GCloud:

```shell
gcloud config set project project-id-placeholder
```

## Firebase Test Lab

**TBD:** move to `fastlane`.

### Android

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
gcloud --quiet config set project project-id-placeholder
gcloud firebase test android run --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --timeout 2m \
  --results-bucket=gs://project-id-placeholder-test \
  --results-dir=test-lab-results-$(date +%Y%m%d-%H%M)
```

### iOS: TBD

