# Ledger Product Specification

Accepted MVP behavior. Changes to product behavior must be recorded here.

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
- When dynamic colors are unavailable, generate the light and dark Material 3 fallback schemes from Flutter's standard blue seed color in the centralized theme.
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
- Editing may change a transaction's date to any allowed past or current date. If the new date belongs to another month, saving switches the shared selected month to that month so the edited transaction remains visible.
- Existing transactions can be deleted after confirmation.
- Edits and deletes immediately affect the relevant monthly statistics.
- Future-dated transactions are not allowed.
- Dismissing an unsaved new-transaction form requires no discard confirmation. Preserve its amount, income/expense type, level-2 and level-3 selections, and note as a local draft; restore those fields when the new-transaction form is reopened, including after an app restart. The date is not part of the draft: each opening pre-fills the date from the currently selected month using the normal date-default rule, and the selected month does not change to follow a draft. The draft never appears in the transaction list or statistics.
- New transactions share one draft across income and expense; changing the type updates that same draft.
- There is only one add action: the Transactions destination's `FloatingActionButton`. If an unfinished new-transaction draft exists, tapping it restores that draft. After a successful save, the next tap opens a fresh form.
- The new-transaction form has a `Clear draft` text action. Activating it removes the unfinished draft and resets the form, including the date default derived from the currently selected month. It is not a second add entry point.
- If a category referenced by the new-transaction draft has since been deleted or migrated, preserve its amount, income/expense type, and note while clearing invalid category selections. If level 2 is invalid, also clear level 3; if only level 3 is invalid, keep level 2. Require a valid category selection before saving.
- Editing an existing transaction loads the original record into the form. Only pressing `Save` updates that record. Closing without saving leaves the original record unchanged and discards the unsaved edits; edit forms do not create drafts or show a discard confirmation.
- Successfully saving a new transaction clears the new-transaction draft.

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
- Income and expense amounts use normal theme text colors. Use the `Income` / `Expense` label and explicit `+` / `−` signs as the primary distinction; do not rely on red/green alone or use Material error color for ordinary expenses.
- Do not show daily subtotals in the MVP.
- A Material `FloatingActionButton` starts a new transaction.
- The create/edit form is a modal bottom sheet reused for both operations.
- Tapping an existing transaction opens the edit form.
- Deletion is available from the edit flow and requires confirmation.

Suggested form behavior already accepted:

- Use a `SegmentedButton` for `Expense / Income`.
- A fresh new-transaction form with no saved draft defaults to `Expense`. The user can switch to `Income`; level 2 still requires an explicit valid selection.
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

- The Transactions and Statistics destinations share both the month-selector behavior and one selected-month state. Switching destinations preserves the selected month.
- Each fresh app launch starts at the current month; the previously selected month is not persisted across launches.
- Show a compact month/year label, such as `September 2026`, with previous and next arrows.
- Disable moving forward when the current month is selected; future months are not browsable.
- Tapping the label opens a year/month selection dialog for faster historical navigation.
- The transaction list only loads the selected month.
- When adding in the current month, default the date to today.
- When adding while viewing a past month, use today's day number in that month; if the day does not exist, clamp it to the month's final day. Example: on September 30, adding in February defaults to February 28 or 29.
- After saving a new transaction, set the shared selected month to the saved transaction's date month so the new record remains visible, even if the user manually chose a different month in the form. This month selection persists while the app process remains active; a fresh app launch starts at the current month as stated above.
- Monthly membership is based on the device's local calendar/time zone.

## 9. Statistics destination UX and calculations

- Statistics are monthly and text-only; do not add charts in the MVP.
- At the top show total income, total expense, and balance (`income − expense`).
- Below, present separate Income and Expense sections.
- Each level-2 category shows its monthly amount and percentage of the corresponding income or expense total.
- Indent level-3 rows beneath their level-2 parent and show their amounts and percentages using the same-side total as the denominator.
- Show percentages to two decimal places (0.01% precision). For a nonzero share below 0.01%, display `<0.01%` rather than `0.00%`.
- Transactions that have a level-2 category but no level-3 category appear under a `No subcategory` (final wording TBD) row only when that level-2 category also has transactions assigned to level-3 categories in the selected month. If all its transactions are level-2 only, display just the level-2 total to avoid repeating the same amount.
- Categories with zero amount in the selected month are hidden.
- If the applicable total is zero, do not calculate or display an invalid percentage.
- If the selected month has no transactions, still show `Income ¥0.00`, `Expense ¥0.00`, and `Balance ¥0.00`, followed by `No transactions this month`; omit empty category lists.
- No chart, dashboard metric-card grid, budget comparison, or cross-month trend is part of the MVP.
- Income and expense totals use the same label-and-sign semantics as transaction rows, without color-only meaning.

## 10. Category management UX

- Open category management from a category action in the Transactions app bar.
- Use a standalone auxiliary page.
- Use a Material `SegmentedButton` to switch between `Expense` and `Income`.
- Use a compact expandable hierarchy for level-2 categories and their level-3 children.
- Provide add, rename, and delete actions at the appropriate levels.
- Keep this page out of the primary bottom/rail navigation.

## 11. Failure handling

- If saving a transaction or migrating categories fails, preserve all form inputs and the current page state, show a clear error, and allow a retry.
- If the database cannot be opened, show a blocking error page with a retry action.
- Never automatically erase or rebuild the database to recover from an open or write failure.
