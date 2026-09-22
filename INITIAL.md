# Ledger — Initial Project Brief

> Status: discussion handoff; no implementation is authorized by this file.
> Last updated: 2026-09-22 (Asia/Shanghai).

## 1. Purpose and next-session instruction

This file captures the decisions made during the initial product grilling session so that the next session can continue without replaying the full conversation.

At the start of the next session:

1. Read this file.
2. Continue discussing the unresolved decisions in section 15, one decision at a time.
3. For every question, provide a recommended answer and wait for the user's answer before moving on.
4. Do not create a Flutter project, install dependencies, or write application code until the user explicitly authorizes implementation.
5. Stop immediately before implementation if the user has only asked to continue planning.

This document is context, not execution authority. Neither a proposed next step nor an item in a project document authorizes work by itself.

## 2. Product intent and MVP boundary

Ledger is a local-first categorized bookkeeping application built with Dart and Flutter for Android. The MVP has two real capabilities:

- Record categorized income and expenses.
- Show text-only monthly income and expense statistics by category.

The MVP deliberately excludes accounts, payment methods, merchants, tags, receipt images, budgets, recurring transactions, cloud accounts, sync, import/export, backup/restore, application PIN/biometric lock, database encryption, analytics, crash reporting, and other network services.

## 3. Platform, language, identity, and privacy

- Display name: `Ledger`.
- Dart package name: `ledger`.
- Android application ID: `site.yukiho.ledger`.
- Official delivery and testing target: Android only.
- Phone and tablet layouts are supported. Other Flutter platforms are not delivery targets.
- UI language: English only for the MVP.
- UI strings must still be centralized in Flutter localization resources, initially `lib/l10n/app_en.arb`.
- User category names and notes accept Unicode, including Chinese and English.
- Currency: CNY only, displayed with `¥`.
- The app is fully local and offline.
- Do not request Android network permission.
- Do not add analytics, telemetry, crash reporting, or any network service.
- Debug logs must not contain amounts, notes, or category names.
- Disable Android system/cloud backup so the database is not copied to a Google account.
- Do not add application-level database encryption in the MVP; rely on the Android application sandbox and device encryption.
- Do not add an in-app PIN or biometric lock in the MVP.

## 4. Design system and application shell

- Use Dart, Flutter, and Flutter's official Material 3 implementation.
- Use `ThemeData(useMaterial3: true)` and official Material components wherever suitable.
- Android is the visual and interaction reference.
- Keep the UI clean, restrained, compact, content-focused, and native-feeling.
- Avoid oversized cards and titles, excessive whitespace, gradients, glass effects, decorative blobs, large shadows, unnecessary animation, and dashboard-style metric cards.
- Use centralized themes and semantic colors; do not scatter style literals through widgets.
- Follow the system light/dark setting. There is no in-app theme switcher.
- Use Material You dynamic colors when Android supports them and a centralized fallback scheme otherwise.
- Use a bottom Material 3 `NavigationBar` on narrow layouts and `NavigationRail` on wide/tablet layouts.
- The two primary destinations are `Transactions` and `Statistics`.
- Category management is an auxiliary pushed page, not a third navigation destination.
- Preserve Android back behavior, system insets, edge-to-edge layout, ripple feedback, and appropriate Material transitions.

## 5. Transaction model and validation

Each transaction stores:

- A required positive amount in integer cents.
- A required calendar date.
- A required top-level type: `income` or `expense`.
- A required second-level category.
- An optional third-level category.
- An optional note.
- Internal creation and modification timestamps.

Rules:

- The amount field always contains a positive value. Income/expense determines direction.
- Minimum amount is greater than `¥0.00`.
- Maximum amount is `¥999,999,999.99`.
- At most two decimal places are allowed.
- Reject negative signs, scientific notation, and an isolated decimal point.
- Store money as integer cents, never floating-point currency.
- Notes may be empty and are limited to 200 Unicode characters.
- The form may show up to three visible note lines and scroll beyond that.
- The list shows a one-line, ellipsized note; editing shows the complete note.
- Existing transactions can be edited.
- Existing transactions can be deleted after confirmation.
- Edits and deletes immediately affect the relevant monthly statistics.
- Future-dated transactions are not allowed.

