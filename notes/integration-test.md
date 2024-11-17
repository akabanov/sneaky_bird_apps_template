# Notes on running integration tests

## Running mobile integration tests

```shell
pushd ..
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/main_test.dart
popd
```


## Building test apk

```shell
pushd ../android
flutter build apk
./gradlew app:assembleAndroidTest
./gradlew app:assembleDebug -Ptarget=integration_test/main_test.dart
popd
```

## Running the tests in Test Lab

```shell
pushd ..
gcloud --quiet config set project flutter-skeleton-app-2ee87
gcloud firebase test android run --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --timeout 2m \
  --results-bucket=gs://flutter-skeleton-app-2ee87 \
  --results-dir=test-lab-results
popd 
```
