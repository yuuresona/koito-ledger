import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/time/year_month.dart';
import 'package:ledger/features/categories/application/category_application_service.dart';
import 'package:ledger/features/categories/data/category_repository.dart';
import 'package:ledger/features/categories/domain/category.dart';
import 'package:ledger/features/transactions/data/transaction_repository.dart';
import 'package:ledger/features/transactions/domain/ledger_transaction.dart';

import '../helpers/test_database.dart';

const _stateSeed = 0x5354415445;
const _invalidSeed = 0x494E56414C4944;
const _draftSeed = 0x4452414654;

void main() {
  test(
    '2,500 randomized transaction mutations match an in-memory model',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final categories = CategoryRepository(
        database,
        now: () => DateTime.utc(2026, 9, 25),
      );
      final fixtures = await _createCategoryFixtures(categories);
      final transactions = TransactionRepository(
        database,
        now: () => DateTime.utc(2026, 9, 25, 12),
      );
      final random = Random(_stateSeed);
      final expected = <int, LedgerTransaction>{};

      for (var iteration = 0; iteration < 2500; iteration++) {
        final operation = random.nextInt(100);
        if (expected.isEmpty || operation < 55) {
          final created = await transactions.create(
            _randomInput(random, fixtures),
          );
          expected[created.id] = created;
        } else if (operation < 85) {
          final current = expected.values.elementAt(
            random.nextInt(expected.length),
          );
          final updated = await transactions.update(
            transactionId: current.id,
            input: _randomInput(random, fixtures),
          );
          expected[current.id] = updated;
        } else {
          final current = expected.values.elementAt(
            random.nextInt(expected.length),
          );
          await transactions.delete(current.id);
          expected.remove(current.id);
        }

        if ((iteration + 1) % 50 == 0) {
          await _verifyAllMonths(
            transactions,
            expected.values.toList(),
            iteration,
          );
        }
      }

      await _verifyAllMonths(transactions, expected.values.toList(), 2500);
      final persisted = await database
          .select(database.ledgerTransactions)
          .get();
      expect(
        persisted.length,
        expected.length,
        reason: 'seed=$_stateSeed final persisted row count',
      );
    },
  );

  test('500 randomized invalid writes never change persisted state', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final categories = CategoryRepository(
      database,
      now: () => DateTime.utc(2026, 9, 25),
    );
    final fixtures = await _createCategoryFixtures(categories);
    final transactions = TransactionRepository(
      database,
      now: () => DateTime.utc(2026, 9, 25, 12),
    );
    final random = Random(_invalidSeed);

    for (var iteration = 0; iteration < 500; iteration++) {
      final expense = fixtures[EntryType.expense]![random.nextInt(5)];
      final otherExpense =
          fixtures[EntryType.expense]![(fixtures[EntryType.expense]!.indexOf(
                    expense,
                  ) +
                  1) %
              5];
      final income = fixtures[EntryType.income]![random.nextInt(5)];
      final valid = _randomInput(random, fixtures);
      final input = switch (random.nextInt(6)) {
        0 => TransactionInput(
          amountCents: 0,
          date: valid.date,
          entryType: valid.entryType,
          categoryId: valid.categoryId,
          subcategoryId: valid.subcategoryId,
          note: valid.note,
        ),
        1 => TransactionInput(
          amountCents: maximumTransactionAmountCents + 1,
          date: valid.date,
          entryType: valid.entryType,
          categoryId: valid.categoryId,
          subcategoryId: valid.subcategoryId,
          note: valid.note,
        ),
        2 => TransactionInput(
          amountCents: 1,
          date: DateTime(2026, 9, 26),
          entryType: EntryType.expense,
          categoryId: expense.parent.id,
          subcategoryId: null,
          note: '',
        ),
        3 => TransactionInput(
          amountCents: 1,
          date: DateTime(2026, 9, 25),
          entryType: EntryType.income,
          categoryId: expense.parent.id,
          subcategoryId: null,
          note: '',
        ),
        4 => TransactionInput(
          amountCents: 1,
          date: DateTime(2026, 9, 25),
          entryType: EntryType.expense,
          categoryId: expense.parent.id,
          subcategoryId: otherExpense.children.first.id,
          note: '',
        ),
        _ => TransactionInput(
          amountCents: 1,
          date: DateTime(2026, 9, 25),
          entryType: EntryType.income,
          categoryId: income.parent.id,
          subcategoryId: null,
          note: List.filled(201, '账').join(),
        ),
      };

      try {
        final created = await transactions.create(input);
        fail(
          'invalid seed=$_invalidSeed iteration=$iteration '
          'unexpectedly created transaction=${created.id}',
        );
      } on TransactionException {
        // Expected rejection at the persistence boundary.
      }
    }

    expect(await database.select(database.ledgerTransactions).get(), isEmpty);
  });

  test(
    '1,000 randomized drafts round-trip and 100 deletions sanitize keys',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final categories = CategoryRepository(
        database,
        now: () => DateTime.utc(2026, 9, 25),
      );
      final fixtures = await _createCategoryFixtures(categories);
      final transactions = TransactionRepository(
        database,
        now: () => DateTime.utc(2026, 9, 25, 12),
      );
      final service = CategoryApplicationService(database);
      final random = Random(_draftSeed);

      for (var iteration = 0; iteration < 1000; iteration++) {
        final type = random.nextBool() ? EntryType.income : EntryType.expense;
        final fixture = fixtures[type]![random.nextInt(5)];
        final child = random.nextBool()
            ? fixture.children[random.nextInt(fixture.children.length)]
            : null;
        final draft = TransactionDraft(
          amountText: _randomDraftAmount(random),
          entryType: type,
          categoryId: fixture.parent.id,
          subcategoryId: child?.id,
          note: _randomNote(random, 40),
        );
        await transactions.saveDraft(draft);
        final loaded = await transactions.loadDraft();
        if (loaded == null ||
            loaded.amountText != draft.amountText ||
            loaded.entryType != draft.entryType ||
            loaded.categoryId != draft.categoryId ||
            loaded.subcategoryId != draft.subcategoryId ||
            loaded.note != draft.note) {
          fail(
            'draft seed=$_draftSeed iteration=$iteration '
            'draft did not round-trip',
          );
        }
      }

      for (var iteration = 0; iteration < 100; iteration++) {
        final parent = await categories.createLevelTwo(
          entryType: EntryType.expense,
          name: 'temporary-parent-$iteration',
        );
        final child = await categories.createLevelThree(
          parentId: parent.id,
          name: 'temporary-child-$iteration',
        );
        await transactions.saveDraft(
          TransactionDraft(
            amountText: _randomDraftAmount(random),
            entryType: EntryType.expense,
            categoryId: parent.id,
            subcategoryId: child.id,
            note: _randomNote(random, 20),
          ),
        );

        await service.deleteLevelThreeWithTransactions(child.id);
        final withoutChild = await transactions.loadDraft();
        if (withoutChild?.categoryId != parent.id ||
            withoutChild?.subcategoryId != null) {
          fail(
            'draft seed=$_draftSeed sanitation iteration=$iteration '
            'level-three deletion was not sanitized',
          );
        }

        await service.deleteLevelTwoWithSubtree(parent.id);
        final withoutParent = await transactions.loadDraft();
        if (withoutParent?.categoryId != null ||
            withoutParent?.subcategoryId != null) {
          fail(
            'draft seed=$_draftSeed sanitation iteration=$iteration '
            'level-two deletion was not sanitized',
          );
        }
      }
    },
  );
}

