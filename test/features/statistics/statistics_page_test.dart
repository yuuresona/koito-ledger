import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/database/app_database.dart';
import 'package:ledger/core/time/year_month.dart';
import 'package:ledger/features/categories/data/category_repository.dart';
import 'package:ledger/features/categories/domain/category.dart';
import 'package:ledger/features/statistics/data/statistics_repository.dart';
import 'package:ledger/features/statistics/presentation/statistics_page.dart';
import 'package:ledger/features/transactions/data/transaction_repository.dart';
import 'package:ledger/features/transactions/domain/ledger_transaction.dart';
import 'package:ledger/l10n/app_localizations.dart';

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

  testWidgets('shows zero totals and an empty state for an empty month', (
    tester,
  ) async {
    await _pumpPage(tester, statistics);

    expect(find.text('Income ¥0.00'), findsOneWidget);
    expect(find.text('Expense ¥0.00'), findsOneWidget);
    expect(find.text('Balance ¥0.00'), findsOneWidget);
    expect(find.text('No transactions this month.'), findsOneWidget);
    expect(find.byKey(const Key('statistics-income-section')), findsNothing);
    expect(find.byKey(const Key('statistics-expense-section')), findsNothing);
  });

  testWidgets('shows totals and hierarchical same-side percentages', (
    tester,
  ) async {
    final travel = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Travel',
    );
    final food = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    final lunch = await categories.createLevelThree(
      parentId: food.id,
      name: 'Lunch',
    );
    final salary = await categories.createLevelTwo(
      entryType: EntryType.income,
      name: 'Salary',
    );
    await transactions.create(_input(5000, EntryType.expense, travel.id));
    await transactions.create(_input(2000, EntryType.expense, food.id));
    await transactions.create(
      _input(3000, EntryType.expense, food.id, subcategoryId: lunch.id),
    );
    await transactions.create(_input(20000, EntryType.income, salary.id));

    await _pumpPage(tester, statistics);

    expect(find.text('Income +¥200.00'), findsOneWidget);
    expect(find.text('Expense −¥100.00'), findsOneWidget);
    expect(find.text('Balance +¥100.00'), findsOneWidget);
    expect(find.byKey(const Key('statistics-income-section')), findsOneWidget);
    expect(find.byKey(const Key('statistics-expense-section')), findsOneWidget);
    expect(find.text('+¥200.00 · 100.00%'), findsOneWidget);
    expect(find.text('−¥50.00 · 50.00%'), findsNWidgets(2));
    expect(find.text('−¥20.00 · 20.00%'), findsOneWidget);
    expect(find.text('−¥30.00 · 30.00%'), findsOneWidget);
    expect(find.text('No subcategory'), findsOneWidget);
    expect(find.byType(Card), findsNothing);

    final parentLeft = tester
        .getTopLeft(find.byKey(ValueKey('statistics-category-${food.id}')))
        .dx;
    final childLeft = tester
        .getTopLeft(find.byKey(ValueKey('statistics-subcategory-${lunch.id}')))
        .dx;
    expect(childLeft, greaterThan(parentLeft));
  });

  testWidgets('shows a negative balance without repeating direct-only totals', (
    tester,
  ) async {
    final rent = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Rent',
    );
    await transactions.create(_input(1234, EntryType.expense, rent.id));

    await _pumpPage(tester, statistics);

    expect(find.text('Income ¥0.00'), findsOneWidget);
    expect(find.text('Expense −¥12.34'), findsOneWidget);
    expect(find.text('Balance −¥12.34'), findsOneWidget);
    expect(find.text('−¥12.34 · 100.00%'), findsOneWidget);
    expect(find.text('No subcategory'), findsNothing);
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  StatisticsRepository statistics,
) async {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: StatisticsPage(
          repository: statistics,
          selectedMonth: const YearMonth(2026, 9),
          onMonthChanged: (_) {},
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

TransactionInput _input(
  int amountCents,
  EntryType entryType,
  int categoryId, {
  int? subcategoryId,
}) {
  return TransactionInput(
    amountCents: amountCents,
    date: DateTime(2026, 9, 24),
    entryType: entryType,
    categoryId: categoryId,
    subcategoryId: subcategoryId,
    note: '',
  );
}