## 6. Category model

### 6.1 Hierarchy

- Level 1 is fixed to `Income` and `Expense`.
- Level 1 values are immutable enum values, not rows in the category table.
- There are no default level-2 or level-3 categories.
- Every level-2 and level-3 category is user-created.
- A level-2 category belongs to either income or expense and is mandatory for a transaction.
- A level-3 category belongs to one level-2 category and is optional for a transaction.
- The hierarchy stops at level 3.
- A user with no level-2 category must create one before saving a transaction.
- Category creation is available both inline from the transaction form and from the category management page.

### 6.2 Names and ordering

- Category names contain 1–30 Unicode characters after trimming outer whitespace.
- Names must be unique among siblings, ignoring outer whitespace and English letter case.
- Identical names are allowed under different parents.
- There is no drag-to-reorder behavior in the MVP.
- Category management and category selectors use creation order, oldest first, to avoid locale-dependent ordering.

### 6.3 Renaming, deleting, and migrating

- Categories can be renamed and deleted.
- Renaming changes the name shown on historical transactions because transactions reference category identity rather than storing a category-name snapshot.
- Category migration may never cross the `Income` / `Expense` boundary.
- All delete and migration operations must be atomic database transactions: everything succeeds or nothing changes.

Deleting a level-2 category offers two whole-subtree choices:

1. Delete the level-2 category, all of its level-3 children, and all transactions in that subtree.
2. Select one target level-2 category of the same income/expense type, migrate the complete subtree and its transactions, then delete the source.

The MVP does not provide per-record or per-child selection during ordinary subtree migration.

Deleting a level-3 category offers these outcomes:

- Delete the category and its transactions.
- Move its transactions elsewhere within the same income/expense side.
- The target can be another level-3 category, or a level-2 category with no level-3 category selected; this permits a transaction to become "level 2 only."

If a whole level-2 migration would place same-named level-3 categories under the target parent, do not silently merge, silently rename, or reject the entire workflow without guidance. Present every conflict separately. Each conflict must be resolved by the user as one of:

- `Merge`: explicitly merge the source level-3 category and its transactions into the existing target category.
- `Rename & move`: enter a non-conflicting name, then migrate it as an independent category.

All conflicts must be resolved before the migration can be committed atomically. The migration conflict workflow does not offer deletion, preventing a user from accidentally deleting records while believing they are migrating them.

### 6.4 Destructive-action safeguards

- Deleting one transaction uses a confirmation dialog.
- Before cascading category deletion, show the exact number of child categories and transactions that will be deleted, then require explicit confirmation.
- The MVP has no recycle bin or general undo history.
- Statistics refresh immediately after a successful delete or migration.

## 7. Transactions destination UX

- The default screen shows transactions for the selected month, newest dates first.
- Group list items by date; within a day, order by creation time descending.
- Use compact Material `ListTile`-style rows, not a separate card for every record.
- Each row shows the level-2 and optional level-3 category path, for example `Food · Lunch`.
- The optional note appears as one secondary line.
- The amount is trailing and includes an explicit `+` or `−` sign.
- Do not show daily subtotals in the MVP.
- A Material `FloatingActionButton` starts a new transaction.
- The create/edit form is a modal bottom sheet reused for both operations.
- Tapping an existing transaction opens the edit form.
- Deletion is available from the edit flow and requires confirmation.

Suggested form behavior already accepted:

- Use a `SegmentedButton` for `Expense / Income`.
- Use a Material `DropdownMenu` for the level-2 category, with an adjacent add action.
- Enable the level-3 selector only after a level-2 category is selected.
- Level 3 includes a `None` value and an adjacent add action.
- New category creation uses a short dialog and automatically selects the created category.
- Changing income/expense or level 2 clears any now-invalid lower-level selection.

Empty and first-run behavior:

- Do not create a multi-page onboarding flow.
- Show a concise empty state with an `Add transaction` action.
- If the selected income/expense side has no level-2 categories, the form shows `Create category` as the primary category action.

