import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/time/year_month.dart';
import 'package:ledger/features/categories/data/category_repository.dart';
import 'package:ledger/features/categories/domain/category.dart';
import 'package:ledger/features/transactions/data/transaction_repository.dart';
import 'package:ledger/features/transactions/domain/ledger_transaction.dart';
import 'package:ledger/features/transactions/presentation/transactions_page.dart';
import 'package:ledger/l10n/app_localizations.dart';

import '../../helpers/test_database.dart';

void main() {
  testWidgets(
    'shows grouped monthly rows with paths, notes, signs, and order',
    (tester) async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final categories = CategoryRepository(
        database,
        now: () => DateTime.utc(2026, 9, 24),
      );
      final transactions = TransactionRepository(
        database,
        now: () => DateTime.utc(2026, 9, 24, 12),
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
      final older = await transactions.create(
        TransactionInput(
          amountCents: 1234,
          date: DateTime(2026, 9, 23),
          entryType: EntryType.expense,
          categoryId: food.id,
          subcategoryId: lunch.id,
          note: 'Noodles',
        ),
      );
      final newer = await transactions.create(
        TransactionInput(
          amountCents: 10000,
          date: DateTime(2026, 9, 24),
          entryType: EntryType.income,
          categoryId: salary.id,
          subcategoryId: null,
          note: '',
        ),
      );
      LedgerTransaction? tapped;

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
            body: TransactionsPage(
              repository: transactions,
              selectedMonth: const YearMonth(2026, 9),
              onMonthChanged: (_) {},
              onEdit: (transaction) => tapped = transaction,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Food · Lunch'), findsOneWidget);
      expect(find.text('Expense · Noodles'), findsOneWidget);
      expect(find.text('−¥12.34'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('+¥100.00'), findsOneWidget);
      expect(
        tester.getTopLeft(find.byKey(ValueKey('transaction-${newer.id}'))).dy,
        lessThan(
          tester.getTopLeft(find.byKey(ValueKey('transaction-${older.id}'))).dy,
        ),
      );

      await tester.tap(find.byKey(ValueKey('transaction-${older.id}')));
      expect(tapped?.id, older.id);
    },
  );
}
