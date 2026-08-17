---
name: add-persisted-setting
description: Add configuration or other locally persisted state using the single-record settings entity and the typed Hive box registry, including the sync/async box rule. Use when asked to add a setting, preference, toggle, stored record, or any value that must survive a restart.
---

# Persisted state

This project has no Hive infrastructure yet; the conventions below are the
target being ported in. If `pubspec.yaml` has no `hive_ce`, say so and stop
rather than improvising a different persistence layer.

## One box, one entity, one class

Configuration is **a single Freezed class stored as one record under one key**,
not a key per setting.

```dart
@freezed
sealed class AppSettings with _$AppSettings {
  const factory AppSettings({
    required bool hapticsEnabled,
    required int dailyGoal,
    required Instrument instrument,
  }) = _AppSettings;

  const AppSettings._();

  factory AppSettings.defaults() => AppSettings(
    hapticsEnabled: Env.isIOS,
    dailyGoal: TuningGoal.defaultDailyGoal,
    instrument: Instrument.acousticGrandPiano,
  );

  factory AppSettings.fromJson(Map<String, Object?> json) =>
      _$AppSettingsFromJson(json);

  static const String storageKey = 'appSettings';
}
```

Rules:

- **`defaults()` is the only source of initial values, and it contains no
  numeric literals.** Every number comes from a named constant (the `Tuning*`
  classes). A literal here is a magic number that silently disagrees with the
  same value elsewhere in the app.
- **`storageKey` is a static const on the entity**, so the key and the type
  that owns it cannot drift apart.
- Adding a field means adding it to `defaults()` in the same edit. A record
  written by an older version will not have it, so it must be non-nullable with
  a default or explicitly nullable.

The notifier owns the box and exposes intent, never the box itself:

```dart
class SettingsNotifier extends Notifier<AppSettings> {
  late final Box<AppSettings> _box;

  @override
  AppSettings build() {
    _box = AppHiveBox.settings.syncBox();
    return _box.get(AppSettings.storageKey) ?? AppSettings.defaults();
  }

  Future<void> save(AppSettings updated) async {
    await _box.put(AppSettings.storageKey, updated);
    state = updated;
  }

  Future<void> resetToDefaults() async {
    final defaults = AppSettings.defaults();
    await _box.put(AppSettings.storageKey, defaults);
    state = defaults;
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
  name: 'settingsProvider',
);
```

Callers change one field with `copyWith` and pass the whole record to `save`.
Do not add a setter per field, and never write to the box from a widget.

Transient state that need not survive a restart does not go near Hive; use a
plain `Notifier`.

## The sync/async box rule

**Hard rule. Every box declares `sync` in `AppHiveBox`, and the choice is
determined by whether the entity count is bounded:**

| Contents | Bound | `sync` | Access |
|---|---|---|---|
| Configuration, metadata, small registries | **under ~500-1000 entities** | `true` | `syncBox()` |
| Stats, history, trial results, contacts, anything user-driven | **unbounded** | `false` | `await asyncBox()` |

```dart
enum AppHiveBox<T> {
  meta<MetaRecord>(sync: true),
  settings<AppSettings>(sync: true),
  scheduledNotifications<ScheduledNotification>(sync: true),

  trials<TrialResult>(sync: false),
  dailyStats<DailyStats>(sync: false);
```

Why it matters in both directions:

- A Hive `Box` is **fully loaded into memory when opened**, and startup awaits
  every `sync: true` box. Marking an unbounded box sync makes launch time grow
  with the user's history: fine on a fresh install, unusable for the heaviest
  users, and invisible in testing because test data is always small. This is
  the expensive mistake, and it surfaces months after release.
- Marking a bounded box async costs you the synchronous read. Settings would
  have to be read through a `Future`, which turns every consumer into an
  `AsyncNotifier` or a `FutureBuilder` and puts a loading state in front of the
  UI for data that was already in memory.

Both box kinds are opened at startup. The `sync` flag decides only whether
`init()` **awaits** the open or lets it finish in the background:

```dart
for (final box in values) {
  if (box.sync) {
    await box.asyncBox();
  } else {
    unawaited(box.asyncBox());
  }
}
```

`syncBox()` asserts `sync` and returns the already-open box. That assert is the
enforcement, so it fires in debug and profile builds only: calling `syncBox()`
on an async box in release returns a box that **may not be open yet**, which
fails as a Hive "box not found" error far from the declaration that caused it.

When in doubt about the bound, ask what the number looks like for the app's
heaviest user after two years. If the answer is "it depends how much they use
it", the box is unbounded.

## Adding a new box

1. Add the entry to `AppHiveBox` with its `sync` value and a doc comment saying
   what it holds.
2. Add the type to the `@GenerateAdapters` list in `hive/hive_adapters.dart`,
   along with any enum it contains. Enums need their own `AdapterSpec`.

   ```dart
   @GenerateAdapters([
     AdapterSpec<AppSettings>(),
     AdapterSpec<Instrument>(),
   ])
   ```

3. Run `dart run build_runner build --delete-conflicting-outputs`.

**typeIds are not written by hand.** `hive_ce_generator` assigns them and
records the assignment in `lib/hive/hive_adapters.g.yaml`, together with a
field index per member. That file is generated, but unlike `*.g.dart` it is
**checked into version control**, because it is the on-disk compatibility
contract:

- Never hand-edit it and never delete it to "regenerate cleanly". Losing it
  means ids are reassigned from scratch and every existing install decodes old
  bytes into the wrong class.
- Ids and field indices of removed types and fields are **retired, not reused**.
  Gaps in the numbering are correct and must be left alone.
- Review its diff like source. An unexpected change there is a data
  compatibility change, whatever the Dart diff looks like.
- Renaming a field is a remove plus an add: the old index is retired and the
  data under it becomes unreachable. If the value must be preserved, it needs a
  migration.

## Migrations

`MetaRecord.schemaVersion` in the `meta` box records the schema the data on
disk was written with. On startup, `runMigrations(storedVersion)` runs anything
pending and the new version is written back.

Bump `currentSchemaVersion` and add a migration step for any change that makes
existing data wrong rather than merely absent: a field changing meaning or
units, a value needing recomputation, data moving between boxes. A plain field
addition with a sensible default needs no migration.

## Verify

Persistence bugs do not appear in a single run. Check both directions:

- A fresh install gets `defaults()`. Clearing app data is the honest test.
- A value survives a **full restart**, not a hot reload. Hot reload keeps boxes
  open and hides a registration or open-order mistake.

## Stop and ask

- A `storageKey` would change on already-released data
- Something on disk needs a real migration
- A box's bound is genuinely unclear, which decides `sync`
- `hive_adapters.g.yaml` shows a change you did not intend
