import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/database/app_database.dart';
import 'package:ledger/core/time/year_month.dart';
import 'package:ledger/features/categories/data/category_repository.dart';
import 'package:ledger/features/categories/domain/category.dart';
import 'package:ledger/features/transactions/data/transaction_repository.dart';
import 'package:ledger/features/transactions/domain/ledger_transaction.dart';

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

  test('creates and watches a month in date and creation order', () async {
    final food = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    final lunch = await categories.createLevelThree(
      parentId: food.id,
      name: 'Lunch',
    );

    await transactions.create(
      _input(date: DateTime(2026, 9, 10), categoryId: food.id),
    );
    final newest = await transactions.create(
      _input(
        date: DateTime(2026, 9, 11),
        categoryId: food.id,
        subcategoryId: lunch.id,
        note: 'Noodles',
      ),
    );
    await transactions.create(
      _input(date: DateTime(2026, 8, 31), categoryId: food.id),
    );

    final september = await transactions.listMonth(const YearMonth(2026, 9));
    expect(september, hasLength(2));
    expect(september.first.id, newest.id);
    expect(september.first.categoryName, 'Food');
    expect(september.first.subcategoryName, 'Lunch');
    expect(september.first.note, 'Noodles');
  });

  test('updates and deletes a transaction', () async {
    final expense = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    final income = await categories.createLevelTwo(
      entryType: EntryType.income,
      name: 'Salary',
    );
    final created = await transactions.create(
      _input(date: DateTime(2026, 9, 10), categoryId: expense.id),
    );

    final updated = await transactions.update(
      transactionId: created.id,
      input: TransactionInput(
        amountCents: 250000,
        date: DateTime(2026, 8, 1),
        entryType: EntryType.income,
        categoryId: income.id,
        subcategoryId: null,
        note: 'August salary',
      ),
    );
    expect(updated.amountCents, 250000);
    expect(updated.entryType, EntryType.income);
    expect(await transactions.listMonth(const YearMonth(2026, 9)), isEmpty);
    expect(
      await transactions.listMonth(const YearMonth(2026, 8)),
      hasLength(1),
    );

    await transactions.delete(created.id);
    expect(await transactions.listMonth(const YearMonth(2026, 8)), isEmpty);
  });

  test('rejects a category from the wrong side or hierarchy', () async {
    final food = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    final lunch = await categories.createLevelThree(
      parentId: food.id,
      name: 'Lunch',
    );

    await expectLater(
      transactions.create(
        TransactionInput(
          amountCents: 100,
          date: DateTime(2026, 9, 1),
          entryType: EntryType.income,
          categoryId: food.id,
          subcategoryId: null,
          note: '',
        ),
      ),
      throwsA(_problem(TransactionProblem.categoryInvalid)),
    );
    await expectLater(
      transactions.create(
        _input(date: DateTime(2026, 9, 1), categoryId: lunch.id),
      ),
      throwsA(_problem(TransactionProblem.categoryInvalid)),
    );
  });

  test('persists one draft and clears deleted category selections', () async {
    final food = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    final lunch = await categories.createLevelThree(
      parentId: food.id,
      name: 'Lunch',
    );
    await transactions.saveDraft(
      TransactionDraft(
        amountText: '12.',
        entryType: EntryType.expense,
        categoryId: food.id,
        subcategoryId: lunch.id,
        note: 'unfinished',
      ),
    );
    expect((await transactions.loadDraft())!.subcategoryId, lunch.id);

    await (database.delete(
      database.categoryRecords,
    )..where((row) => row.id.equals(lunch.id))).go();
    await (database.delete(
      database.categoryRecords,
    )..where((row) => row.id.equals(food.id))).go();

    final sanitized = await transactions.loadDraft();
    expect(sanitized!.amountText, '12.');
    expect(sanitized.note, 'unfinished');
    expect(sanitized.categoryId, isNull);
    expect(sanitized.subcategoryId, isNull);

    await transactions.clearDraft();
    expect(await transactions.loadDraft(), isNull);
  });

  test('database rejects a zero amount', () async {
    final food = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    await expectLater(
      database
          .into(database.ledgerTransactions)
          .insert(
            LedgerTransactionsCompanion(
              amountCents: const Value(0),
              dateEpochDay: const Value(1),
              entryType: const Value(0),
              categoryId: Value(food.id),
              createdAtMicros: const Value(1),
              updatedAtMicros: const Value(1),
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('creating a transaction atomically clears the saved draft', () async {
    final food = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    await transactions.saveDraft(const TransactionDraft.empty());

    await transactions.create(
      _input(date: DateTime(2026, 9, 24), categoryId: food.id),
    );

    expect(await transactions.loadDraft(), isNull);
  });

  test('database enforces the singleton draft row', () async {
    await transactions.saveDraft(const TransactionDraft.empty());

    await expectLater(
      database
          .into(database.transactionDraftRecords)
          .insert(
            const TransactionDraftRecordsCompanion(
              id: Value(2),
              amountText: Value('1.00'),
              entryType: Value(0),
              note: Value(''),
              updatedAtMicros: Value(1),
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('repository rejects future dates even for prebuilt input', () async {
    final food = await categories.createLevelTwo(
      entryType: EntryType.expense,
      name: 'Food',
    );
    await expectLater(
      transactions.create(
        _input(date: DateTime(2026, 9, 25), categoryId: food.id),
      ),
      throwsA(_problem(TransactionProblem.futureDate)),
    );
  });
}

TransactionInput _input({
  required DateTime date,
  required int categoryId,
  int? subcategoryId,
  String note = '',
}) {
  return TransactionInput(
    amountCents: 1234,
    date: date,
    entryType: EntryType.expense,
    categoryId: categoryId,
    subcategoryId: subcategoryId,
    note: note,
  );
}

Matcher _problem(TransactionProblem problem) {
  return isA<TransactionException>().having(
    (error) => error.problem,
    'problem',
    problem,
  );
}
