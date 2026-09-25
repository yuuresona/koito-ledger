# Repository privacy hardening

**Date:** 2026-09-25 13:17 CST

## Scope

- Audited the tracked tree and all reachable Git commits for common tokens, embedded credentials, private keys, signing files, local databases, release packages, oversized blobs, personal addresses in files, absolute home paths, host names, and machine-specific verification details.
- Kept this task separate from application behavior: no product capability, database schema, dependency version, or runtime permission changed.
- Treated absolute security as unattainable; the objective is to remove observed exposure and add layered prevention with explicit remaining limits.

## Hardening changes

- Expanded `.gitignore` to cover environment files, credential stores, common private-key and signing formats, service configuration files, local databases, APKs, and app bundles. Existing Flutter, build, local-tooling, Android SDK, and generated-local-file exclusions remain in place.
- Replaced verification-machine, USB-controller, virtualization-path, test-device model, process-ID, and timing details with environment-neutral verification statements while preserving whether each validation passed or was unavailable.
- Changed hosted dependency records from the environment-specific mirror to the official `https://pub.dev` source without changing the resolved dependency versions or hashes.
- Configured only this local clone to use a noreply commit address and to scope any future HTTPS credential-helper entries by full repository path. No credential helper was installed and no token was persisted by this task.

## Audit result and remaining boundary

- No GitHub token, password, embedded-authentication URL, SSH/private key, Android signing key, `.env` file, local ledger database, APK/AAB, build directory, or user transaction data was found in the reachable repository history.
- The largest reachable blob is generated database code at approximately 115 KB; no suspicious large artifact was found.
- The already published commits still contain the earlier personal author address in commit metadata and earlier revisions of the machine-specific documentation. A normal follow-up commit cannot remove historical objects.
- Removing those historical values requires rewriting every published commit and force-pushing `main`, which changes commit IDs and can disrupt other clones. No history rewrite, force push, or remote mutation was performed without explicit authorization.

## Verification

- Official-source `flutter pub get`: passed; resolved versions and package hashes remained unchanged.
- Hardened ignore-rule probes: passed for environment files, credential JSON, common private/signing keys, Android keystores, local databases, APKs, app bundles, and Android SDK configuration.
- Current-tree machine-fingerprint scan: passed with no retained machine-specific identifier.
- `flutter analyze`: passed with no issues.
- `flutter test --concurrency=1`: all 67 tests passed.
- `git diff --check`: passed.
