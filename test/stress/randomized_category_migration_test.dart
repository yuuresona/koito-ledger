import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/database/app_database.dart';
import 'package:ledger/features/categories/application/category_application_service.dart';
import 'package:ledger/features/categories/data/category_repository.dart';
import 'package:ledger/features/categories/domain/category.dart';

import '../helpers/test_database.dart';

const _migrationSeed = 0x4D494752415445;
const _crossTypeSeed = 0x43524F5353545950;

void main() {
  test('250 randomized subtree migrations preserve transactions and cents', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = CategoryRepository(
      database,
      now: () => DateTime.utc(2026, 9, 25),
    );
    final service = CategoryApplicationService(
      database,
      now: () => DateTime.utc(2026, 9, 25, 12),
    );
    final random = Random(_migrationSeed);

    for (var iteration = 0; iteration < 250; iteration++) {
      final entryType = random.nextBool()
          ? EntryType.expense
          : EntryType.income;
      final source = await repository.createLevelTwo(
        entryType: entryType,
        name: 'source-$iteration',
      );
      final target = await repository.createLevelTwo(
        entryType: entryType,
        name: 'target-$iteration',
      );
      final resolutions = <int, CategoryConflictResolution>{};
      final expectedSubcategoryByTransaction = <int, int?>{};
      final expectedChildren = <int, String>{};
      final mergedSourceIds = <int>[];
      var expectedCents = 0;

      Future<int> insert({
        required int categoryId,
        required int? subcategoryId,
      }) async {
        final amount = random.nextInt(999999) + 1;
        final id = await _insertTransaction(
          database,
          entryType: entryType,
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          amountCents: amount,
          timestamp: 1789891200000000 + expectedSubcategoryByTransaction.length,
        );
        expectedSubcategoryByTransaction[id] = subcategoryId;
        expectedCents += amount;
        return id;
      }

      await insert(categoryId: source.id, subcategoryId: null);
      await insert(categoryId: target.id, subcategoryId: null);

      final childCount = random.nextInt(7) + 1;
      for (var childIndex = 0; childIndex < childCount; childIndex++) {
        final originalName = 'child-$iteration-$childIndex';
        final sourceChild = await repository.createLevelThree(
          parentId: source.id,
          name: originalName,
        );
        final hasConflict = random.nextBool();
        int expectedChildId;
        var expectedName = originalName;

        if (hasConflict) {
          final targetChild = await repository.createLevelThree(
            parentId: target.id,
            name: originalName.toUpperCase(),
          );
          expectedChildren[targetChild.id] = originalName.toUpperCase();
          if (random.nextBool()) {
            resolutions[sourceChild.id] = const MergeCategory();
            expectedChildId = targetChild.id;
            mergedSourceIds.add(sourceChild.id);
          } else {
            expectedName = 'moved-$iteration-$childIndex';
            resolutions[sourceChild.id] = RenameAndMoveCategory(expectedName);
            expectedChildId = sourceChild.id;
            expectedChildren[sourceChild.id] = expectedName;
          }

          for (var index = 0; index < random.nextInt(3); index++) {
            await insert(categoryId: target.id, subcategoryId: targetChild.id);
          }
        } else {
          expectedChildId = sourceChild.id;
          expectedChildren[sourceChild.id] = expectedName;
        }

        final sourceTransactionCount = random.nextInt(4) + 1;
        for (var index = 0; index < sourceTransactionCount; index++) {
          final transactionId = await insert(
            categoryId: source.id,
            subcategoryId: sourceChild.id,
          );
          expectedSubcategoryByTransaction[transactionId] = expectedChildId;
        }
      }

      final conflicts = await service.levelTwoMigrationConflicts(
        sourceId: source.id,
        targetId: target.id,
      );
      expect(
        conflicts.map((item) => item.source.id).toSet(),
        resolutions.keys.toSet(),
        reason: 'seed=$_migrationSeed iteration=$iteration conflicts',
      );

      await service.migrateLevelTwo(
        sourceId: source.id,
        targetId: target.id,
        resolutions: resolutions,
      );

      await expectLater(
        repository.getRecord(source.id),
        throwsA(
          isA<CategoryException>().having(
            (error) => error.problem,
            'problem',
            CategoryProblem.categoryNotFound,
          ),
        ),
        reason: 'seed=$_migrationSeed iteration=$iteration source removed',
      );
      for (final sourceId in mergedSourceIds) {
        await expectLater(
          repository.getRecord(sourceId),
          throwsA(isA<CategoryException>()),
          reason: 'seed=$_migrationSeed iteration=$iteration merged child',
        );
      }

      final records = await database.select(database.ledgerTransactions).get();
      expect(
        records,
        hasLength(expectedSubcategoryByTransaction.length),
        reason: 'seed=$_migrationSeed iteration=$iteration transaction count',
      );
      expect(
        records.fold<int>(0, (total, row) => total + row.amountCents),
        expectedCents,
        reason: 'seed=$_migrationSeed iteration=$iteration cents',
      );
      for (final record in records) {
        expect(
          record.categoryId,
          target.id,
          reason:
              'seed=$_migrationSeed iteration=$iteration tx=${record.id} parent',
        );
        expect(
          record.subcategoryId,
          expectedSubcategoryByTransaction[record.id],
          reason:
              'seed=$_migrationSeed iteration=$iteration tx=${record.id} child',
        );
      }

      final trees = await repository.listTrees(entryType);
      expect(trees, hasLength(1));
      expect(trees.single.category.id, target.id);
      expect(
        {for (final child in trees.single.children) child.id: child.name},
        expectedChildren,
        reason: 'seed=$_migrationSeed iteration=$iteration target tree',
      );

      await service.deleteLevelTwoWithSubtree(target.id);
      expect(await database.select(database.categoryRecords).get(), isEmpty);
      expect(await database.select(database.ledgerTransactions).get(), isEmpty);
    }
  });

  test('200 randomized cross-type migrations are atomic rejections', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = CategoryRepository(
      database,
      now: () => DateTime.utc(2026, 9, 25),
    );
    final service = CategoryApplicationService(database);
    final random = Random(_crossTypeSeed);

    for (var iteration = 0; iteration < 200; iteration++) {
      final sourceType = random.nextBool()
          ? EntryType.expense
          : EntryType.income;
      final targetType = sourceType == EntryType.expense
          ? EntryType.income
          : EntryType.expense;
      final source = await repository.createLevelTwo(
        entryType: sourceType,
        name: 'cross-source-$iteration',
      );
      final sourceChild = await repository.createLevelThree(
        parentId: source.id,
        name: 'cross-child-$iteration',
      );
      final target = await repository.createLevelTwo(
        entryType: targetType,
        name: 'cross-target-$iteration',
      );
      final transactionId = await _insertTransaction(
        database,
        entryType: sourceType,
        categoryId: source.id,
        subcategoryId: sourceChild.id,
        amountCents: random.nextInt(999999) + 1,
        timestamp: 1789891200000000 + iteration,
      );

      await expectLater(
        service.migrateLevelTwo(
          sourceId: source.id,
          targetId: target.id,
          resolutions: const {},
        ),
        throwsA(
          isA<CategoryException>().having(
            (error) => error.problem,
            'problem',
            CategoryProblem.crossTypeMigration,
          ),
        ),
        reason: 'seed=$_crossTypeSeed iteration=$iteration',
      );

      final persisted = await (database.select(
        database.ledgerTransactions,
      )..where((row) => row.id.equals(transactionId))).getSingle();
      expect(persisted.categoryId, source.id);
      expect(persisted.subcategoryId, sourceChild.id);
      expect(await repository.getRecord(source.id), isNotNull);
      expect(await repository.getRecord(sourceChild.id), isNotNull);
      expect(await repository.getRecord(target.id), isNotNull);

      await service.deleteLevelTwoWithSubtree(source.id);
      await service.deleteLevelTwoWithSubtree(target.id);
    }
  });
}

Future<int> _insertTransaction(
  AppDatabase database, {
  required EntryType entryType,
  required int categoryId,
  required int? subcategoryId,
  required int amountCents,
  required int timestamp,
}) {
  return database
      .into(database.ledgerTransactions)
      .insert(
        LedgerTransactionsCompanion.insert(
          amountCents: amountCents,
          dateEpochDay: 20720,
          entryType: entryType.databaseValue,
          categoryId: categoryId,
          subcategoryId: Value(subcategoryId),
          createdAtMicros: timestamp,
          updatedAtMicros: timestamp,
        ),
      );
}
