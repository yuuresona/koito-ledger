import 'package:drift/drift.dart';
import 'package:characters/characters.dart';

import '../../../core/database/app_database.dart';
import '../../../core/time/year_month.dart';
import '../../categories/domain/category.dart';
import '../domain/ledger_transaction.dart';

class TransactionRepository {
  TransactionRepository(this.database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase database;
  final DateTime Function() _now;

  Stream<List<LedgerTransaction>> watchMonth(YearMonth month) {
    final levelTwo = database.alias(
      database.categoryRecords,
      'level_two_category',
    );
    final levelThree = database.alias(
      database.categoryRecords,
      'level_three_category',
    );
    final query = database.select(database.ledgerTransactions).join([
      innerJoin(
        levelTwo,
        levelTwo.id.equalsExp(database.ledgerTransactions.categoryId),
      ),
      leftOuterJoin(
        levelThree,
        levelThree.id.equalsExp(database.ledgerTransactions.subcategoryId),
      ),
    ]);
    query
      ..where(
        database.ledgerTransactions.dateEpochDay.isBiggerOrEqualValue(
              month.startEpochDay,
            ) &
            database.ledgerTransactions.dateEpochDay.isSmallerThanValue(
              month.endEpochDayExclusive,
            ),
      )
      ..orderBy([
        OrderingTerm.desc(database.ledgerTransactions.dateEpochDay),
        OrderingTerm.desc(database.ledgerTransactions.createdAtMicros),
        OrderingTerm.desc(database.ledgerTransactions.id),
      ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          _transactionFromRow(
            row.readTable(database.ledgerTransactions),
            row.readTable(levelTwo),
            row.readTableOrNull(levelThree),
          ),
      ],
    );
  }

  Future<List<LedgerTransaction>> listMonth(YearMonth month) =>
      _listMonth(month);

  Future<LedgerTransaction> create(TransactionInput input) {
    return database.transaction(() async {
      _validateInput(input);
      await _validateCategorySelection(input);
      final nowMicros = _now().toUtc().microsecondsSinceEpoch;
      final id = await database
          .into(database.ledgerTransactions)
          .insert(
            LedgerTransactionsCompanion(
              amountCents: Value(input.amountCents),
              dateEpochDay: Value(calendarDateToEpochDay(input.date)),
              entryType: Value(input.entryType.databaseValue),
              categoryId: Value(input.categoryId),
              subcategoryId: Value(input.subcategoryId),
              note: Value(input.note.isEmpty ? null : input.note),
              createdAtMicros: Value(nowMicros),
              updatedAtMicros: Value(nowMicros),
            ),
          );
      await (database.delete(
        database.transactionDraftRecords,
      )..where((row) => row.id.equals(1))).go();
      return _get(id);
    });
  }

  Future<LedgerTransaction> update({
    required int transactionId,
    required TransactionInput input,
  }) {
    return database.transaction(() async {
      await _requireRecord(transactionId);
      _validateInput(input);
      await _validateCategorySelection(input);
      await (database.update(
        database.ledgerTransactions,
      )..where((row) => row.id.equals(transactionId))).write(
        LedgerTransactionsCompanion(
          amountCents: Value(input.amountCents),
          dateEpochDay: Value(calendarDateToEpochDay(input.date)),
          entryType: Value(input.entryType.databaseValue),
          categoryId: Value(input.categoryId),
          subcategoryId: Value(input.subcategoryId),
          note: Value(input.note.isEmpty ? null : input.note),
          updatedAtMicros: Value(_now().toUtc().microsecondsSinceEpoch),
        ),
      );
      return _get(transactionId);
    });
  }

  Future<void> delete(int transactionId) {
    return database.transaction(() async {
      final deleted = await (database.delete(
        database.ledgerTransactions,
      )..where((row) => row.id.equals(transactionId))).go();
      if (deleted == 0) {
        throw const TransactionException(
          TransactionProblem.transactionNotFound,
        );
      }
    });
  }

  Future<TransactionDraft?> loadDraft() async {
    final query = database.select(database.transactionDraftRecords)
      ..where((row) => row.id.equals(1));
    final record = await query.getSingleOrNull();
    if (record == null) return null;

    final entryType = EntryType.fromDatabase(record.entryType);
    var categoryId = record.categoryId;
    var subcategoryId = record.subcategoryId;
    var changed = false;

    CategoryRecord? category;
    if (categoryId != null) {
      category = await _findCategory(categoryId);
      if (category == null ||
          category.parentId != null ||
          category.entryType != entryType.databaseValue) {
        categoryId = null;
        subcategoryId = null;
        changed = true;
      }
    } else if (subcategoryId != null) {
      subcategoryId = null;
      changed = true;
    }

    if (subcategoryId != null) {
      final subcategory = await _findCategory(subcategoryId);
      if (subcategory == null ||
          subcategory.parentId != category!.id ||
          subcategory.entryType != entryType.databaseValue) {
        subcategoryId = null;
        changed = true;
      }
    }

    final draft = TransactionDraft(
      amountText: record.amountText,
      entryType: entryType,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      note: record.note,
    );
    if (changed) await saveDraft(draft);
    return draft;
  }

  Future<void> saveDraft(TransactionDraft draft) async {
    await database
        .into(database.transactionDraftRecords)
        .insertOnConflictUpdate(
          TransactionDraftRecordsCompanion(
            id: const Value(1),
            amountText: Value(draft.amountText),
            entryType: Value(draft.entryType.databaseValue),
            categoryId: Value(draft.categoryId),
            subcategoryId: Value(draft.subcategoryId),
            note: Value(draft.note),
            updatedAtMicros: Value(_now().toUtc().microsecondsSinceEpoch),
          ),
        );
  }

  Future<void> clearDraft() async {
    await (database.delete(
      database.transactionDraftRecords,
    )..where((row) => row.id.equals(1))).go();
  }

  Future<void> _validateCategorySelection(TransactionInput input) async {
    final category = await _findCategory(input.categoryId);
    if (category == null ||
        category.parentId != null ||
        category.entryType != input.entryType.databaseValue) {
      throw const TransactionException(TransactionProblem.categoryInvalid);
    }
    if (input.subcategoryId == null) return;
    final subcategory = await _findCategory(input.subcategoryId!);
    if (subcategory == null ||
        subcategory.parentId != category.id ||
        subcategory.entryType != input.entryType.databaseValue) {
      throw const TransactionException(TransactionProblem.subcategoryInvalid);
    }
  }

  void _validateInput(TransactionInput input) {
    if (input.amountCents <= 0) {
      throw const TransactionException(TransactionProblem.amountZero);
    }
    if (input.amountCents > maximumTransactionAmountCents) {
      throw const TransactionException(TransactionProblem.amountTooLarge);
    }
    if (calendarDateToEpochDay(input.date) > calendarDateToEpochDay(_now())) {
      throw const TransactionException(TransactionProblem.futureDate);
    }
    if (input.note.characters.length > maximumTransactionNoteCharacters) {
      throw const TransactionException(TransactionProblem.noteTooLong);
    }
  }

  Future<List<LedgerTransaction>> _listMonth(YearMonth month) async {
    final levelTwo = database.alias(
      database.categoryRecords,
      'level_two_category',
    );
    final levelThree = database.alias(
      database.categoryRecords,
      'level_three_category',
    );
    final query = database.select(database.ledgerTransactions).join([
      innerJoin(
        levelTwo,
        levelTwo.id.equalsExp(database.ledgerTransactions.categoryId),
      ),
      leftOuterJoin(
        levelThree,
        levelThree.id.equalsExp(database.ledgerTransactions.subcategoryId),
      ),
    ]);
    query
      ..where(
        database.ledgerTransactions.dateEpochDay.isBiggerOrEqualValue(
              month.startEpochDay,
            ) &
            database.ledgerTransactions.dateEpochDay.isSmallerThanValue(
              month.endEpochDayExclusive,
            ),
      )
      ..orderBy([
        OrderingTerm.desc(database.ledgerTransactions.dateEpochDay),
        OrderingTerm.desc(database.ledgerTransactions.createdAtMicros),
        OrderingTerm.desc(database.ledgerTransactions.id),
      ]);
    return [
      for (final row in await query.get())
        _transactionFromRow(
          row.readTable(database.ledgerTransactions),
          row.readTable(levelTwo),
          row.readTableOrNull(levelThree),
        ),
    ];
  }

  Future<CategoryRecord?> _findCategory(int id) {
    final query = database.select(database.categoryRecords)
      ..where((row) => row.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<LedgerTransactionRecord> _requireRecord(int id) async {
    final query = database.select(database.ledgerTransactions)
      ..where((row) => row.id.equals(id));
    final record = await query.getSingleOrNull();
    if (record == null) {
      throw const TransactionException(TransactionProblem.transactionNotFound);
    }
    return record;
  }

  Future<LedgerTransaction> _get(int id) async {
    final levelTwo = database.alias(
      database.categoryRecords,
      'level_two_category',
    );
    final levelThree = database.alias(
      database.categoryRecords,
      'level_three_category',
    );
    final query = database.select(database.ledgerTransactions).join([
      innerJoin(
        levelTwo,
        levelTwo.id.equalsExp(database.ledgerTransactions.categoryId),
      ),
      leftOuterJoin(
        levelThree,
        levelThree.id.equalsExp(database.ledgerTransactions.subcategoryId),
      ),
    ])..where(database.ledgerTransactions.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) {
      throw const TransactionException(TransactionProblem.transactionNotFound);
    }
    return _transactionFromRow(
      row.readTable(database.ledgerTransactions),
      row.readTable(levelTwo),
      row.readTableOrNull(levelThree),
    );
  }
}

LedgerTransaction _transactionFromRow(
  LedgerTransactionRecord record,
  CategoryRecord category,
  CategoryRecord? subcategory,
) {
  return LedgerTransaction(
    id: record.id,
    amountCents: record.amountCents,
    date: epochDayToCalendarDate(record.dateEpochDay),
    entryType: EntryType.fromDatabase(record.entryType),
    categoryId: category.id,
    categoryName: category.name,
    subcategoryId: subcategory?.id,
    subcategoryName: subcategory?.name,
    note: record.note,
    createdAt: DateTime.fromMicrosecondsSinceEpoch(
      record.createdAtMicros,
      isUtc: true,
    ),
    updatedAt: DateTime.fromMicrosecondsSinceEpoch(
      record.updatedAtMicros,
      isUtc: true,
    ),
  );
}
