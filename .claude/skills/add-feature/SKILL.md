---
name: add-feature
description: Add a product feature to this app following its domain/data/presentation layering, Riverpod provider conventions and Freezed models. Use when asked to add a feature, screen, repository, controller, or provider, or when unsure where a new file belongs.
---

# Adding a feature

Every product feature is a vertical slice under `lib/features/<feature>/`, split
into three layers. The layering is the point: it is what keeps the domain
testable without a Flutter binding and lets the data layer be swapped without
touching the UI. Do not flatten it because a feature looks small, and do not
add a fourth layer because one looks big.

## Assumptions

Riverpod 3 and Freezed 3. The examples below use Freezed 3 syntax
(`@freezed sealed class X with _$X`) and manual Riverpod providers.

**Providers are written by hand. `riverpod_annotation` and `riverpod_generator`
are deliberately absent from `pubspec.yaml`.** Code generation covers Freezed,
JSON and Hive only. Do not add those packages back to make a `@riverpod`
example work, and if you see `@riverpod` in a document describing this project,
the document is stale and the code wins.

## Layout

```
lib/features/<feature>/
  domain/            # contracts and pure models
  data/              # implementations and their providers
  presentation/
    controller/      # Riverpod notifiers
    model/           # Freezed UI-state models
    widget/          # screens and widgets
```

## 1. `domain/`: contracts and pure models

Abstract repository interfaces and the models they return.

**Hard constraint: no `package:flutter/*` and no `package:flutter_riverpod/*`
imports in this directory.** `package:flutter/foundation.dart` is tolerated
where Freezed needs it. If a domain file needs a Flutter or Riverpod import,
the abstraction is wrong; stop and say so instead of adding the import.

```dart
// domain/gallery_images_repository.dart
abstract class GalleryImagesRepository {
  Future<List<GalleryImage>> fetch(GalleryImagesOrder order, AdultContentFilter filter);
}

// domain/gallery_image.dart
@freezed
sealed class GalleryImage with _$GalleryImage {
  const GalleryImage._();          // required for custom getters and methods

  const factory GalleryImage({
    required String imageUrl,
    required String prompt,
    required bool nsfw,
  }) = _GalleryImage;

  factory GalleryImage.fromJson(Map<String, Object?> json) =>
      _$GalleryImageFromJson(json);
}
```

Enums that model a domain choice (sort order, filter mode) live here too, not
in the presentation layer, even when only one widget reads them.

## 2. `data/`: implementations and providers

One file per provider, named `<thing>_provider.dart`, holding the provider and
its private implementation class together.

```dart
// data/gallery_images_repository_provider.dart
final galleryImagesRepositoryProvider = Provider<GalleryImagesRepository>(
  (ref) => _GalleryImagesRepositoryImpl(client: ref.watch(httpClientProvider)),
  name: 'Gallery repository provider',
);

class _GalleryImagesRepositoryImpl implements GalleryImagesRepository { ... }
```

Rules:

- **Type the provider by the interface** (`Provider<GalleryImagesRepository>`),
  never by the implementation. This is what makes the provider overridable in
  tests with a fake.
- **The implementation class is private** (leading underscore) and lives in the
  same file. Nothing outside the data layer may name it.
- **Always pass `name:`.** `AppProviderObserver` logs provider transitions and
  errors by name; an unnamed provider produces unreadable logs.
- **Get dependencies through `ref.watch`**, never by constructing an
  `http.Client` or reading a box directly. `httpClientProvider` exists so the
  network can be faked in one place.
- Repository implementations own their wire format: JSON parsing, query
  parameter mapping, and normalising server quirks. None of that leaks upward.
  Map API strings to domain enums with an exhaustive `switch` expression, so a
  new enum value becomes a compile error rather than a silent default.

If the repository persists data rather than fetching it, use a
`NotifierProvider` so the repository *is* the notifier and its state is
observable:

```dart
final imageBookmarksRepositoryProvider =
    NotifierProvider<ImageBookmarksRepository, List<GalleryImage>>(
  ImageBookmarksRepositoryImpl.new,
);
```

## 3. `presentation/`

### `model/`: UI state

Freezed models carrying derived state, often combining several domain models
into one snapshot the widget can render without further work. Put computed
getters here (after the private constructor) rather than in widgets.

### `controller/`: Riverpod notifiers

`AsyncNotifier<T>` for async state, `Notifier<T>` for sync state.

```dart
final feedController = AsyncNotifierProvider(FeedController.new);

class FeedController extends AsyncNotifier<Feed> {
  @override
  Future<Feed> build() async {
    final params = ref.watch(feedParametersProvider);
    final images = await ref.watch(galleryImageCacheProvider(params).future);
    return Feed(parameters: params, images: _toFeedImages(images));
  }

  void hide(FeedImage image) {
    if (!state.isLoading && state.hasValue) {
      final feed = state.value!;
      state = AsyncData(feed.copyWith(
        images: feed.images.where((it) => it != image).toList(),
      ));
    }
  }
}
```

Two rules that are easy to get wrong:

- **Declare every reactive dependency in `build()` via `ref.watch`.** A
  dependency read inside a method instead will not trigger a rebuild, and the
  bug looks like a stale screen rather than an error.
- **Public methods mutate state directly** (`state = AsyncData(...)`), they do
  not re-invoke `build()`. Guard with `state.hasValue` first: mutating during
  the loading phase throws.

### `widget/`: screens and widgets

Screens are suffixed `*Screen`. Use `ConsumerWidget` or
`ConsumerStatefulWidget` whenever a widget watches a provider. Co-locate
sub-widgets in a sub-folder named after their screen.

Widgets do not parse, sort, filter or fetch. If a widget needs data shaped
differently, that shaping belongs in a `presentation/model` getter or in the
controller.

## Cross-cutting

- **Logging**: use `shared/log`, never `print`. Prefer a class-level logger,
  `static final _log = Log.forType(MyClass);`. Level is `ALL` in debug and
  `WARNING` in release, so anything you want to see in production must be
  `warning` or above.
- **Snackbars from outside the widget tree** (from a notifier, for example) go
  through the global `scaffoldMessengerKey` in `shared/scaffold_messenger/`.
- **Build-time constants** go in `app/env.dart` via `String.fromEnvironment`,
  passed with `--dart-define`. Never read a raw environment string at a call
  site; add a named accessor to `Env` so a typo is a compile error.
- **User-visible strings** are localised. Add them to the ARB files and reach
  them through the generated `AppLocalizations`, never as literals in a widget.

## Checklist

- [ ] `domain/`: repository interface plus models, no Flutter or Riverpod imports
- [ ] `data/`: implementation, private, with a provider typed by the interface and given a `name:`
- [ ] `presentation/model/`: Freezed UI-state models
- [ ] `presentation/controller/`: notifiers, dependencies watched in `build()`
- [ ] `presentation/widget/`: `*Screen` plus co-located sub-widgets
- [ ] New Hive boxes registered in `AppHiveBox` (see `add-persisted-setting`)
- [ ] New `Env` constants added if the feature needs build-time config
- [ ] Localised strings added to the ARB files
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter analyze` and `flutter test` pass

## Stop and ask

- A domain model needs a Flutter or Riverpod import
- A feature needs to read another feature's providers directly (it usually
  means the shared piece belongs in `shared/`)
- A new third-party package is required
- The change touches native configuration; that is `bump-deps` territory