Future<Map<EntryType, List<_CategoryFixture>>> _createCategoryFixtures(
  CategoryRepository repository,
) async {
  final result = <EntryType, List<_CategoryFixture>>{};
  for (final type in EntryType.values) {
    final fixtures = <_CategoryFixture>[];
    for (var parentIndex = 0; parentIndex < 5; parentIndex++) {
      final parent = await repository.createLevelTwo(
        entryType: type,
        name: '${type.name}-parent-$parentIndex',
      );
      final children = <LedgerCategory>[];
      for (var childIndex = 0; childIndex < 3; childIndex++) {
        children.add(
          await repository.createLevelThree(
            parentId: parent.id,
            name: '${type.name}-child-$parentIndex-$childIndex',
          ),
        );
      }
      fixtures.add(_CategoryFixture(parent, children));
    }
    result[type] = fixtures;
  }
  return result;
}

TransactionInput _randomInput(
  Random random,
  Map<EntryType, List<_CategoryFixture>> fixtures,
) {
  final type = random.nextBool() ? EntryType.income : EntryType.expense;
  final fixture = fixtures[type]![random.nextInt(fixtures[type]!.length)];
  final child = random.nextInt(10) < 7
      ? fixture.children[random.nextInt(fixture.children.length)]
      : null;
  final start = calendarDateToEpochDay(DateTime(2025, 1, 1));
  final end = calendarDateToEpochDay(DateTime(2026, 9, 25));
  return TransactionInput(
    amountCents: random.nextInt(20) == 0
        ? maximumTransactionAmountCents
        : 1 + random.nextInt(1000000000),
    date: epochDayToCalendarDate(start + random.nextInt(end - start + 1)),
    entryType: type,
    categoryId: fixture.parent.id,
    subcategoryId: child?.id,
    note: _randomNote(random, 30),
  );
}

