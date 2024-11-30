# New Flutter project template

This is a template for a new Flutter project with the instructions on how to set up common integrations.

## Environment setup

Useful aliases:

```shell
# ~/.bashrc 
alias ba='dart run build_runner build && git add -A .'
```

## Dependencies

Useful optional dependencies.

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

## TODO

* prepare multi-file integration test suite for Test Lab
* how to retrieve test screenshots from Test Lab
