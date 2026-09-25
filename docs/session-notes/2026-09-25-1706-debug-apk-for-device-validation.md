# Debug APK for device validation

**Date:** 2026-09-25 17:06 CST

## Scope

- Built a fresh universal Android debug APK from the current MVP source for user-run physical-device validation.
- Did not change application source, accepted behavior, dependencies, database schema, or runtime permissions.
- Kept release signing out of scope; this artifact uses the standard Android debug certificate and must not be treated as a production release.

## Artifact

- Relative path: `build/app/outputs/flutter-apk/app-debug.apk`
- Size: 194,995,850 bytes (approximately 186 MiB).
- SHA-256: `b3e318e3ac583675199564aa6dedefaf9dac59d054a6fc1c705be8fd2e82062c`
- Package: `site.yukiho.ledger`
- Version: `0.1.0` (`versionCode` 1)
- Android SDK range: minimum API 24, target API 36.
- Native ABIs: `arm64-v8a`, `armeabi-v7a`, and `x86_64`.

## Verification

- Flutter debug APK build: passed.
- APK Signature Scheme V2 verification: passed with one Android debug signer.
- Zip alignment verification: passed.
- Merged manifest inspection: `android:allowBackup="false"`; no Android `INTERNET` permission.
- Launchable activity: `site.yukiho.ledger.MainActivity`.
- The most recent unchanged-source automated baseline remains static analysis with no issues and all 67 tests passing, including the deterministic randomized and migration suites.

## Pending manual result

- Streamed installation through the project-local ADB succeeded on the connected authorized Android device.
- A forced cold launch returned status `ok`; the package reported version `0.1.0` and `site.yukiho.ledger/.MainActivity` was the top resumed activity.
- The user reported that animations in the debug build feel heavy and occasionally janky compared with similar applications. This observation is recorded without assigning a cause; debug-mode overhead and application-level frame work still need to be measured separately.
- Exercise category creation, transaction creation/edit/delete, draft restoration, month navigation, and monthly statistics.
- Restart the app to verify local persistence, then report any visual, interaction, or data-consistency defect with reproduction steps.
