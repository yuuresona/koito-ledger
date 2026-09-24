# Architecture

## Scope and boundaries

Ledger is an offline Android Flutter application. Flutter's Material 3 widgets provide the UI. UI state uses `StatefulWidget`, `ValueNotifier`, `StreamBuilder`, and constructor injection. The MVP has no external state-management or routing package.

The app shell has two destinations, Transactions and Statistics. Narrow layouts use `NavigationBar`; wide layouts use `NavigationRail`. The selected destination belongs to the shell. Category management is a pushed auxiliary page opened from the Transactions app bar.

The theme follows system brightness. Material You color schemes are used on supported Android devices through `dynamic_color`; a centralized light/dark `ColorScheme.fromSeed(seedColor: Colors.blue)` is used otherwise. User-visible strings come from `lib/l10n/app_en.arb` through Flutter's generated localization classes.

`dynamic_color` stays on the 1.x line for this foundation because 2.x returns `material_ui` color schemes that cannot be passed to Flutter's official `ThemeData`. The 1.x API supplies Flutter Material color schemes directly. Reconsider this constraint only when the official Flutter Material integration is compatible.

The Android manifests omit `INTERNET` permission in every build variant, so the standard Flutter debug service and hot reload are unavailable. Local debug APKs can be installed and launched with `adb`. Android backup is disabled in the application manifest. Stage 1 uses Flutter 3.47.5 stable, the generated Dart 3.13.4 lower bound, and a committed `pubspec.lock`; the Gradle wrapper uses its smaller binary distribution.

## Persistence and data model

SQLite persistence uses Drift 2.x with `drift_flutter`. `AppDatabase` opens `ledger.sqlite` in the application documents directory, enables SQLite foreign keys on every open, and exposes an injectable in-memory constructor for tests. A blocking localized error page with retry is shown if the database cannot be opened; the app never deletes or rebuilds a failed database automatically.

Schema version 1 contains:

- `categories`: integer identity, trimmed display name, normalized sibling name, fixed income/expense integer value, optional self-referencing parent, and UTC creation/modification timestamps in microseconds. A null parent denotes level 2; a non-null parent denotes level 3.
- `ledger_transactions`: the Stage 3 persistence foundation with integer-cent amount, local calendar date as an integer epoch-day, fixed income/expense value, required level-2 identity, optional level-3 identity, optional note, and UTC creation/modification timestamps in microseconds.

The date uses an epoch-day instead of a timestamp so device time-zone changes cannot move a transaction to another calendar day. Money remains an integer number of cents. Foreign keys use `RESTRICT`; destructive category workflows must explicitly handle dependent records inside an application-level transaction instead of relying on an implicit cascade.

Sibling uniqueness is enforced twice: the repository validates names for localized feedback, and SQLite partial unique indexes protect against races. Level-2 names are unique by income/expense side; level-3 names are unique by parent. Normalization trims outer whitespace and folds English `A`–`Z` only, matching the accepted behavior without applying locale-dependent transformations to other scripts.

`CategoryRepository` owns category persistence, validation, creation-order queries, and reactive hierarchy streams. `CategoryApplicationService` owns atomic subtree deletion and migration, cross-side rejection, level-3 transaction moves, and explicit per-conflict merge or rename decisions. Widgets receive both through constructor injection.

Drift-generated database code is committed. `drift_schemas/app_database/` stores every schema version, and generated migration helpers under `test/generated_migrations/` validate the current database against those committed snapshots. Every future schema edit must increment `schemaVersion`, add a migration, refresh the snapshot, and add a data-preservation migration test.

## Source organization

- `lib/app/`: app root, responsive shell, and centralized theme.
- `lib/core/database/`: Drift tables, database opening, and migration strategy.
- `lib/features/categories/domain/`: category types, validation values, and operation models.
- `lib/features/categories/data/`: the Drift-backed category repository.
- `lib/features/categories/application/`: atomic multi-entity category rules.
- `lib/features/categories/presentation/`: category management UI and conflict workflows.
- `lib/l10n/`: English ARB source; generated Dart stays under Flutter's generated localization output.
- `drift_schemas/`: committed schema snapshots.
- `test/generated_migrations/`: generated schema helpers used by migration tests.

## Verification

Static formatting, analysis, unit/database/migration/widget tests, and an Android debug build are stage gates. Android verification uses a physical device in this environment because hardware virtualization support is unavailable. Exact results are recorded in `docs/progress.md` and the current session note.
