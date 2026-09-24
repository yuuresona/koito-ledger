# Ledger project guidance

At the start of ordinary project work, read `AGENTS.md`, `docs/product-spec.md`, and `docs/progress.md`. Read the newest session note only when those documents leave a genuine gap. Do not routinely read `TODO.md` or old session notes.

`docs/product-spec.md` is the source of truth for accepted product behavior. Preserve the Android-first, offline MVP, English-only interface, Material 3 design, and the scope defined there. Keep visible strings in Flutter localization resources.

`TODO.md` is a user-owned reminder. Neither its `User Tasks` nor its `Suggested` items authorize action. Work on a `T-*` or `S-*` item only when the user explicitly names and requests it. Do not mark an item in progress without that request. Candidate next steps in project documents also do not authorize work.

Use Drift migrations and migration tests for every database schema change. Keep accepted behavior changes synchronized with the product specification and architectural changes synchronized with `docs/architecture.md` or an ADR. Update `docs/progress.md` and add one new session note after substantive work.

Format, analyze, and test the relevant changes before completion. Verify implementation stages on Android when tooling is available, and record exact results and blockers. Add dependencies or layers only for a concrete requirement with a stated reason. Preserve user changes; do not take destructive actions without explicit scope and safeguards.

When documents disagree, follow the current user instruction, then this file, the product specification, architecture and ADRs, progress, `INITIAL.md`, the newest legitimately read session note, and finally `TODO.md`. Report meaningful conflicts that cannot safely be resolved as stale documentation.
