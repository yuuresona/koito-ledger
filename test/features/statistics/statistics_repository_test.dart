import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/database/app_database.dart';
import 'package:ledger/core/time/year_month.dart';
import 'package:ledger/features/categories/application/category_application_service.dart';
import 'package:ledger/features/categories/data/category_repository.dart';
import 'package:ledger/features/categories/domain/category.dart';
import 'package:ledger/features/statistics/data/statistics_repository.dart';
import 'package:ledger/features/statistics/domain/monthly_statistics.dart';
import 'package:ledger/features/transactions/data/transaction_repository.dart';
import 'package:ledger/features/transactions/domain/ledger_transaction.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late CategoryRepository categories;
  late TransactionRepository transactions;
  late StatisticsRepository statistics;

  setUp(() {
    database = createTestDatabase();
    categories = CategoryRepository(
      database,
      now: () => DateTime.utc(2026, 9, 24),
    );
    transactions = TransactionRepository(
      database,
      now: () => DateTime.utc(2026, 9, 24, 12),
    );
    statistics = StatisticsRepository(transactions);
  });

  tearDown(() => database.close());

  test('aggregates only the selected month', () async {
    final food = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    await transactions.create(_input(DateTime(2026, 9, 1), food.id));
    await transactions.create(_input(DateTime(2026, 8, 31), food.id));

    final result = await statistics.watchMonth(const YearMonth(2026, 9)).first;

    expect(result.expenseCents, 1234);
    expect(result.expenseCategories.single.name, 'Food');
  });

  test('reacts to create, update, category rename, and delete', () async {
    final food = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    final values = StreamIterator<MonthlyStatistics>(
      statistics.watchMonth(const YearMonth(2026, 9)),
    );
    addTearDown(values.cancel);

    expect((await _next(values)).expenseCents, 0);

    final created = await transactions.create(
      _input(DateTime(2026, 9, 1), food.id),
    );
    expect((await _next(values)).expenseCents, 1234);

    await transactions.update(
      transactionId: created.id,
      input: TransactionInput(
        amountCents: 2500,
        date: DateTime(2026, 9, 1),
        entryType: EntryType.expense,
        categoryId: food.id,
        subcategoryId: null,
        note: '',
      ),
    );
    expect((await _next(values)).expenseCents, 2500);

    await categories.rename(categoryId: food.id, name: 'Meals');
    expect((await _next(values)).expenseCategories.single.name, 'Meals');

    await transactions.delete(created.id);
    expect((await _next(values)).expenseCents, 0);
  });

  test('reacts to an atomic level-two migration', () async {
    final source = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    final target = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Living',
    );
    await transactions.create(_input(DateTime(2026, 9, 1), source.id));
    final values = StreamIterator<MonthlyStatistics>(
      statistics.watchMonth(const YearMonth(2026, 9)),
    );
    addTearDown(values.cancel);

    expect((await _next(values)).expenseCategories.single.name, 'Food');

    await CategoryApplicationService(database).migrateLevelTwo(
      sourceId: source.id,
      targetId: target.id,
      resolutions: const {},
    );

    final migrated = await _next(values);
    expect(migrated.expenseCents, 1234);
    expect(migrated.expenseCategories.single.name, 'Living');
  });
}

Future<MonthlyStatistics> _next(
  StreamIterator<MonthlyStatistics> values,
) async {
  final hasValue = await values.moveNext().timeout(const Duration(seconds: 2));
  expect(hasValue, isTrue);
  return values.current;
}

TransactionInput _input(DateTime date, int categoryId) {
  return TransactionInput(
    amountCents: 1234,
    date: date,
    entryType: EntryType.expense,
    categoryId: categoryId,
    subcategoryId: null,
    note: '',
  );
}
