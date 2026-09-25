import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../data/category_repository.dart';
import '../domain/category.dart';
import '../domain/category_name.dart';

class CategoryApplicationService {
  CategoryApplicationService(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  Future<CategoryDeletionPreview> previewLevelTwoDeletion(int categoryId) {
    return _database.transaction(() async {
      final category = await _record(categoryId);
      _requireLevelTwo(category);
      final children = await _children(category.id);
      final transactions = await _transactionsForLevelTwo(category.id);
      return CategoryDeletionPreview(
        childCount: children.length,
        transactionCount: transactions.length,
      );
    });
  }

  Future<LevelThreeDeletionPreview> previewLevelThreeDeletion(int categoryId) {
    return _database.transaction(() async {
      final category = await _record(categoryId);
      _requireLevelThree(category);
      final transactions = await _transactionsForLevelThree(category.id);
      return LevelThreeDeletionPreview(transactionCount: transactions.length);
    });
  }

  Future<void> deleteLevelTwoWithSubtree(int categoryId) {
    return _database.transaction(() async {
      final category = await _record(categoryId);
      _requireLevelTwo(category);
      await (_database.delete(
        _database.ledgerTransactions,
      )..where((row) => row.categoryId.equals(category.id))).go();
      await (_database.delete(
        _database.categoryRecords,
      )..where((row) => row.parentId.equals(category.id))).go();
      await (_database.delete(
        _database.categoryRecords,
      )..where((row) => row.id.equals(category.id))).go();
    });
  }

  Future<void> deleteLevelThreeWithTransactions(int categoryId) {
    return _database.transaction(() async {
      final category = await _record(categoryId);
      _requireLevelThree(category);
      await (_database.delete(
        _database.ledgerTransactions,
      )..where((row) => row.subcategoryId.equals(category.id))).go();
      await (_database.delete(
        _database.categoryRecords,
      )..where((row) => row.id.equals(category.id))).go();
    });
  }

  Future<List<CategoryMigrationConflict>> levelTwoMigrationConflicts({
    required int sourceId,
    required int targetId,
  }) {
    return _database.transaction(() async {
      final context = await _levelTwoMigrationContext(sourceId, targetId);
      return _conflicts(context.sourceChildren, context.targetChildren);
    });
  }

  Future<void> migrateLevelTwo({
    required int sourceId,
    required int targetId,
    required Map<int, CategoryConflictResolution> resolutions,
  }) {
    return _database.transaction(() async {
      final context = await _levelTwoMigrationContext(sourceId, targetId);
      final conflicts = _conflicts(
        context.sourceChildren,
        context.targetChildren,
      );
      final conflictIds = conflicts.map((item) => item.source.id).toSet();
      if (!resolutions.keys.toSet().containsAll(conflictIds)) {
        throw const CategoryException(
          CategoryProblem.missingConflictResolution,
        );
      }
      if (resolutions.keys.any((id) => !conflictIds.contains(id))) {
        throw const CategoryException(
          CategoryProblem.invalidConflictResolution,
        );
      }

      final targetByName = {
        for (final record in context.targetChildren)
          record.normalizedName: record,
      };
      final occupiedNames = targetByName.keys.toSet();
      final moveNames = <int, CategoryName>{};
      final mergeTargets = <int, CategoryRecord>{};

      for (final sourceChild in context.sourceChildren) {
        final existing = targetByName[sourceChild.normalizedName];
        if (existing == null) {
          final parsed = CategoryName.parse(sourceChild.name);
          if (!occupiedNames.add(parsed.normalized)) {
            throw const CategoryException(CategoryProblem.duplicateName);
          }
          moveNames[sourceChild.id] = parsed;
          continue;
        }

        final resolution = resolutions[sourceChild.id];
        switch (resolution) {
          case MergeCategory():
            mergeTargets[sourceChild.id] = existing;
          case RenameAndMoveCategory(:final name):
            final parsed = CategoryName.parse(name);
            if (!occupiedNames.add(parsed.normalized)) {
              throw const CategoryException(CategoryProblem.duplicateName);
            }
            moveNames[sourceChild.id] = parsed;
          case null:
            throw const CategoryException(
              CategoryProblem.missingConflictResolution,
            );
        }
      }

      await (_database.update(_database.ledgerTransactions)
            ..where((row) => row.categoryId.equals(sourceId)))
          .write(LedgerTransactionsCompanion(categoryId: Value(targetId)));

      final updatedAt = _now().toUtc().microsecondsSinceEpoch;
      for (final sourceChild in context.sourceChildren) {
        final mergeTarget = mergeTargets[sourceChild.id];
        if (mergeTarget != null) {
          await (_database.update(
            _database.ledgerTransactions,
          )..where((row) => row.subcategoryId.equals(sourceChild.id))).write(
            LedgerTransactionsCompanion(subcategoryId: Value(mergeTarget.id)),
          );
          await (_database.delete(
            _database.categoryRecords,
          )..where((row) => row.id.equals(sourceChild.id))).go();
          continue;
        }

        final parsed = moveNames[sourceChild.id]!;
        await (_database.update(
          _database.categoryRecords,
        )..where((row) => row.id.equals(sourceChild.id))).write(
          CategoryRecordsCompanion(
            name: Value(parsed.value),
            normalizedName: Value(parsed.normalized),
            parentId: Value(targetId),
            updatedAtMicros: Value(updatedAt),
          ),
        );
      }

      await (_database.delete(
        _database.categoryRecords,
      )..where((row) => row.id.equals(sourceId))).go();
    });
  }

  Future<void> migrateLevelThreeTransactions({
    required int sourceId,
    required LevelThreeMigrationTarget target,
  }) {
    return _database.transaction(() async {
      final source = await _record(sourceId);
      _requireLevelThree(source);
      final targetLevelTwo = await _record(target.levelTwoId);
      _requireLevelTwo(targetLevelTwo);
      if (source.entryType != targetLevelTwo.entryType) {
        throw const CategoryException(CategoryProblem.crossTypeMigration);
      }

      CategoryRecord? targetLevelThree;
      if (target.levelThreeId != null) {
        targetLevelThree = await _record(target.levelThreeId!);
        _requireLevelThree(targetLevelThree);
        if (targetLevelThree.id == source.id ||
            targetLevelThree.parentId != targetLevelTwo.id ||
            targetLevelThree.entryType != source.entryType) {
          throw const CategoryException(CategoryProblem.invalidMigrationTarget);
        }
      }

      await (_database.update(
        _database.ledgerTransactions,
      )..where((row) => row.subcategoryId.equals(source.id))).write(
        LedgerTransactionsCompanion(
          categoryId: Value(targetLevelTwo.id),
          subcategoryId: Value(targetLevelThree?.id),
        ),
      );
      await (_database.delete(
        _database.categoryRecords,
      )..where((row) => row.id.equals(source.id))).go();
    });
  }

  Future<_LevelTwoMigrationContext> _levelTwoMigrationContext(
    int sourceId,
    int targetId,
  ) async {
    if (sourceId == targetId) {
      throw const CategoryException(CategoryProblem.sameCategory);
    }
    final source = await _record(sourceId);
    final target = await _record(targetId);
    _requireLevelTwo(source);
    _requireLevelTwo(target);
    if (source.entryType != target.entryType) {
      throw const CategoryException(CategoryProblem.crossTypeMigration);
    }
    return _LevelTwoMigrationContext(
      source: source,
      target: target,
      sourceChildren: await _children(source.id),
      targetChildren: await _children(target.id),
    );
  }

  List<CategoryMigrationConflict> _conflicts(
    List<CategoryRecord> sourceChildren,
    List<CategoryRecord> targetChildren,
  ) {
    final targets = {
      for (final category in targetChildren) category.normalizedName: category,
    };
    return [
      for (final source in sourceChildren)
        if (targets[source.normalizedName] case final target?)
          CategoryMigrationConflict(
            source: categoryFromRecord(source),
            target: categoryFromRecord(target),
          ),
    ];
  }

  Future<CategoryRecord> _record(int id) async {
    final query = _database.select(_database.categoryRecords)
      ..where((row) => row.id.equals(id));
    final record = await query.getSingleOrNull();
    if (record == null) {
      throw const CategoryException(CategoryProblem.categoryNotFound);
    }
    return record;
  }

  Future<List<CategoryRecord>> _children(int parentId) {
    final query = _database.select(_database.categoryRecords)
      ..where((row) => row.parentId.equals(parentId))
      ..orderBy([
        (row) => OrderingTerm.asc(row.createdAtMicros),
        (row) => OrderingTerm.asc(row.id),
      ]);
    return query.get();
  }

  Future<List<LedgerTransactionRecord>> _transactionsForLevelTwo(
    int categoryId,
  ) {
    final query = _database.select(_database.ledgerTransactions)
      ..where((row) => row.categoryId.equals(categoryId));
    return query.get();
  }

  Future<List<LedgerTransactionRecord>> _transactionsForLevelThree(
    int categoryId,
  ) {
    final query = _database.select(_database.ledgerTransactions)
      ..where((row) => row.subcategoryId.equals(categoryId));
    return query.get();
  }

  void _requireLevelTwo(CategoryRecord category) {
    if (category.parentId != null) {
      throw const CategoryException(CategoryProblem.notLevelTwo);
    }
  }

  void _requireLevelThree(CategoryRecord category) {
    if (category.parentId == null) {
      throw const CategoryException(CategoryProblem.notLevelThree);
    }
  }
}

class _LevelTwoMigrationContext {
  const _LevelTwoMigrationContext({
    required this.source,
    required this.target,
    required this.sourceChildren,
    required this.targetChildren,
  });

  final CategoryRecord source;
  final CategoryRecord target;
  final List<CategoryRecord> sourceChildren;
  final List<CategoryRecord> targetChildren;
}
