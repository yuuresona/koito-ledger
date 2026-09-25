import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@TableIndex.sql('''
CREATE UNIQUE INDEX categories_level2_name_unique
ON categories (entry_type, normalized_name)
WHERE parent_id IS NULL;
''')
@TableIndex.sql('''
CREATE UNIQUE INDEX categories_level3_name_unique
ON categories (parent_id, normalized_name)
WHERE parent_id IS NOT NULL;
''')
@TableIndex(
  name: 'categories_creation_order',
  columns: {#entryType, #parentId, #createdAtMicros, #id},
)
class CategoryRecords extends Table {
  @override
  String get tableName => 'categories';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 30)();
  TextColumn get normalizedName => text().withLength(min: 1, max: 30)();
  IntColumn get entryType =>
      integer().customConstraint('NOT NULL CHECK (entry_type IN (0, 1))')();
  IntColumn get parentId => integer().nullable().references(
    CategoryRecords,
    #id,
    onDelete: KeyAction.restrict,
  )();
  IntColumn get createdAtMicros => integer()();
  IntColumn get updatedAtMicros => integer()();
}

@TableIndex(
  name: 'transactions_month_order',
  columns: {#dateEpochDay, #createdAtMicros},
)
@TableIndex(name: 'transactions_category', columns: {#categoryId})
@TableIndex(name: 'transactions_subcategory', columns: {#subcategoryId})
@DataClassName('LedgerTransactionRecord')
class LedgerTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountCents => integer().customConstraint(
    'NOT NULL CHECK (amount_cents > 0 AND amount_cents <= 99999999999)',
  )();
  IntColumn get dateEpochDay => integer()();
  IntColumn get entryType =>
      integer().customConstraint('NOT NULL CHECK (entry_type IN (0, 1))')();

  @ReferenceName('levelTwoCategory')
  IntColumn get categoryId => integer().references(
    CategoryRecords,
    #id,
    onDelete: KeyAction.restrict,
  )();

  @ReferenceName('levelThreeCategory')
  IntColumn get subcategoryId => integer().nullable().references(
    CategoryRecords,
    #id,
    onDelete: KeyAction.restrict,
  )();

  TextColumn get note => text().nullable()();
  IntColumn get createdAtMicros => integer()();
  IntColumn get updatedAtMicros => integer()();
}

class TransactionDraftRecords extends Table {
  IntColumn get id => integer().customConstraint('NOT NULL CHECK (id = 1)')();
  TextColumn get amountText => text()();
  IntColumn get entryType =>
      integer().customConstraint('NOT NULL CHECK (entry_type IN (0, 1))')();

  @ReferenceName('draftLevelTwoCategory')
  IntColumn get categoryId => integer().nullable().references(
    CategoryRecords,
    #id,
    onDelete: KeyAction.setNull,
  )();

  @ReferenceName('draftLevelThreeCategory')
  IntColumn get subcategoryId => integer().nullable().references(
    CategoryRecords,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get note => text()();
  IntColumn get updatedAtMicros => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [CategoryRecords, LedgerTransactions, TransactionDraftRecords],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'ledger'));

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from == 1 && to == 2) {
        await migrator.createTable(transactionDraftRecords);
        return;
      }
      throw StateError('Missing database migration from $from to $to.');
    },
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
