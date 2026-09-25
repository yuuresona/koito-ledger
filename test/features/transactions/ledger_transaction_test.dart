import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/features/categories/domain/category.dart';
import 'package:ledger/features/transactions/domain/ledger_transaction.dart';

void main() {
  group('parseAmountCents', () {
    test('parses whole and decimal amounts without floating point', () {
      expect(parseAmountCents('1'), 100);
      expect(parseAmountCents('1.2'), 120);
      expect(parseAmountCents('999999999.99'), 99999999999);
    });

    test('rejects empty, zero, signs, exponent, and excess precision', () {
      expect(
        () => parseAmountCents(''),
        throwsA(_problem(TransactionProblem.amountRequired)),
      );
      expect(
        () => parseAmountCents('0.00'),
        throwsA(_problem(TransactionProblem.amountZero)),
      );
      for (final input in ['-1', '+1', '1e2', '.', '1.234']) {
        expect(
          () => parseAmountCents(input),
          throwsA(_problem(TransactionProblem.amountInvalid)),
          reason: input,
        );
      }
    });

    test('rejects values above the maximum', () {
      expect(
        () => parseAmountCents('1000000000.00'),
        throwsA(_problem(TransactionProblem.amountTooLarge)),
      );
    });
  });

  test('transaction input rejects future dates and overlong Unicode notes', () {
    expect(
      () => TransactionInput.parse(
        amountText: '1.00',
        date: DateTime(2026, 9, 25),
        entryType: EntryType.expense,
        categoryId: 1,
        subcategoryId: null,
        note: '',
        now: DateTime(2026, 9, 24, 23, 59),
      ),
      throwsA(_problem(TransactionProblem.futureDate)),
    );
    expect(
      () => TransactionInput.parse(
        amountText: '1.00',
        date: DateTime(2026, 9, 24),
        entryType: EntryType.expense,
        categoryId: 1,
        subcategoryId: null,
        note: List.filled(201, '账').join(),
        now: DateTime(2026, 9, 24),
      ),
      throwsA(_problem(TransactionProblem.noteTooLong)),
    );
  });
}

Matcher _problem(TransactionProblem problem) {
  return isA<TransactionException>().having(
    (error) => error.problem,
    'problem',
    problem,
  );
}
