import 'dart:math';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/database/app_database.dart';

import '../generated_migrations/schema.dart';
import '../generated_migrations/schema_v1.dart' as v1;

const _schemaMigrationSeed = 0x534348454D415631;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('50 randomized v1 databases migrate to v2 without data loss', () async {
    final random = Random(_schemaMigrationSeed);

    for (var iteration = 0; iteration < 50; iteration++) {
      final schema = await verifier.schemaAt(1);
      final oldDatabase = v1.DatabaseAtV1(schema.newConnection());
      final expectedCategories =
          <
            ({
              int id,
              String name,
              String normalizedName,
              int entryType,
              int? parentId,
              int createdAt,
              int updatedAt,
            })
          >[];
      final expectedTransactions =
          <
            ({
              int id,
              int amountCents,
              int dateEpochDay,
              int entryType,
              int categoryId,
              int? subcategoryId,
              String? note,
              int createdAt,
              int updatedAt,
            })
          >[];
      final childrenByParent = <int, List<int>>{};
      var nextCategoryId = 1;

      final parentCount = random.nextInt(8) + 2;
      for (var parentIndex = 0; parentIndex < parentCount; parentIndex++) {
        final entryType = random.nextInt(2);
        final parentId = nextCategoryId++;
        final parentName = 'p-$iteration-$parentIndex';
        final createdAt = random.nextInt(1000000000) + 1;
        final updatedAt = createdAt + random.nextInt(10000);
        expectedCategories.add((
          id: parentId,
          name: parentName,
          normalizedName: parentName,
          entryType: entryType,
          parentId: null,
          createdAt: createdAt,
          updatedAt: updatedAt,
        ));
        await _insertCategory(
          oldDatabase,
          id: parentId,
          name: parentName,
          entryType: entryType,
          parentId: null,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final children = <int>[];
        final childCount = random.nextInt(6);
        for (var childIndex = 0; childIndex < childCount; childIndex++) {
          final childId = nextCategoryId++;
          final childName = 'c-$iteration-$parentIndex-$childIndex';
          final childCreatedAt = random.nextInt(1000000000) + 1;
          final childUpdatedAt = childCreatedAt + random.nextInt(10000);
          children.add(childId);
          expectedCategories.add((
            id: childId,
            name: childName,
            normalizedName: childName,
            entryType: entryType,
            parentId: parentId,
            createdAt: childCreatedAt,
            updatedAt: childUpdatedAt,
          ));
          await _insertCategory(
            oldDatabase,
            id: childId,
            name: childName,
            entryType: entryType,
            parentId: parentId,
            createdAt: childCreatedAt,
            updatedAt: childUpdatedAt,
          );
        }
        childrenByParent[parentId] = children;
      }

      final parents = expectedCategories
          .where((category) => category.parentId == null)
          .toList();
      final transactionCount = random.nextInt(76) + 25;
      for (
        var transactionIndex = 0;
        transactionIndex < transactionCount;
        transactionIndex++
      ) {
        final parent = parents[random.nextInt(parents.length)];
        final children = childrenByParent[parent.id]!;
        final subcategoryId = children.isNotEmpty && random.nextBool()
            ? children[random.nextInt(children.length)]
            : null;
        final id = transactionIndex + 1;
        final amountCents = random.nextInt(1000000000) + 1;
        final dateEpochDay = random.nextInt(73414) - 25567;
        final note = switch (random.nextInt(5)) {
          0 => null,
          1 => '',
          2 => 'ASCII-$iteration-$transactionIndex',
          3 => '账目-${random.nextInt(100000)}',
          _ => 'e\u0301-${random.nextInt(100000)}',
        };
        final createdAt = random.nextInt(1000000000) + 1;
        final updatedAt = createdAt + random.nextInt(10000);
        expectedTransactions.add((
          id: id,
          amountCents: amountCents,
          dateEpochDay: dateEpochDay,
          entryType: parent.entryType,
          categoryId: parent.id,
          subcategoryId: subcategoryId,
          note: note,
          createdAt: createdAt,
          updatedAt: updatedAt,
        ));
        await oldDatabase.customStatement(
          'INSERT INTO ledger_transactions '
          '(id, amount_cents, date_epoch_day, entry_type, category_id, '
          'subcategory_id, note, created_at_micros, updated_at_micros) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            id,
            amountCents,
            dateEpochDay,
            parent.entryType,
            parent.id,
            subcategoryId,
            note,
            createdAt,
            updatedAt,
          ],
        );
      }
      await oldDatabase.close();

      final database = AppDatabase.forTesting(schema.newConnection());
      await verifier.migrateAndValidate(database, 2);

      final categories = await database.select(database.categoryRecords).get();
      final transactions = await database
          .select(database.ledgerTransactions)
          .get();
      expect(
        categories,
        hasLength(expectedCategories.length),
        reason: 'seed=$_schemaMigrationSeed iteration=$iteration categories',
      );
      expect(
        transactions,
        hasLength(expectedTransactions.length),
        reason: 'seed=$_schemaMigrationSeed iteration=$iteration transactions',
      );

      final categoriesById = {for (final row in categories) row.id: row};
      for (final expected in expectedCategories) {
        final actual = categoriesById[expected.id];
        expect(actual, isNotNull);
        expect(actual!.name, expected.name);
        expect(actual.normalizedName, expected.normalizedName);
        expect(actual.entryType, expected.entryType);
        expect(actual.parentId, expected.parentId);
        expect(actual.createdAtMicros, expected.createdAt);
        expect(actual.updatedAtMicros, expected.updatedAt);
      }

      final transactionsById = {for (final row in transactions) row.id: row};
      for (final expected in expectedTransactions) {
        final actual = transactionsById[expected.id];
        expect(actual, isNotNull);
        expect(actual!.amountCents, expected.amountCents);
        expect(actual.dateEpochDay, expected.dateEpochDay);
        expect(actual.entryType, expected.entryType);
        expect(actual.categoryId, expected.categoryId);
        expect(actual.subcategoryId, expected.subcategoryId);
        expect(actual.note, expected.note);
        expect(actual.createdAtMicros, expected.createdAt);
        expect(actual.updatedAtMicros, expected.updatedAt);
      }

      final draftParent = parents[random.nextInt(parents.length)];
      final draftChildren = childrenByParent[draftParent.id]!;
      final draftChild = draftChildren.isEmpty
          ? null
          : draftChildren[random.nextInt(draftChildren.length)];
      await database
          .into(database.transactionDraftRecords)
          .insert(
            TransactionDraftRecordsCompanion.insert(
              id: const Value(1),
              amountText: 'iteration-$iteration',
              entryType: draftParent.entryType,
              categoryId: Value(draftParent.id),
              subcategoryId: Value(draftChild),
              note: '迁移草稿-$iteration',
              updatedAtMicros: iteration + 1,
            ),
          );
      final draft = await database
          .select(database.transactionDraftRecords)
          .getSingle();
      expect(draft.amountText, 'iteration-$iteration');
      expect(draft.categoryId, draftParent.id);
      expect(draft.subcategoryId, draftChild);

      await database.close();
    }
  });
}

Future<void> _insertCategory(
  v1.DatabaseAtV1 database, {
  required int id,
  required String name,
  required int entryType,
  required int? parentId,
  required int createdAt,
  required int updatedAt,
}) {
  return database.customStatement(
    'INSERT INTO categories '
    '(id, name, normalized_name, entry_type, parent_id, '
    'created_at_micros, updated_at_micros) '
    'VALUES (?, ?, ?, ?, ?, ?, ?)',
    [id, name, name, entryType, parentId, createdAt, updatedAt],
  );
}
