import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/database/app_database.dart';
import 'package:ledger/features/categories/data/category_repository.dart';
import 'package:ledger/features/categories/domain/category.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late CategoryRepository repository;

  setUp(() {
    database = createTestDatabase();
    repository = CategoryRepository(
      database,
      now: () => DateTime.utc(2026, 9, 24),
    );
  });

  tearDown(() => database.close());

  test('creates a hierarchy in creation order', () async {
    final food = await repository.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    final transport = await repository.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Transport',
    );
    await repository.createLevelThree(parentId: food.id, name: 'Lunch');
    await repository.createLevelThree(parentId: food.id, name: 'Dinner');

    final trees = await repository.listTrees(EntryType.expense);

    expect(trees.map((tree) => tree.category.name), ['Food', 'Transport']);
    expect(trees.first.children.map((child) => child.name), [
      'Lunch',
      'Dinner',
    ]);
    expect(trees.last.category.id, transport.id);
  });

  test('enforces case-insensitive uniqueness only among siblings', () async {
    final food = await repository.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    final travel = await repository.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Travel',
    );
    await repository.createLevelThree(parentId: food.id, name: 'Lunch');

    await expectLater(
      repository.createLevelTwo(entryType: EntryType.expense, name: ' food '),
      throwsA(
        isA<CategoryException>().having(
          (error) => error.problem,
          'problem',
          CategoryProblem.duplicateName,
        ),
      ),
    );
    await expectLater(
      repository.createLevelThree(parentId: food.id, name: 'LUNCH'),
      throwsA(isA<CategoryException>()),
    );

    final sameNameElsewhere = await repository.createLevelThree(
      parentId: travel.id,
      name: 'lunch',
    );
    final sameNameOtherType = await repository.createLevelTwo(
      entryType: EntryType.income,
      name: 'FOOD',
    );

    expect(sameNameElsewhere.name, 'lunch');
    expect(sameNameOtherType.name, 'FOOD');
  });

  test('renames a category without changing its identity', () async {
    final category = await repository.createLevelTwo(
      entryType: EntryType.income,
      name: 'Salary',
    );

    final renamed = await repository.rename(
      categoryId: category.id,
      name: 'Primary salary',
    );

    expect(renamed.id, category.id);
    expect(renamed.name, 'Primary salary');
    expect(renamed.normalizedName, 'primary salary');
  });
}
