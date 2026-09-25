import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/features/categories/domain/category.dart';
import 'package:ledger/features/statistics/domain/monthly_statistics.dart';
import 'package:ledger/features/transactions/domain/ledger_transaction.dart';

void main() {
  test('aggregates totals and category hierarchy in creation order', () {
    final statistics = MonthlyStatistics.fromTransactions([
      _transaction(
        id: 1,
        amountCents: 3000,
        entryType: EntryType.expense,
        categoryId: 20,
        categoryName: 'Food',
        subcategoryId: 22,
        subcategoryName: 'Lunch',
      ),
      _transaction(
        id: 2,
        amountCents: 5000,
        entryType: EntryType.expense,
        categoryId: 10,
        categoryName: 'Travel',
      ),
      _transaction(
        id: 3,
        amountCents: 2000,
        entryType: EntryType.expense,
        categoryId: 20,
        categoryName: 'Food',
      ),
      _transaction(
        id: 4,
        amountCents: 20000,
        entryType: EntryType.income,
        categoryId: 30,
        categoryName: 'Salary',
      ),
    ]);

    expect(statistics.incomeCents, 20000);
    expect(statistics.expenseCents, 10000);
    expect(statistics.balanceCents, 10000);
    expect(statistics.hasTransactions, isTrue);

    expect(statistics.expenseCategories.map((category) => category.name), [
      'Travel',
      'Food',
    ]);
    final travel = statistics.expenseCategories.first;
    expect(travel.amountCents, 5000);
    expect(travel.directAmountCents, 5000);
    expect(travel.subcategories, isEmpty);

    final food = statistics.expenseCategories.last;
    expect(food.amountCents, 5000);
    expect(food.directAmountCents, 2000);
    expect(food.hasMixedAssignments, isTrue);
    expect(food.subcategories.single.name, 'Lunch');
    expect(food.subcategories.single.amountCents, 3000);
  });

  test('empty statistics contain zero totals and no categories', () {
    final statistics = MonthlyStatistics.fromTransactions(const []);

    expect(statistics.incomeCents, 0);
    expect(statistics.expenseCents, 0);
    expect(statistics.balanceCents, 0);
    expect(statistics.hasTransactions, isFalse);
    expect(statistics.incomeCategories, isEmpty);
    expect(statistics.expenseCategories, isEmpty);
  });

  group('formatPercentage', () {
    test('rounds to two decimal places', () {
      expect(formatPercentage(partCents: 1, totalCents: 3), '33.33%');
      expect(formatPercentage(partCents: 2, totalCents: 3), '66.67%');
    });

    test('uses the less-than marker for a nonzero share below 0.01%', () {
      expect(formatPercentage(partCents: 1, totalCents: 10001), '<0.01%');
      expect(formatPercentage(partCents: 1, totalCents: 10000), '0.01%');
    });

    test('omits a percentage when the total is zero', () {
      expect(formatPercentage(partCents: 0, totalCents: 0), isNull);
    });

    test('does not overflow while scaling a large monthly total', () {
      expect(
        formatPercentage(
          partCents: 900719925474099300,
          totalCents: 900719925474099300,
        ),
        '100.00%',
      );
    });
  });
}

LedgerTransaction _transaction({
  required int id,
  required int amountCents,
  required EntryType entryType,
  required int categoryId,
  required String categoryName,
  int? subcategoryId,
  String? subcategoryName,
}) {
  return LedgerTransaction(
    id: id,
    amountCents: amountCents,
    date: DateTime(2026, 9, 24),
    entryType: entryType,
    categoryId: categoryId,
    categoryName: categoryName,
    subcategoryId: subcategoryId,
    subcategoryName: subcategoryName,
    note: null,
    createdAt: DateTime.utc(2026, 9, 24),
    updatedAt: DateTime.utc(2026, 9, 24),
  );
}
