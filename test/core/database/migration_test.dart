import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/database/app_database.dart';

import '../../generated_migrations/schema.dart';
import '../../generated_migrations/schema_v1.dart' as v1;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('schema version 2 matches its committed snapshot', () async {
    final schema = await verifier.schemaAt(2);
    final database = AppDatabase.forTesting(schema.newConnection());

    await verifier.migrateAndValidate(database, 2);

    await database.close();
  });

  test(
    'migration from version 1 preserves categories and transactions',
    () async {
      final schema = await verifier.schemaAt(1);
      final oldDatabase = v1.DatabaseAtV1(schema.newConnection());
      await oldDatabase.customStatement(
        'INSERT INTO categories '
        '(id, name, normalized_name, entry_type, parent_id, '
        'created_at_micros, updated_at_micros) '
        'VALUES (?, ?, ?, ?, NULL, ?, ?)',
        [1, 'Food', 'food', 0, 100, 100],
      );
      await oldDatabase.customStatement(
        'INSERT INTO ledger_transactions '
        '(id, amount_cents, date_epoch_day, entry_type, category_id, '
        'subcategory_id, note, created_at_micros, updated_at_micros) '
        'VALUES (?, ?, ?, ?, ?, NULL, ?, ?, ?)',
        [1, 1234, 20721, 0, 1, 'Lunch', 200, 200],
      );
      await oldDatabase.close();

      final database = AppDatabase.forTesting(schema.newConnection());
      await verifier.migrateAndValidate(database, 2);

      final category = await database
          .select(database.categoryRecords)
          .getSingle();
      final transaction = await database
          .select(database.ledgerTransactions)
          .getSingle();
      expect(category.name, 'Food');
      expect(transaction.amountCents, 1234);
      expect(transaction.note, 'Lunch');

      await database
          .into(database.transactionDraftRecords)
          .insert(
            const TransactionDraftRecordsCompanion(
              id: Value(1),
              amountText: Value('12.34'),
              entryType: Value(0),
              note: Value('Draft'),
              updatedAtMicros: Value(300),
            ),
          );
      expect(
        (await database.select(database.transactionDraftRecords).getSingle())
            .amountText,
        '12.34',
      );

      await database.close();
    },
  );
}
