import 'package:characters/characters.dart';

import '../../../core/time/year_month.dart';
import '../../categories/domain/category.dart';

const maximumTransactionAmountCents = 99999999999;
const maximumTransactionNoteCharacters = 200;

class LedgerTransaction {
  const LedgerTransaction({
    required this.id,
    required this.amountCents,
    required this.date,
    required this.entryType,
    required this.categoryId,
    required this.categoryName,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int amountCents;
  final DateTime date;
  final EntryType entryType;
  final int categoryId;
  final String categoryName;
  final int? subcategoryId;
  final String? subcategoryName;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class TransactionInput {
  const TransactionInput({
    required this.amountCents,
    required this.date,
    required this.entryType,
    required this.categoryId,
    required this.subcategoryId,
    required this.note,
  });

  factory TransactionInput.parse({
    required String amountText,
    required DateTime date,
    required EntryType entryType,
    required int? categoryId,
    required int? subcategoryId,
    required String note,
    required DateTime now,
  }) {
    if (categoryId == null) {
      throw const TransactionException(TransactionProblem.categoryRequired);
    }
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (calendarDateToEpochDay(normalizedDate) > calendarDateToEpochDay(now)) {
      throw const TransactionException(TransactionProblem.futureDate);
    }
    if (note.characters.length > maximumTransactionNoteCharacters) {
      throw const TransactionException(TransactionProblem.noteTooLong);
    }
    return TransactionInput(
      amountCents: parseAmountCents(amountText),
      date: normalizedDate,
      entryType: entryType,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      note: note,
    );
  }

  final int amountCents;
  final DateTime date;
  final EntryType entryType;
  final int categoryId;
  final int? subcategoryId;
  final String note;
}

class TransactionDraft {
  const TransactionDraft({
    required this.amountText,
    required this.entryType,
    required this.categoryId,
    required this.subcategoryId,
    required this.note,
  });

  const TransactionDraft.empty()
    : amountText = '',
      entryType = EntryType.expense,
      categoryId = null,
      subcategoryId = null,
      note = '';

  final String amountText;
  final EntryType entryType;
  final int? categoryId;
  final int? subcategoryId;
  final String note;

  bool get isEmpty =>
      amountText.isEmpty &&
      entryType == EntryType.expense &&
      categoryId == null &&
      subcategoryId == null &&
      note.isEmpty;
}

int parseAmountCents(String input) {
  if (input.isEmpty) {
    throw const TransactionException(TransactionProblem.amountRequired);
  }
  if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(input)) {
    throw const TransactionException(TransactionProblem.amountInvalid);
  }
  final parts = input.split('.');
  final whole = int.tryParse(parts.first);
  if (whole == null) {
    throw const TransactionException(TransactionProblem.amountInvalid);
  }
  final fraction = parts.length == 1
      ? 0
      : int.parse(parts.last.padRight(2, '0'));
  if (whole > maximumTransactionAmountCents ~/ 100) {
    throw const TransactionException(TransactionProblem.amountTooLarge);
  }
  final cents = whole * 100 + fraction;
  if (cents == 0) {
    throw const TransactionException(TransactionProblem.amountZero);
  }
  if (cents > maximumTransactionAmountCents) {
    throw const TransactionException(TransactionProblem.amountTooLarge);
  }
  return cents;
}

String amountCentsToInput(int amountCents) {
  final whole = amountCents ~/ 100;
  final fraction = amountCents.remainder(100).toString().padLeft(2, '0');
  return '$whole.$fraction';
}

enum TransactionProblem {
  amountRequired,
  amountInvalid,
  amountZero,
  amountTooLarge,
  futureDate,
  noteTooLong,
  categoryRequired,
  categoryInvalid,
  subcategoryInvalid,
  transactionNotFound,
}

class TransactionException implements Exception {
  const TransactionException(this.problem);

  final TransactionProblem problem;

  @override
  String toString() => 'TransactionException($problem)';
}