Future<void> _verifyAllMonths(
  TransactionRepository repository,
  List<LedgerTransaction> expected,
  int iteration,
) async {
  var month = const YearMonth(2025, 1);
  const finalMonth = YearMonth(2026, 9);
  while (!month.isAfter(finalMonth)) {
    final expectedMonth =
        expected
            .where(
              (transaction) => YearMonth.fromDate(transaction.date) == month,
            )
            .toList()
          ..sort(_compareTransactions);
    final actual = await repository.listMonth(month);
    if (actual.length != expectedMonth.length) {
      fail(
        'state seed=$_stateSeed iteration=$iteration month=$month '
        'expected length=${expectedMonth.length} actual=${actual.length}',
      );
    }
    for (var index = 0; index < actual.length; index++) {
      final left = actual[index];
      final right = expectedMonth[index];
      if (left.id != right.id ||
          left.amountCents != right.amountCents ||
          left.date != right.date ||
          left.entryType != right.entryType ||
          left.categoryId != right.categoryId ||
          left.categoryName != right.categoryName ||
          left.subcategoryId != right.subcategoryId ||
          left.subcategoryName != right.subcategoryName ||
          left.note != right.note ||
          left.createdAt != right.createdAt ||
          left.updatedAt != right.updatedAt) {
        fail(
          'state seed=$_stateSeed iteration=$iteration month=$month '
          'row index=$index expected=${right.id} actual=${left.id}',
        );
      }
    }
    month = month.next;
  }
}

int _compareTransactions(LedgerTransaction left, LedgerTransaction right) {
  final dateOrder = calendarDateToEpochDay(right.date)
      .compareTo(calendarDateToEpochDay(left.date));
  if (dateOrder != 0) return dateOrder;
  final creationOrder = right.createdAt.compareTo(left.createdAt);
  if (creationOrder != 0) return creationOrder;
  return right.id.compareTo(left.id);
}

String _randomNote(Random random, int maximumLength) {
  const tokens = ['a', 'Z', '账', '🙂', 'e\u0301', ' '];
  return List.generate(
    random.nextInt(maximumLength + 1),
    (_) => tokens[random.nextInt(tokens.length)],
  ).join();
}

String _randomDraftAmount(Random random) {
  const tokens = ['', '.', '0', '12.', '001.20', '-1', '999999999.99'];
  return tokens[random.nextInt(tokens.length)];
}

class _CategoryFixture {
  const _CategoryFixture(this.parent, this.children);

  final LedgerCategory parent;
  final List<LedgerCategory> children;
}
