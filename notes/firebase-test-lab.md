# Firebase Test Lab Integration

## Running Android tests in Test Lab

Build test artifacts:

```shell
pushd ../android
flutter build apk
./gradlew app:assembleAndroidTest
./gradlew app:assembleDebug -Ptarget=integration_test/all_tests.dart
popd
```

Run the Test Lab tests:

```shell
pushd ..
gcloud --quiet config set project flutter-app-template-445902
gcloud firebase test android run --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --timeout 2m \
  --results-bucket=gs://flutter-app-template-445902-test \
  --results-dir=test-lab-results-$(date +%Y%m%d-%H%M)
popd 
```

## Running iOS tests in Test Lab

TODO; [integration-test package reference](https://github.com/flutter/flutter/tree/main/packages/integration_test)

