# Ledger

Ledger is a local-first, offline Android bookkeeping app built with Flutter. Its MVP records categorized income and expenses and shows text-only monthly statistics.

## Requirements

- Flutter SDK and the Android toolchain. The foundation was generated and checked with Flutter 3.47.5 and Dart 3.13.4. See [Flutter's Android setup guide](https://docs.flutter.dev/platform-integration/android/setup).
- An Android emulator or device for the stage verification.

## Run

```sh
flutter pub get
dart run build_runner build
flutter build apk --debug
adb install --no-streaming -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n site.yukiho.ledger/.MainActivity
```

The app requests no Android network permission, including in debug builds. Install and launch the APK with `adb`; Flutter's network-based debug service and hot reload are not available with this manifest.

## Check

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

When the Drift schema changes, increment the database schema version, write the migration, then refresh the committed schema and migration helpers:

```sh
dart run drift_dev make-migrations
dart run drift_dev schema generate --data-classes --companions \
  drift_schemas/app_database test/generated_migrations
```

The Android app ID is `site.yukiho.ledger`. The Dart package name is `ledger`.

Accepted behavior is in [docs/product-spec.md](docs/product-spec.md). Architecture and current progress are in [docs/architecture.md](docs/architecture.md) and [docs/progress.md](docs/progress.md).