## 8. Month and date navigation

- The Transactions and Statistics destinations share the same month-selector behavior.
- Show a compact month/year label, such as `September 2026`, with previous and next arrows.
- Disable moving forward when the current month is selected; future months are not browsable.
- Tapping the label opens a year/month selection dialog for faster historical navigation.
- The transaction list only loads the selected month.
- When adding in the current month, default the date to today.
- When adding while viewing a past month, use today's day number in that month; if the day does not exist, clamp it to the month's final day. Example: on September 30, adding in February defaults to February 28 or 29.
- After saving, remain in the selected month so the new record stays visible.
- Monthly membership is based on the device's local calendar/time zone.

## 9. Statistics destination UX and calculations

- Statistics are monthly and text-only; do not add charts in the MVP.
- At the top show total income, total expense, and balance (`income − expense`).
- Below, present separate Income and Expense sections.
- Each level-2 category shows its monthly amount and percentage of the corresponding income or expense total.
- Indent level-3 rows beneath their level-2 parent and show their amounts and percentages using the same-side total as the denominator.
- Transactions that have a level-2 category but no level-3 category appear under an `Uncategorized` or equivalent `Not further categorized` row within that level-2 group. Final English wording remains to be polished.
- Categories with zero amount in the selected month are hidden.
- If the applicable total is zero, do not calculate or display an invalid percentage.
- No chart, dashboard metric-card grid, budget comparison, or cross-month trend is part of the MVP.

## 10. Category management UX

- Open category management from a category action in the Transactions app bar.
- Use a standalone auxiliary page.
- Use a Material `SegmentedButton` to switch between `Expense` and `Income`.
- Use a compact expandable hierarchy for level-2 categories and their level-3 children.
- Provide add, rename, and delete actions at the appropriate levels.
- Keep this page out of the primary bottom/rail navigation.

## 11. Persistence and technical architecture

- Persist data locally in SQLite through Drift.
- Drift was selected for type-safe queries, reactive streams, transactions, and schema migration tooling.
- Preserve stable record identity plus creation and modification timestamps so future sync is not needlessly blocked, but do not implement sync now.
- Use Drift streams to refresh transaction and statistics views after writes.
- Do not introduce Riverpod, Bloc, or another state-management package in the MVP.
- Use Flutter's built-in `StatefulWidget`, `ValueNotifier`, `StreamBuilder`, and constructor injection for UI/transient state and dependencies.
- Use a pragmatic feature-first structure.
- Use repository boundaries around persistence.
- Add application services only where genuine multi-entity rules require them, especially category migration/deletion.
- Do not create one-use-case classes or pass-through interfaces merely to imitate strict Clean Architecture.
- Do not introduce a routing package unless later requirements exceed Flutter's built-in navigation needs.

Proposed project layout:

```text
ledger/
├── AGENTS.md
├── INITIAL.md
├── README.md
├── TODO.md
├── docs/
│   ├── product-spec.md
│   ├── architecture.md
│   ├── progress.md
│   ├── session-notes/
│   └── decisions/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── ledger_app.dart
│   │   ├── app_shell.dart
│   │   └── theme/
│   ├── core/
│   │   ├── database/
│   │   │   ├── tables/
│   │   │   ├── daos/
│   │   │   └── migrations/
│   │   ├── money/
│   │   └── time/
│   ├── features/
│   │   ├── transactions/
│   │   │   ├── data/
│   │   │   ├── application/
│   │   │   └── presentation/
│   │   ├── categories/
│   │   │   ├── data/
│   │   │   ├── application/
│   │   │   └── presentation/
│   │   └── statistics/
│   │       ├── data/
│   │       └── presentation/
│   ├── shared/widgets/
│   └── l10n/app_en.arb
├── test/
├── integration_test/
└── drift_schemas/
```

Do not create empty directories merely to make the tree look complete. Add a layer only when it has an actual responsibility. Tests should broadly mirror the relevant source feature structure.

## 12. Testing and quality gates

Required test scope:

