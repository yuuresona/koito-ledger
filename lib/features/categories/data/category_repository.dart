import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/category.dart';
import '../domain/category_name.dart';

class CategoryRepository {
  CategoryRepository(this.database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase database;
  final DateTime Function() _now;

  Stream<List<CategoryTree>> watchTrees(EntryType entryType) {
    final query = database.select(database.categoryRecords)
      ..where((row) => row.entryType.equals(entryType.databaseValue))
      ..orderBy([
        (row) => OrderingTerm.asc(row.createdAtMicros),
        (row) => OrderingTerm.asc(row.id),
      ]);
    return query.watch().map(_recordsToTrees);
  }

  Future<List<CategoryTree>> listTrees(EntryType entryType) async {
    final query = database.select(database.categoryRecords)
      ..where((row) => row.entryType.equals(entryType.databaseValue))
      ..orderBy([
        (row) => OrderingTerm.asc(row.createdAtMicros),
        (row) => OrderingTerm.asc(row.id),
      ]);
    return _recordsToTrees(await query.get());
  }

  Future<LedgerCategory> createLevelTwo({
    required EntryType entryType,
    required String name,
  }) {
    return database.transaction(() async {
      final parsed = CategoryName.parse(name);
      await _ensureUnique(
        entryType: entryType,
        parentId: null,
        normalizedName: parsed.normalized,
      );
      final now = _now().toUtc().microsecondsSinceEpoch;
      final id = await database
          .into(database.categoryRecords)
          .insert(
            CategoryRecordsCompanion.insert(
              name: parsed.value,
              normalizedName: parsed.normalized,
              entryType: entryType.databaseValue,
              createdAtMicros: now,
              updatedAtMicros: now,
            ),
          );
      return categoryFromRecord(await getRecord(id));
    });
  }

  Future<LedgerCategory> createLevelThree({
    required int parentId,
    required String name,
  }) {
    return database.transaction(() async {
      final parent = await getRecord(parentId);
      if (parent.parentId != null) {
        throw const CategoryException(CategoryProblem.invalidParent);
      }
      final parsed = CategoryName.parse(name);
      await _ensureUnique(
        entryType: EntryType.fromDatabase(parent.entryType),
        parentId: parent.id,
        normalizedName: parsed.normalized,
      );
      final now = _now().toUtc().microsecondsSinceEpoch;
      final id = await database
          .into(database.categoryRecords)
          .insert(
            CategoryRecordsCompanion.insert(
              name: parsed.value,
              normalizedName: parsed.normalized,
              entryType: parent.entryType,
              parentId: Value(parent.id),
              createdAtMicros: now,
              updatedAtMicros: now,
            ),
          );
      return categoryFromRecord(await getRecord(id));
    });
  }

  Future<LedgerCategory> rename({
    required int categoryId,
    required String name,
  }) {
    return database.transaction(() async {
      final current = await getRecord(categoryId);
      final parsed = CategoryName.parse(name);
      await _ensureUnique(
        entryType: EntryType.fromDatabase(current.entryType),
        parentId: current.parentId,
        normalizedName: parsed.normalized,
        excludingId: current.id,
      );
      await (database.update(
        database.categoryRecords,
      )..where((row) => row.id.equals(current.id))).write(
        CategoryRecordsCompanion(
          name: Value(parsed.value),
          normalizedName: Value(parsed.normalized),
          updatedAtMicros: Value(_now().toUtc().microsecondsSinceEpoch),
        ),
      );
      return categoryFromRecord(await getRecord(categoryId));
    });
  }

  Future<CategoryRecord> getRecord(int id) async {
    final query = database.select(database.categoryRecords)
      ..where((row) => row.id.equals(id));
    final record = await query.getSingleOrNull();
    if (record == null) {
      throw const CategoryException(CategoryProblem.categoryNotFound);
    }
    return record;
  }

  Future<void> _ensureUnique({
    required EntryType entryType,
    required int? parentId,
    required String normalizedName,
    int? excludingId,
  }) async {
    final query = database.select(database.categoryRecords)
      ..where((row) {
        Expression<bool> expression =
            row.entryType.equals(entryType.databaseValue) &
            row.normalizedName.equals(normalizedName);
        expression &= parentId == null
            ? row.parentId.isNull()
            : row.parentId.equals(parentId);
        if (excludingId != null) {
          expression &= row.id.isNotValue(excludingId);
        }
        return expression;
      });
    if (await query.getSingleOrNull() != null) {
      throw const CategoryException(CategoryProblem.duplicateName);
    }
  }

  List<CategoryTree> _recordsToTrees(List<CategoryRecord> records) {
    final parents = records.where((record) => record.parentId == null);
    return [
      for (final parent in parents)
        CategoryTree(
          category: categoryFromRecord(parent),
          children: [
            for (final child in records)
              if (child.parentId == parent.id) categoryFromRecord(child),
          ],
        ),
    ];
  }
}

LedgerCategory categoryFromRecord(CategoryRecord record) {
  return LedgerCategory(
    id: record.id,
    name: record.name,
    normalizedName: record.normalizedName,
    entryType: EntryType.fromDatabase(record.entryType),
    parentId: record.parentId,
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
