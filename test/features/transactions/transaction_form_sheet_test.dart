import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/database/app_database.dart';
import 'package:ledger/core/time/year_month.dart';
import 'package:ledger/features/categories/data/category_repository.dart';
import 'package:ledger/features/categories/domain/category.dart';
import 'package:ledger/features/transactions/data/transaction_repository.dart';
import 'package:ledger/features/transactions/domain/ledger_transaction.dart';
import 'package:ledger/features/transactions/presentation/transaction_form_sheet.dart';
import 'package:ledger/l10n/app_localizations.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late CategoryRepository categories;
  late TransactionRepository transactions;

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
  });

  tearDown(() => database.close());

  testWidgets('creates a category inline and saves a transaction', (
    tester,
  ) async {
    await _pumpHost(tester, categories, transactions);
    await tester.tap(find.text('Open'));
    await _pumpUntil(tester, find.text('New transaction'));
    await tester.pump(const Duration(milliseconds: 500));
    await _pumpUntil(tester, find.text('Create category'));

    await tester.tap(find.text('Create category'));
    await _pumpUntil(tester, find.widgetWithText(TextField, 'Category name'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Category name'),
      'Food',
    );
    await tester.tap(find.text('Save').last);
    await _pumpUntil(
      tester,
      find.widgetWithText(TextField, 'Category name'),
      absent: true,
    );
    expect(find.byKey(const Key('transaction-category')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('transaction-amount')),
      '12.34',
    );
    await tester.ensureVisible(find.byKey(const Key('save-transaction')));
    await tester.tap(find.byKey(const Key('save-transaction')));
    await _pumpUntil(tester, find.text('New transaction'), absent: true);

    final saved = await database.select(database.ledgerTransactions).get();
    expect(saved, hasLength(1));
    expect(saved.single.amountCents, 1234);
    expect(
      (await database.select(database.categoryRecords).getSingle()).name,
      'Food',
    );
  });

  testWidgets('restores a dismissed new-transaction draft and clears it', (
    tester,
  ) async {
    await categories.createLevelTwo(entryType: EntryType.expense, name: 'Food');
    await _pumpHost(tester, categories, transactions);
    await tester.tap(find.text('Open'));
    await _pumpUntil(tester, find.text('New transaction'));
    await tester.pump(const Duration(milliseconds: 500));
    await _pumpUntil(tester, find.byKey(const Key('transaction-category')));
    await tester.enterText(find.byKey(const Key('transaction-amount')), '12.');
    await tester.enterText(
      find.byKey(const Key('transaction-note')),
      'unfinished',
    );
    await tester.binding.handlePopRoute();
    await _pumpUntil(tester, find.text('New transaction'), absent: true);

    final draft = await transactions.loadDraft();
    expect(draft!.amountText, '12.');
    expect(draft.note, 'unfinished');

    await tester.tap(find.text('Open'));
    await _pumpUntil(tester, find.text('New transaction'));
    await tester.pump(const Duration(milliseconds: 500));
    await _pumpUntil(tester, find.byKey(const Key('transaction-category')));
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('transaction-amount')))
          .controller!
          .text,
      '12.',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('transaction-note')))
          .controller!
          .text,
      'unfinished',
    );

    await tester.ensureVisible(find.text('Clear draft'));
    await tester.tap(find.text('Clear draft'));
    await tester.pump();
    expect(await transactions.loadDraft(), isNull);
    await tester.binding.handlePopRoute();
    await _pumpUntil(tester, find.text('New transaction'), absent: true);
  });

  testWidgets('edit closes without saving, then updates and deletes', (
    tester,
  ) async {
    final food = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    final transaction = await transactions.create(
      TransactionInput(
        amountCents: 1000,
        date: DateTime(2026, 9, 24),
        entryType: EntryType.expense,
        categoryId: food.id,
        subcategoryId: null,
        note: '',
      ),
    );
    await _pumpHost(tester, categories, transactions, transaction: transaction);

    await tester.tap(find.text('Open'));
    await _pumpUntil(tester, find.text('Edit transaction'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(
      find.byKey(const Key('transaction-amount')),
      '99.00',
    );
    await tester.binding.handlePopRoute();
    await _pumpUntil(tester, find.text('Edit transaction'), absent: true);
    expect(
      (await database.select(database.ledgerTransactions).getSingle())
          .amountCents,
      1000,
    );

    await tester.tap(find.text('Open'));
    await _pumpUntil(tester, find.text('Edit transaction'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(
      find.byKey(const Key('transaction-amount')),
      '20.00',
    );
    await tester.ensureVisible(find.byKey(const Key('save-transaction')));
    await tester.tap(find.byKey(const Key('save-transaction')));
    await _pumpUntil(tester, find.text('Edit transaction'), absent: true);
    expect(
      (await database.select(database.ledgerTransactions).getSingle())
          .amountCents,
      2000,
    );

    await tester.tap(find.text('Open'));
    await _pumpUntil(tester, find.text('Edit transaction'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.ensureVisible(find.text('Delete'));
    await tester.tap(find.text('Delete'));
    await _pumpUntil(
      tester,
      find.text('Delete this transaction? This cannot be undone.'),
    );
    await tester.tap(find.text('Delete').last);
    await _pumpUntil(tester, find.text('Edit transaction'), absent: true);
    expect(await database.select(database.ledgerTransactions).get(), isEmpty);
  });

  testWidgets('blocks dismissal while a new transaction is saving', (
    tester,
  ) async {
    final food = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    final delayedTransactions = _DelayedTransactionRepository(
      database,
      now: () => DateTime.utc(2026, 9, 24, 12),
    );
    await delayedTransactions.saveDraft(
      TransactionDraft(
        amountText: '12.34',
        entryType: EntryType.expense,
        categoryId: food.id,
        subcategoryId: null,
        note: 'Lunch',
      ),
    );
    await _pumpHost(tester, categories, delayedTransactions);
    await tester.tap(find.text('Open'));
    await _pumpUntil(tester, find.text('New transaction'));
    await tester.pump(const Duration(milliseconds: 500));
    await _pumpUntil(tester, find.byKey(const Key('transaction-category')));

    await tester.ensureVisible(find.byKey(const Key('save-transaction')));
    await tester.tap(find.byKey(const Key('save-transaction')));
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.close))
          .onPressed,
      isNull,
    );

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('New transaction'), findsOneWidget);

    delayedTransactions.completeSave();
    await _pumpUntil(tester, find.text('New transaction'), absent: true);
    expect(
      await database.select(database.ledgerTransactions).get(),
      hasLength(1),
    );
    expect(await delayedTransactions.loadDraft(), isNull);
  });
}

class _DelayedTransactionRepository extends TransactionRepository {
  _DelayedTransactionRepository(super.database, {super.now});

  final _saveBarrier = Completer<void>();

  void completeSave() => _saveBarrier.complete();

  @override
  Future<LedgerTransaction> create(TransactionInput input) async {
    await _saveBarrier.future;
    return super.create(input);
  }
}

Future<void> _pumpHost(
  WidgetTester tester,
  CategoryRepository categories,
  TransactionRepository transactions, {
  LedgerTransaction? transaction,
}) async {
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
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => showTransactionFormSheet(
                context: context,
                transactionRepository: transactions,
                categoryRepository: categories,
                selectedMonth: const YearMonth(2026, 9),
                transaction: transaction,
                now: () => DateTime(2026, 9, 24),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  bool absent = false,
}) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    final matched = finder.evaluate().isNotEmpty;
    if (matched != absent) return;
  }
  fail('Timed out waiting for ${absent ? 'absence' : 'presence'} of $finder.');
}
