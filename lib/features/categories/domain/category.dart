enum EntryType {
  expense(0),
  income(1);

  const EntryType(this.databaseValue);

  final int databaseValue;

  static EntryType fromDatabase(int value) => switch (value) {
    0 => EntryType.expense,
    1 => EntryType.income,
    _ => throw StateError('Unknown entry type value: $value'),
  };
}

class LedgerCategory {
  const LedgerCategory({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.entryType,
    required this.parentId,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String normalizedName;
  final EntryType entryType;
  final int? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLevelTwo => parentId == null;
  bool get isLevelThree => parentId != null;
}

class CategoryTree {
  const CategoryTree({required this.category, required this.children});

  final LedgerCategory category;
  final List<LedgerCategory> children;
}

enum CategoryProblem {
  emptyName,
  nameTooLong,
  duplicateName,
  categoryNotFound,
  invalidParent,
  notLevelTwo,
  notLevelThree,
  sameCategory,
  crossTypeMigration,
  invalidMigrationTarget,
  missingConflictResolution,
  invalidConflictResolution,
}

class CategoryException implements Exception {
  const CategoryException(this.problem);

  final CategoryProblem problem;

  @override
  String toString() => 'CategoryException($problem)';
}

class CategoryDeletionPreview {
  const CategoryDeletionPreview({
    required this.childCount,
    required this.transactionCount,
  });

  final int childCount;
  final int transactionCount;
}

class LevelThreeDeletionPreview {
  const LevelThreeDeletionPreview({required this.transactionCount});

  final int transactionCount;
}

class CategoryMigrationConflict {
  const CategoryMigrationConflict({required this.source, required this.target});

  final LedgerCategory source;
  final LedgerCategory target;
}

sealed class CategoryConflictResolution {
  const CategoryConflictResolution();
}

class MergeCategory extends CategoryConflictResolution {
  const MergeCategory();
}

class RenameAndMoveCategory extends CategoryConflictResolution {
  const RenameAndMoveCategory(this.name);

  final String name;
}

class LevelThreeMigrationTarget {
  const LevelThreeMigrationTarget({
    required this.levelTwoId,
    this.levelThreeId,
  });

  final int levelTwoId;
  final int? levelThreeId;
}
