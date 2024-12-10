# New Flutter project template

This is a template for a new Flutter project with the instructions on how to set up common integrations.

## Quick access

Run integration tests using test driver

```shell
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/main_test.dart
```

## Environment setup

Useful aliases (per OS user):

```shell
# ~/.bashrc

# (re)generate code and git-add new files
alias ba='dart run build_runner build && git add -A .'
alias fpa='flutter pub add '
alias ft='flutter test'
```

### Shorebird

Install Shorebird (per OS user):

```shell
# https://docs.shorebird.dev/
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
```

Integrate:

```shell
shorebird init
```

## Dependencies

Useful optional dependencies.

### Mockito

```shell
flutter pub add dev:mockito
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

### 

[Device preview package:](https://pub.dev/packages/device_preview/score)

```shell
flutter pub add device_preview
```

## TODO

* prepare multi-file integration test suite for Test Lab
* how to retrieve test screenshots from Test Lab
