# Architecture

## Scope and boundaries

Ledger is an offline Android Flutter application. Flutter's Material 3 widgets provide the UI. UI state uses `StatefulWidget`, `ValueNotifier`, `StreamBuilder`, and constructor injection. The MVP has no external state-management or routing package.

The app shell has two destinations, Transactions and Statistics. Narrow layouts use `NavigationBar`; wide layouts use `NavigationRail`. The selected destination belongs to the shell. Category management is a pushed auxiliary page opened from the Transactions app bar.

The theme follows system brightness. Material You color schemes are used on supported Android devices through `dynamic_color`; a centralized light/dark `ColorScheme.fromSeed(seedColor: Colors.blue)` is used otherwise. User-visible strings come from `lib/l10n/app_en.arb` through Flutter's generated localization classes.

`dynamic_color` stays on the 1.x line for this foundation because 2.x returns `material_ui` color schemes that cannot be passed to Flutter's official `ThemeData`. The 1.x API supplies Flutter Material color schemes directly. Reconsider this constraint only when the official Flutter Material integration is compatible.

The Android manifests omit `INTERNET` permission in every build variant, so the standard Flutter debug service and hot reload are unavailable. Android backup is disabled in the application manifest. Stage 1 uses Flutter 3.47.5 stable, the generated Dart 3.13.4 lower bound, and a committed `pubspec.lock`; the Gradle wrapper uses its smaller binary distribution. Automated Android runtime access is unavailable in the current verification environment, so APK verification must remain offline or use a separately authorized manual installation.

## Persistence and data model

SQLite persistence uses Drift 2.x with `drift_flutter`. `AppDatabase` opens `ledger.sqlite` in the application documents directory, enables SQLite foreign keys on every open, and exposes an injectable in-memory constructor for tests. A blocking localized error page with retry is shown if the database cannot be opened; the app never deletes or rebuilds a failed database automatically.

Schema version 2 contains:

- `categories`: integer identity, trimmed display name, normalized sibling name, fixed income/expense integer value, optional self-referencing parent, and UTC creation/modification timestamps in microseconds. A null parent denotes level 2; a non-null parent denotes level 3.
- `ledger_transactions`: the Stage 3 persistence foundation with integer-cent amount, local calendar date as an integer epoch-day, fixed income/expense value, required level-2 identity, optional level-3 identity, optional note, and UTC creation/modification timestamps in microseconds.
- `transaction_draft_records`: one optional singleton new-transaction draft containing the raw amount input, income/expense type, nullable category identities, and note. The date is deliberately absent because every form opening derives it from the selected month. Draft category foreign keys use `SET NULL` so category deletion cannot block and stale selections can be sanitized on load.

The date uses an epoch-day instead of a timestamp so device time-zone changes cannot move a transaction to another calendar day. Money remains an integer number of cents. Category-parent and transaction-category foreign keys use `RESTRICT`; destructive category workflows must explicitly handle durable dependent records inside an application-level transaction instead of relying on an implicit cascade. Draft category references use `SET NULL` as described above.

Sibling uniqueness is enforced twice: the repository validates names for localized feedback, and SQLite partial unique indexes protect against races. Level-2 names are unique by income/expense side; level-3 names are unique by parent. Normalization trims outer whitespace and folds English `A`–`Z` only, matching the accepted behavior without applying locale-dependent transformations to other scripts.

`CategoryRepository` owns category persistence, validation, creation-order queries, and reactive hierarchy streams. `CategoryApplicationService` owns atomic subtree deletion and migration, cross-side rejection, level-3 transaction moves, and explicit per-conflict merge or rename decisions. Widgets receive both through constructor injection.

`TransactionRepository` validates transaction invariants at the persistence boundary, performs create/update/delete operations, joins category names into monthly results, and orders rows by date and creation time descending. Creating a transaction and removing its saved draft occur in one database transaction. Draft loading preserves amount, type, and note while clearing invalid category selections according to the accepted hierarchy rules.

`StatisticsRepository` derives a reactive `MonthlyStatistics` value from the existing joined monthly transaction stream; Stage 4 adds no table or persisted summary. The immutable statistics model aggregates positive integer cents by income/expense, level-2 category, optional level-3 category, and direct level-2 assignment. Category rows use category identity order, which follows creation order. Totals, balances, and percentages use integer arithmetic throughout; percentage scaling uses `BigInt` intermediates to prevent overflow before returning the small display value. Percentage formatting rounds to two decimal places and handles nonzero shares below `0.01%` explicitly.

The app shell owns one in-memory `YearMonth` shared by Transactions and Statistics. It starts at the current month on every process launch and is never persisted. Calendar dates convert to UTC-based epoch-day integers using only their year, month, and day components, avoiding time-zone and daylight-saving shifts. A new form derives its date from the selected month; a successful create or edit moves the shared selected month to the saved date's month.

The Transactions page watches one month through Drift, groups compact rows by date, and displays category paths, one-line notes, entry-type labels, and explicit signed CNY amounts. One shell-level `FloatingActionButton` opens a reusable create/edit modal sheet. New-form dismissal persists the single draft; edit dismissal leaves the stored record unchanged. Inline category creation uses the existing category repository.

The Statistics page watches the same selected month and renders text-only summary rows followed by separate income and expense hierarchies. It uses compact list rows rather than charts or dashboard cards. Direct level-2 assignments receive a localized `No subcategory` child only when named level-3 rows are also present. The shared integer-cent CNY formatter is also used by transaction rows, so display formatting never converts stored or aggregated money to floating point.

Drift-generated database code is committed. `drift_schemas/app_database/` stores every schema version, and generated migration helpers under `test/generated_migrations/` validate the current database against those committed snapshots. Every future schema edit must increment `schemaVersion`, add a migration, refresh the snapshot, and add a data-preservation migration test.

## Source organization

- `lib/app/`: app root, responsive shell, and centralized theme.
- `lib/core/database/`: Drift tables, database opening, and migration strategy.
- `lib/core/money/`: integer-cent CNY display formatting.
- `lib/core/time/`: calendar-month and epoch-day utilities.
- `lib/features/categories/domain/`: category types, validation values, and operation models.
- `lib/features/categories/data/`: the Drift-backed category repository.
- `lib/features/categories/application/`: atomic multi-entity category rules.
- `lib/features/categories/presentation/`: category management UI and conflict workflows.
- `lib/features/transactions/domain/`: transaction values, validation, drafts, and errors.
- `lib/features/transactions/data/`: transaction CRUD, monthly joins, and draft persistence.
- `lib/features/transactions/presentation/`: shared month navigation, monthly rows, and the create/edit sheet.
- `lib/features/statistics/domain/`: immutable monthly totals, category aggregates, and percentage formatting.
- `lib/features/statistics/data/`: reactive statistics projection over monthly transactions.
- `lib/features/statistics/presentation/`: text-only monthly summary and category hierarchy.
- `lib/l10n/`: English ARB source; generated Dart stays under Flutter's generated localization output.
- `drift_schemas/`: committed schema snapshots.
- `test/generated_migrations/`: generated schema helpers used by migration tests.

## Verification

Static formatting, analysis, unit/database/migration/widget tests, and an Android debug build are stage gates. Automated emulator and physical-device access are unavailable in the current verification environment. Exact verification results and any explicitly skipped device checks are recorded in `docs/progress.md` and the current session note.