- Unit tests for money, dates, category validation, monthly statistics, deletion, migration, and conflict handling.
- Drift tests for schema constraints, foreign keys, transactions, queries, and migrations.
- Widget tests for first-run/empty states, the transaction form, category management, and text statistics.
- One Android integration path covering: create categories → add transaction → view statistics → edit transaction → delete transaction.
- Prefer risk-based coverage over chasing an arbitrary percentage.

Before completing any implementation stage:

- Format the code.
- Run static analysis.
- Run all tests relevant to the changed behavior.
- Verify the stage on Android.
- Record exact verification results in project progress and the current session note.

## 13. Planned implementation stages

These stages are a plan, not authorization. A stage begins only after an explicit user command.

### Stage 1 — Foundation

- Create the Flutter Android project.
- Establish Material 3 theming, system light/dark behavior, and dynamic color fallback.
- Configure English localization.
- Build the two-destination responsive shell using NavigationBar/NavigationRail.
- Establish formatting, linting, testing, and build baselines.

### Stage 2 — Categories

- Add Drift and the initial database schema.
- Implement repositories and category application rules.
- Implement category create, rename, delete, subtree migration, and per-conflict resolution.
- Add associated unit, database, and widget tests.

### Stage 3 — Transactions

- Implement shared month navigation.
- Implement monthly transaction list and date grouping.
- Implement create/edit bottom-sheet form and inline category creation.
- Implement transaction deletion and relevant tests.

### Stage 4 — Statistics

- Implement monthly totals, balance, hierarchical category amounts, uncategorized rows, and percentages.
- Implement zero and empty states.
- Add calculation, query, and widget tests.

### Stage 5 — Hardening

- Complete Drift migration tests and schema snapshots.
- Complete critical widget and Android integration coverage.
- Verify accessibility, touch targets, keyboard behavior, errors, loading states, empty states, and responsive layouts.
- Verify Android manifest privacy boundaries and release build behavior.
- Reconcile documentation with the implemented result.

Every stage must be independently demonstrable and verified before proceeding to the next.

## 14. Project documentation and agent-governance rules

### 14.1 Document responsibilities

- `AGENTS.md`: stable project-specific instructions for coding agents; do not duplicate the full product specification.
- `README.md`: project introduction plus run, test, and build instructions.
- `TODO.md`: a reminder list for the user, never an autonomous agent work queue.
- `docs/product-spec.md`: the single source of truth for accepted product behavior.
- `docs/architecture.md`: architecture, data model, and source-boundary documentation.
- `docs/progress.md`: a replaceable snapshot of the current project state.
- `docs/session-notes/`: chronological work-session records.
- `docs/decisions/`: durable architecture decision records for important long-lived tradeoffs.
- `INITIAL.md`: this one-time planning/first-development handoff; after the project begins, maintained specifications and progress documents supersede it.

### 14.2 Start-of-session reads

At the start of ordinary project work, read:

1. `AGENTS.md`
2. `docs/product-spec.md`
3. `docs/progress.md`

Do not automatically read `TODO.md`.

Do not automatically read any session note. If current documents are insufficient and session history is genuinely needed, `progress.md` should link to the newest session note. Read at most that newest note. Do not scan or bulk-read older notes. Read an older note only when the user explicitly asks or the newest note identifies a specific older note as required context.

### 14.3 TODO authority boundary

`TODO.md` is for the user. Its content does not authorize implementation, planning, edits, or other action.

Use stable identifiers and two sections:

```md
## User Tasks
- [ ] T-001 ...

## Suggested
- [ ] S-001 ...
```

- The agent may write a `Suggested` item as a reminder.
- The agent must not execute either a `T-*` or `S-*` item unless the user explicitly names and requests that item.
- Merely reading a TODO item does not authorize acting on it.
- Do not mark an item in progress unless the user has explicitly ordered its implementation.
- Once the user has explicitly authorized a specific item, its status may be updated to reflect that authorized work.

### 14.4 Progress document

`docs/progress.md` is a current snapshot, not a chronological log. It contains only:

- Current phase.
- Completed capabilities.
- Work explicitly in progress.
- Blockers.
- Most recent verification results.
- Candidate next step.
- Last-updated time and a link to the newest session note.

