# Published-history sanitization

**Date:** 2026-09-25 15:07 CST

## Scope and safeguards

- Rewrote the six commits reachable from `main` under the user's explicit authorization so previously published personal and machine-specific metadata is not retained in the replacement branch.
- Created and verified a complete Git bundle before rewriting. It was stored outside the repository with mode `600` until remote verification completed, then deleted during local cleanup.
- Pinned the final remote update to the exact audited former tip, preventing an unexpected remote commit from being overwritten. Commit identifiers are intentionally omitted so obsolete hosted objects are not directly addressable from current documentation.

## Rewrite result

- Replaced the earlier personal author and committer address with `yuuresona@users.noreply.github.com`; GitHub's own `noreply@github.com` committer metadata remains unchanged.
- Removed the observed test-device model, host-controller model, virtualization device path, launch timing, process identifier, and environment-specific dependency mirror from every rewritten revision.
- Preserved all six commits, the one merge, commit messages and dates, and the exact final source tree. Commit IDs necessarily changed because Git commit IDs cover parent IDs, trees, and metadata.
- Kept the product implementation and accepted behavior unchanged.

## Verification

- Rewritten-history metadata and content scans: passed with no former personal address or observed machine-specific value.
- Common token, private-key, embedded-credential, signing-key, local-database, release-artifact, and suspicious-path scans: passed with no match.
- Final-tree identity against the pre-rewrite tip: exact Git tree match.
- Dart formatting: 46 files checked, zero changed.
- `flutter analyze`: passed with no issues.
- `flutter test --concurrency=1`: all 67 tests passed, including the deterministic stress and migration suites.
- `git diff --check`: passed.

## Publication and cleanup

- The user's SSH-authenticated terminal published the replacement with a force-with-lease pinned to the audited former tip. GitHub reported the forced update, and an independent remote query returned the expected sanitized tip.
- The local tracking ref matched the verified remote tip, no `refs/original` entry remained, and the temporary recovery bundle and unreachable local objects were removed after verification.
- Replacing GitHub's branch removes the former history from normal repository navigation but cannot revoke copies already fetched by another clone or fork, and hosting-provider caches may persist temporarily.
