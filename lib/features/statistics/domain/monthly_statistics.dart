import '../../categories/domain/category.dart';
import '../../transactions/domain/ledger_transaction.dart';

class MonthlyStatistics {
  const MonthlyStatistics({
    required this.incomeCents,
    required this.expenseCents,
    required this.incomeCategories,
    required this.expenseCategories,
  });

  factory MonthlyStatistics.fromTransactions(
    List<LedgerTransaction> transactions,
  ) {
    final income = <int, _CategoryAccumulator>{};
    final expense = <int, _CategoryAccumulator>{};
    var incomeCents = 0;
    var expenseCents = 0;

    for (final transaction in transactions) {
      final accumulators = transaction.entryType == EntryType.income
          ? income
          : expense;
      final category = accumulators.putIfAbsent(
        transaction.categoryId,
        () => _CategoryAccumulator(
          id: transaction.categoryId,
          name: transaction.categoryName,
        ),
      );
      category.add(transaction);
      if (transaction.entryType == EntryType.income) {
        incomeCents += transaction.amountCents;
      } else {
        expenseCents += transaction.amountCents;
      }
    }

    return MonthlyStatistics(
      incomeCents: incomeCents,
      expenseCents: expenseCents,
      incomeCategories: _sortedCategories(income),
      expenseCategories: _sortedCategories(expense),
    );
  }

  final int incomeCents;
  final int expenseCents;
  final List<CategoryStatistics> incomeCategories;
  final List<CategoryStatistics> expenseCategories;

  int get balanceCents => incomeCents - expenseCents;

  bool get hasTransactions => incomeCents != 0 || expenseCents != 0;

  static List<CategoryStatistics> _sortedCategories(
    Map<int, _CategoryAccumulator> accumulators,
  ) {
    final sorted = accumulators.values.toList()
      ..sort((left, right) => left.id.compareTo(right.id));
    return List.unmodifiable(sorted.map((category) => category.build()));
  }
}

class CategoryStatistics {
  const CategoryStatistics({
    required this.id,
    required this.name,
    required this.amountCents,
    required this.directAmountCents,
    required this.subcategories,
  });

  final int id;
  final String name;
  final int amountCents;
  final int directAmountCents;
  final List<SubcategoryStatistics> subcategories;

  bool get hasMixedAssignments =>
      directAmountCents > 0 && subcategories.isNotEmpty;
}

class SubcategoryStatistics {
  const SubcategoryStatistics({
    required this.id,
    required this.name,
    required this.amountCents,
  });

  final int id;
  final String name;
  final int amountCents;
}

String? formatPercentage({required int partCents, required int totalCents}) {
  if (partCents < 0 || totalCents < 0 || partCents > totalCents) {
    throw ArgumentError('Percentage values must satisfy 0 <= part <= total.');
  }
  if (totalCents == 0) return null;

  final part = BigInt.from(partCents);
  final total = BigInt.from(totalCents);
  final scaled = part * BigInt.from(10000);
  if (partCents > 0 && scaled < total) return '<0.01%';

  final hundredths = ((scaled * BigInt.two + total) ~/ (total * BigInt.two))
      .toInt();
  final whole = hundredths ~/ 100;
  final fraction = hundredths.remainder(100).toString().padLeft(2, '0');
  return '$whole.$fraction%';
}

class _CategoryAccumulator {
  _CategoryAccumulator({required this.id, required this.name});

  final int id;
  final String name;
  int amountCents = 0;
  int directAmountCents = 0;
  final Map<int, _SubcategoryAccumulator> subcategories = {};

  void add(LedgerTransaction transaction) {
    amountCents += transaction.amountCents;
    final subcategoryId = transaction.subcategoryId;
    if (subcategoryId == null) {
      directAmountCents += transaction.amountCents;
      return;
    }
    final subcategory = subcategories.putIfAbsent(
      subcategoryId,
      () => _SubcategoryAccumulator(
        id: subcategoryId,
        name: transaction.subcategoryName!,
      ),
    );
    subcategory.amountCents += transaction.amountCents;
  }

  CategoryStatistics build() {
    final sortedSubcategories = subcategories.values.toList()
      ..sort((left, right) => left.id.compareTo(right.id));
    return CategoryStatistics(
      id: id,
      name: name,
      amountCents: amountCents,
      directAmountCents: directAmountCents,
      subcategories: List.unmodifiable(
        sortedSubcategories.map(
          (subcategory) => SubcategoryStatistics(
            id: subcategory.id,
            name: subcategory.name,
            amountCents: subcategory.amountCents,
          ),
        ),
      ),
    );
  }
}

class _SubcategoryAccumulator {
  _SubcategoryAccumulator({required this.id, required this.name});

  final int id;
  final String name;
  int amountCents = 0;
}