A candidate next step is context only and never grants execution authority. Historical detail belongs in Git and session notes.

### 14.5 Session notes

Create one new note for each substantive work session using:

`docs/session-notes/YYYY-MM-DD-HHMM-short-topic.md`

Do not rewrite old notes. Each note contains:

1. `Goal`: the user's explicit request.
2. `Context read`: project documents actually read.
3. `Changes`: code and documentation changes.
4. `Decisions`: decisions added or revised.
5. `Verification`: commands/checks and their results.
6. `Handoff`: current state, unresolved issues, and a safe candidate next step.

`Handoff` provides context only; it does not authorize autonomous continuation.

### 14.6 Documentation updates

- Change `product-spec.md` whenever accepted product behavior changes.
- Change `architecture.md` when architecture, data models, or source boundaries change.
- Add an ADR for important long-lived tradeoffs; do not erase old decisions to hide history.
- At the end of substantive authorized work, update `progress.md` and add a session note.
- Keep documentation changes in the same commit as the corresponding authorized code changes when commits are part of the user's request.

### 14.7 Project prompt content for `AGENTS.md`

The future `AGENTS.md` should include these stable instructions:

- Read the required current-state documents before work.
- Treat `product-spec.md` as the product-behavior source of truth.
- Enforce the TODO authority boundary exactly.
- Preserve the agreed MVP scope, Material 3, Android-first behavior, and English-only UI.
- Require a Drift migration and migration tests for schema changes.
- Synchronize accepted behavior changes into the specification.
- Update progress and session notes after substantive work.
- Format, analyze, and test relevant changes before completion.
- Do not add complexity or dependencies without a concrete requirement and stated reason.
- Preserve user changes and do not take destructive action without explicit scope and safeguards.

### 14.8 Conflict precedence

When facts conflict, use this precedence:

1. The user's explicit instruction in the current conversation.
2. `AGENTS.md` stable work rules.
3. `docs/product-spec.md` product behavior.
4. `docs/architecture.md` and accepted ADRs.
5. `docs/progress.md` current-state facts.
6. `INITIAL.md` initial snapshot.
7. The newest session note, when legitimately read.
8. `TODO.md`, which remains a reminder and never grants execution authority.

Do not silently choose between meaningful conflicts. Report the conflict and ask the user unless one document is obviously stale and safely correctable as part of already authorized work.

## 15. Decisions still open for the next discussion

The grilling session was intentionally stopped before implementation. At minimum, consider resolving these items before authorizing Stage 1:

- Exact fallback Material 3 seed/color scheme when dynamic color is unavailable.
- Exact visual semantics for income and expense amounts without misusing Material error colors.
- Exact database schema details: identifier representation, date representation, normalized-name storage, indexes, foreign-key actions, and timestamp format.
- Whether generated Drift files are committed or regenerated locally/CI.
- Exact Flutter/Dart version policy and dependency pinning/update policy.
- Lint configuration and continuous-integration expectations, if CI is wanted for the MVP.
- Exact loading, recoverable-error, database-open-failure, and write-failure UX.
- Accessibility acceptance details beyond standard Material behavior.
- Final wording for English empty states, deletion warnings, migration conflicts, and the no-third-level statistics row.
- Whether a single selected month is shared between the Transactions and Statistics destinations or each destination preserves its own selected month.
- Whether transaction deletion is exposed only inside edit mode or also through another explicit action; avoid accidental swipe deletion unless deliberately chosen.
- Whether a category-management entry also appears in an overflow menu on the Statistics destination.
- Final package/dependency list after checking current official documentation at implementation time.
- Git/commit and CI conventions, if the user wants them documented.

Continue asking one question at a time and recommend an answer. Do not reopen decisions above unless a newly discovered conflict or requirement requires it.

## 16. Explicit non-authorization statement

Creating or reading this file does not authorize:

- Flutter project scaffolding.
- Dependency installation.
- Source-code creation or modification.
- Database creation or migration.
- Android manifest changes.
- Running an implementation stage.
- Acting on any TODO item.

Only a new, explicit user instruction may authorize those actions.
