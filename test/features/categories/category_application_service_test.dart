import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/database/app_database.dart';
import 'package:ledger/features/categories/application/category_application_service.dart';
import 'package:ledger/features/categories/data/category_repository.dart';
import 'package:ledger/features/categories/domain/category.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late CategoryRepository repository;
  late CategoryApplicationService service;

  setUp(() {
    database = createTestDatabase();
    repository = CategoryRepository(
      database,
      now: () => DateTime.utc(2026, 9, 24),
    );
    service = CategoryApplicationService(
      database,
      now: () => DateTime.utc(2026, 9, 24),
    );
  });

  tearDown(() => database.close());

  test('previews and atomically deletes a level-two subtree', () async {
    final food = await repository.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    final lunch = await repository.createLevelThree(
      parentId: food.id,
      name: 'Lunch',
    );
    await _insertTransaction(database, food, lunch);

    final preview = await service.previewLevelTwoDeletion(food.id);
    expect(preview.childCount, 1);
    expect(preview.transactionCount, 1);

    await service.deleteLevelTwoWithSubtree(food.id);

    expect(await database.select(database.categoryRecords).get(), isEmpty);
    expect(await database.select(database.ledgerTransactions).get(), isEmpty);
  });

  test('requires every level-two name conflict before changing data', () async {
    final source = await repository.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Source',
    );
    final target = await repository.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Target',
    );
    final sourceLunch = await repository.createLevelThree(
      parentId: source.id,
      name: 'Lunch',
    );
    await repository.createLevelThree(parentId: target.id, name: 'LUNCH');
    await _insertTransaction(database, source, sourceLunch);

    final conflicts = await service.levelTwoMigrationConflicts(
      sourceId: source.id,
      targetId: target.id,
    );
    expect(conflicts, hasLength(1));

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
          CategoryProblem.missingConflictResolution,
        ),
      ),
    );

    expect(await repository.getRecord(source.id), isNotNull);
    final transaction = await database
        .select(database.ledgerTransactions)
        .getSingle();
    expect(transaction.categoryId, source.id);
    expect(transaction.subcategoryId, sourceLunch.id);
  });

  test('merges conflicts and moves the rest of a level-two subtree', () async {
    final source = await repository.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Source',
    );
    final target = await repository.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Target',
    );
    final sourceLunch = await repository.createLevelThree(
      parentId: source.id,
      name: 'Lunch',
    );
    final sourceCoffee = await repository.createLevelThree(
      parentId: source.id,
      name: 'Coffee',
    );
    final targetLunch = await repository.createLevelThree(
      parentId: target.id,
      name: 'LUNCH',
    );
    await _insertTransaction(database, source, sourceLunch);
    await _insertTransaction(database, source, sourceCoffee);
    await _insertTransaction(database, source, null);

    await service.migrateLevelTwo(
      sourceId: source.id,
      targetId: target.id,
      resolutions: {sourceLunch.id: const MergeCategory()},
    );

    final trees = await repository.listTrees(EntryType.expense);
    expect(trees, hasLength(1));
    expect(trees.single.category.id, target.id);
    expect(trees.single.children.map((child) => child.name), [
      'Coffee',
      'LUNCH',
    ]);
    final transactions = await database
        .select(database.ledgerTransactions)
        .get();
    expect(transactions.every((item) => item.categoryId == target.id), isTrue);
    expect(
      transactions.map((item) => item.subcategoryId),
      containsAll([targetLunch.id, sourceCoffee.id, null]),
    );
  });

  test('renames a conflicting child while moving a subtree', () async {
    final source = await repository.createLevelTwo(
      entryType: EntryType.income,
      name: 'Source',
    );
    final target = await repository.createLevelTwo(
      entryType: EntryType.income,
      name: 'Target',
    );
    final sourceBonus = await repository.createLevelThree(
      parentId: source.id,
      name: 'Bonus',
    );
    await repository.createLevelThree(parentId: target.id, name: 'BONUS');

    await service.migrateLevelTwo(
      sourceId: source.id,
      targetId: target.id,
      resolutions: {
        sourceBonus.id: const RenameAndMoveCategory('Annual bonus'),
      },
    );

    final tree = (await repository.listTrees(EntryType.income)).single;
    expect(tree.children.map((child) => child.name), ['Annual bonus', 'BONUS']);
  });

  test('moves level-three transactions to a level-two-only target', () async {
    final sourceParent = await repository.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    final source = await repository.createLevelThree(
      parentId: sourceParent.id,
      name: 'Lunch',
    );
    final target = await repository.createLevelTwo(
      entryType: EntryType.expense,
      name: 'General',
    );
    await _insertTransaction(database, sourceParent, source);

    await service.migrateLevelThreeTransactions(
      sourceId: source.id,
      target: LevelThreeMigrationTarget(levelTwoId: target.id),
    );

    final transaction = await database
        .select(database.ledgerTransactions)
        .getSingle();
    expect(transaction.categoryId, target.id);
    expect(transaction.subcategoryId, isNull);
    await expectLater(
      repository.getRecord(source.id),
      throwsA(isA<CategoryException>()),
    );
  });

  test('rejects migration across income and expense', () async {
    final expense = await repository.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Expense',
    );
    final income = await repository.createLevelTwo(
      entryType: EntryType.income,
      name: 'Income',
    );

    await expectLater(
      service.migrateLevelTwo(
        sourceId: expense.id,
        targetId: income.id,
        resolutions: const {},
      ),
      throwsA(
        isA<CategoryException>().having(
          (error) => error.problem,
          'problem',
          CategoryProblem.crossTypeMigration,
        ),
      ),
    );
  });
}

Future<int> _insertTransaction(
  AppDatabase database,
  LedgerCategory category,
  LedgerCategory? subcategory,
) {
  const now = 1789891200000000;
  return database
      .into(database.ledgerTransactions)
      .insert(
        LedgerTransactionsCompanion.insert(
          amountCents: 1234,
          dateEpochDay: 20720,
          entryType: category.entryType.databaseValue,
          categoryId: category.id,
          subcategoryId: Value(subcategory?.id),
          createdAtMicros: now,
          updatedAtMicros: now,
        ),
      );
}
