# Notes on running integration tests

## Running mobile integration tests

```shell
pushd ..
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/main_test.dart
popd
```

