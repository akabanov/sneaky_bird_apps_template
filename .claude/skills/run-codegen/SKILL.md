---
name: run-codegen
description: Run and troubleshoot build_runner code generation for Freezed, json_serializable, Hive adapters and localisations. Use when generated files are missing or stale, when a *.freezed.dart or *.g.dart import fails to resolve, or when build_runner errors.
---

# Code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

`--delete-conflicting-outputs` is not optional here. Without it, a rename or a
partially failed previous run leaves an orphaned output that blocks the next
build with a conflict that reads like an unrelated error.

## What is generated, and by what

| Suffix | Generator | Written for |
|---|---|---|
| `*.freezed.dart` | `freezed` | `@freezed` models: `copyWith`, equality, pattern matching |
| `*.g.dart` | `json_serializable` | `fromJson` / `toJson` |
| `hive/hive_adapters.g.dart` | `hive_ce_generator` | adapters for every `AdapterSpec` in `@GenerateAdapters` |
| `hive/hive_adapters.g.yaml` | `hive_ce_generator` | the typeId and field-index ledger, **committed** |
| `hive/hive_registrar.g.dart` | `hive_ce_generator` | `Hive.registerAdapters()` |
| `gen/app_localizations*.dart` | `flutter gen-l10n` | ARB files, **not** build_runner |

Localisations are the exception: they are produced by the Flutter tool, so
running build_runner will never fix a missing `AppLocalizations` member. Run
`flutter gen-l10n` (or a build, which triggers it) after editing an ARB file.

**Never hand-edit a generated file.** The next run overwrites it, so the fix
lasts exactly until someone else builds and reappears as a mystery regression.
Change the annotated source instead.

## The declarations generation depends on

A missing `part` directive is the single most common cause of "generated file
not found", because the error names the missing file rather than the missing
line:

```dart
part 'gallery_image.freezed.dart';   // required by @freezed
part 'gallery_image.g.dart';         // required only if the model has fromJson
```

The filenames must match the source file exactly. Rename the file and both
directives have to follow.

Freezed 3 model shape:

```dart
@freezed
sealed class MyModel with _$MyModel {
  const MyModel._();                 // needed for any custom getter or method

  const factory MyModel({
    required String id,
    @Default(false) bool flag,
  }) = _MyModel;

  factory MyModel.fromJson(Map<String, Object?> json) => _$MyModelFromJson(json);

  bool get isFlagged => flag;        // custom members go after the private ctor
}
```

Omitting `const MyModel._()` and then adding a getter produces an error about
the mixin rather than about the missing constructor. That is the same class of
mistake, one line up.

## When a build fails

1. Read the **first** error, not the last. One missing part directive cascades
   into dozens of unresolved-symbol errors underneath it.
2. Errors naming `_$Something` are almost always a missing or misspelled
   `part`, not a generator bug.
3. If errors persist after a correct-looking source change, the build cache is
   suspect:

   ```bash
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```

4. `dart run build_runner watch --delete-conflicting-outputs` is convenient
   during a long editing session, but do not leave it running while switching
   branches: it regenerates against a half-checked-out tree.

## After generating

`flutter analyze` is the check that matters, because generation can succeed
while producing code that does not satisfy the analyzer. Both must be clean
before the change is considered done.

## Generated output is not committed

`lib/gen`, `*.g.dart` and `*.freezed.dart` are gitignored, so a fresh clone
does not build until generation has run.

`hive_adapters.g.yaml` is the exception: it is generated, but it is committed,
because it is the typeId ledger rather than code. See `add-persisted-setting`.

Two consequences worth holding on to:

- **`git status` proves nothing about generation.** A clean tree after a model
  change means the output was ignored, not that nothing needed regenerating.
  The evidence is `flutter analyze`, not the diff.
- **Every build environment must generate for itself.** Both Fastfiles run
  `build_runner` after `flutter pub get`. `codemagic.yaml` does not: its
  workflows run `flutter pub get` and `flutter gen-l10n` only, so any build
  path that does not go through Fastlane still needs the step adding. Skipping
  it fails in CI with missing `_$` symbols while every local build stays green,
  because the local tree still holds output from an earlier run.
