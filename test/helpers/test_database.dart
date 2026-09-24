import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ledger/core/database/app_database.dart';

AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(
    DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ),
  );
}
