# Deterministic randomized stress testing completed

**Date:** 2026-09-25 11:14 CST

## Scope and method

- Added four offline stress-test modules without changing production behavior or dependencies.
- Used fixed seeds and included the seed plus failing iteration in assertion diagnostics so every generated failure is reproducible.
- Kept the campaign test-driven: each new stress module was formatted, statically analyzed, and run independently before it entered the combined stress and complete regression suites.
- Counted 279,014 top-level randomized or exhaustive cases. Several cases contain additional rows or assertions, including up to 400 transactions per statistics dataset and multiple transactions per category-migration scenario.

## Domain and arithmetic coverage

- Seed `0x4C454447`: 50,000 valid amount strings round-tripped exactly and 30,000 malformed, signed, exponent, over-precision, non-ASCII-digit, or out-of-range strings were rejected.
- Seed `0x43415445`: 20,000 Unicode category names verified trimming, ASCII case folding, and grapheme-count preservation.
- Exhaustively round-tripped all 73,414 calendar dates from 1900-01-01 through 2100-12-31.
- Seed `0x44415445`: 50,000 month-default calculations remained inside the selected month with correct end-of-month clamping.
- Seed `0x53544154`: 1,000 generated statistics datasets verified income, expense, balance, hierarchy totals, mixed direct/subcategory assignments, ordering, and permutation invariance.
- Seed `0x50435447`: 50,000 large percentage calculations matched an independent rational-arithmetic oracle, including the `<0.01%` boundary.

## Persistence and migration coverage

- Seed `0x5354415445`: 2,500 randomized transaction creates, updates, and deletes were repeatedly reconciled against an independent in-memory model over every month from January 2025 through September 2026.
- Seed `0x494E56414C4944`: 500 invalid writes exercised zero/oversized amounts, future dates, wrong-side categories, mismatched subcategories, and overlong Unicode notes; every rejection left the transaction table unchanged.
- Seed `0x4452414654`: 1,000 draft round trips and 100 category-deletion scenarios verified persisted draft fidelity and foreign-key sanitation.
- Seed `0x4D494752415445`: 250 randomized level-2 subtree migrations mixed conflict merges and rename-and-move resolutions while preserving every transaction, subcategory target, and cent.
- Seed `0x43524F5353545950`: 200 cross-type category migrations were rejected atomically without changing categories or transactions.
- Seed `0x534348454D415631`: 50 randomized schema-v1 databases migrated to schema v2 with field-by-field preservation of categories, transactions, Unicode notes, foreign keys, and usability of the new draft table.

## Verification results

- Each of the four targeted stress modules passed independently.
- `flutter test test/stress --concurrency=1`: all 13 stress tests passed in about 29 seconds.
- `flutter test --concurrency=1`: all 67 project tests passed in about 75 seconds.
- `flutter analyze`: passed with no issues.
- `git diff --check`: passed.
- No product defect was found, so no production code or accepted product behavior changed during this campaign.

## Android and handoff

- The existing Stage 4 debug APK was not rebuilt because only tests and documentation changed. Its last verified SHA-256 remains `601bf9a484f5637c92746ae66f63a202b078f0e69f139632ca4fd719b7843996`.
- Runtime verification remains unavailable locally because hardware virtualization support is absent; USB automation remains suspended because libusb enumeration resets the host USB controller. No USB command was run.
- The MVP automated verification baseline is complete. Manual Android smoke testing, a baseline commit, and any release packaging require separate user authorization.
