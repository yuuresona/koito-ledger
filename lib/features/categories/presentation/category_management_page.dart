import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../application/category_application_service.dart';
import '../data/category_repository.dart';
import '../domain/category.dart';
import '../domain/category_name.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({
    required this.repository,
    required this.service,
    super.key,
  });

  final CategoryRepository repository;
  final CategoryApplicationService service;

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  EntryType _entryType = EntryType.expense;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.categories)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<EntryType>(
                segments: [
                  ButtonSegment(
                    value: EntryType.expense,
                    label: Text(l10n.expense),
                  ),
                  ButtonSegment(
                    value: EntryType.income,
                    label: Text(l10n.income),
                  ),
                ],
                selected: {_entryType},
                onSelectionChanged: (selection) {
                  setState(() => _entryType = selection.single);
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CategoryTree>>(
              stream: widget.repository.watchTrees(_entryType),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _InlineError(onRetry: () => setState(() {}));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final trees = snapshot.data!;
                if (trees.isEmpty) {
                  return _EmptyCategories(
                    message: _entryType == EntryType.expense
                        ? l10n.noExpenseCategories
                        : l10n.noIncomeCategories,
                    onAdd: _addLevelTwo,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: trees.length,
                  itemBuilder: (context, index) {
                    return _CategoryTreeTile(
                      tree: trees[index],
                      onAddChild: () => _addLevelThree(trees[index].category),
                      onRenameParent: () => _rename(trees[index].category),
                      onDeleteParent: () =>
                          _deleteLevelTwo(trees[index].category),
                      onRenameChild: _rename,
                      onDeleteChild: _deleteLevelThree,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addLevelTwo,
        icon: const Icon(Icons.add),
        label: Text(l10n.addCategory),
      ),
    );
  }

  Future<void> _addLevelTwo() async {
    final l10n = AppLocalizations.of(context)!;
    await _showNameDialog(
      title: l10n.addCategory,
      onSave: (name) =>
          widget.repository.createLevelTwo(entryType: _entryType, name: name),
    );
  }

  Future<void> _addLevelThree(LedgerCategory parent) async {
    final l10n = AppLocalizations.of(context)!;
    await _showNameDialog(
      title: l10n.addSubcategory,
      onSave: (name) =>
          widget.repository.createLevelThree(parentId: parent.id, name: name),
    );
  }

  Future<void> _rename(LedgerCategory category) async {
    final l10n = AppLocalizations.of(context)!;
    await _showNameDialog(
      title: l10n.rename,
      initialValue: category.name,
      onSave: (name) =>
          widget.repository.rename(categoryId: category.id, name: name),
    );
  }

  Future<void> _deleteLevelTwo(LedgerCategory category) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final preview = await widget.service.previewLevelTwoDeletion(category.id);
      if (!mounted) return;
      final choice = await showDialog<_LevelTwoDeleteChoice>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: Text(l10n.deleteCategory),
          children: [
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(dialogContext, _LevelTwoDeleteChoice.delete),
              child: ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.deleteCategoryAndRecords),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(dialogContext, _LevelTwoDeleteChoice.move),
              child: ListTile(
                leading: const Icon(Icons.drive_file_move_outline),
                title: Text(l10n.moveCategoryAndRecords),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      );
      if (!mounted || choice == null) return;

      if (choice == _LevelTwoDeleteChoice.delete) {
        final confirmed = await _confirm(
          title: l10n.deleteCategory,
          message: l10n.deleteCategorySummary(
            preview.childCount,
            preview.transactionCount,
          ),
        );
        if (confirmed) {
          await _runOperation(
            () => widget.service.deleteLevelTwoWithSubtree(category.id),
          );
        }
        return;
      }

      final trees = await widget.repository.listTrees(category.entryType);
      if (!mounted) return;
      final targets = trees
          .map((tree) => tree.category)
          .where((item) => item.id != category.id)
          .toList();
      if (targets.isEmpty) {
        await _showMessage(l10n.noMigrationTargets);
        return;
      }
      final target = await _selectLevelTwoTarget(targets);
      if (target == null || !mounted) return;

      final conflicts = await widget.service.levelTwoMigrationConflicts(
        sourceId: category.id,
        targetId: target.id,
      );
      if (!mounted) return;
      final resolutions = <int, CategoryConflictResolution>{};
      for (final conflict in conflicts) {
        final resolution = await _resolveConflict(conflict);
        if (resolution == null || !mounted) return;
        resolutions[conflict.source.id] = resolution;
      }

      final confirmed = await _confirm(
        title: l10n.moveCategoryAndRecords,
        message: l10n.moveCategoryConfirmation(target.name),
      );
      if (confirmed) {
        await _runOperation(
          () => widget.service.migrateLevelTwo(
            sourceId: category.id,
            targetId: target.id,
            resolutions: resolutions,
          ),
        );
      }
    } catch (error) {
      _showOperationError(error);
    }
  }

  Future<void> _deleteLevelThree(LedgerCategory category) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final preview = await widget.service.previewLevelThreeDeletion(
        category.id,
      );
      if (!mounted) return;
      final choice = await showDialog<_LevelThreeDeleteChoice>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: Text(l10n.deleteSubcategory),
          children: [
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(dialogContext, _LevelThreeDeleteChoice.delete),
              child: ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.deleteSubcategoryAndRecords),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(dialogContext, _LevelThreeDeleteChoice.move),
              child: ListTile(
                leading: const Icon(Icons.drive_file_move_outline),
                title: Text(l10n.moveSubcategoryRecords),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      );
      if (choice == null || !mounted) return;

      if (choice == _LevelThreeDeleteChoice.delete) {
        final confirmed = await _confirm(
          title: l10n.deleteSubcategory,
          message: l10n.deleteSubcategorySummary(preview.transactionCount),
        );
        if (confirmed) {
          await _runOperation(
            () => widget.service.deleteLevelThreeWithTransactions(category.id),
          );
        }
        return;
      }

      final trees = await widget.repository.listTrees(category.entryType);
      if (!mounted) return;
      final options = <_LevelThreeTargetOption>[
        for (final tree in trees) ...[
          _LevelThreeTargetOption(
            target: LevelThreeMigrationTarget(levelTwoId: tree.category.id),
            label: l10n.categoryOnlyTarget(tree.category.name),
          ),
          for (final child in tree.children)
            if (child.id != category.id)
              _LevelThreeTargetOption(
                target: LevelThreeMigrationTarget(
                  levelTwoId: tree.category.id,
                  levelThreeId: child.id,
                ),
                label: '${tree.category.name} · ${child.name}',
              ),
        ],
      ];
      final target = await _selectLevelThreeTarget(options);
      if (target == null || !mounted) return;
      final targetName = options
          .firstWhere((option) => option.target == target)
          .label;
      final confirmed = await _confirm(
        title: l10n.moveSubcategoryRecords,
        message: l10n.moveSubcategoryConfirmation(
          preview.transactionCount,
          targetName,
        ),
      );
      if (confirmed) {
        await _runOperation(
          () => widget.service.migrateLevelThreeTransactions(
            sourceId: category.id,
            target: target,
          ),
        );
      }
    } catch (error) {
      _showOperationError(error);
    }
  }

  Future<void> _showNameDialog({
    required String title,
    required Future<Object?> Function(String name) onSave,
    String initialValue = '',
  }) async {
    var value = initialValue;
    String? errorText;
    var saving = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(title),
            content: TextFormField(
              initialValue: initialValue,
              autofocus: true,
              maxLength: 30,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.categoryName,
                errorText: errorText,
              ),
              onChanged: (newValue) => value = newValue,
              onFieldSubmitted: saving
                  ? null
                  : (_) => _saveName(
                      dialogContext: dialogContext,
                      setDialogState: setDialogState,
                      name: value,
                      onSave: onSave,
                      setSaving: (value) => saving = value,
                      setError: (value) => errorText = value,
                    ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () => _saveName(
                        dialogContext: dialogContext,
                        setDialogState: setDialogState,
                        name: value,
                        onSave: onSave,
                        setSaving: (value) => saving = value,
                        setError: (value) => errorText = value,
                      ),
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveName({
    required BuildContext dialogContext,
    required StateSetter setDialogState,
    required String name,
    required Future<Object?> Function(String name) onSave,
    required ValueChanged<bool> setSaving,
    required ValueChanged<String?> setError,
  }) async {
    setDialogState(() {
      setSaving(true);
      setError(null);
    });
    try {
      await onSave(name);
      if (dialogContext.mounted) Navigator.pop(dialogContext);
    } catch (error) {
      if (!dialogContext.mounted) return;
      setDialogState(() {
        setSaving(false);
        setError(_errorMessage(dialogContext, error));
      });
    }
  }

  Future<String?> _promptNameValue({
    required String title,
    required String initialValue,
  }) async {
    var value = initialValue;
    String? errorText;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(title),
            content: TextFormField(
              initialValue: initialValue,
              autofocus: true,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: l10n.categoryName,
                errorText: errorText,
              ),
              onChanged: (newValue) => value = newValue,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  try {
                    final parsed = CategoryName.parse(value);
                    Navigator.pop(dialogContext, parsed.value);
                  } catch (error) {
                    setDialogState(
                      () => errorText = _errorMessage(dialogContext, error),
                    );
                  }
                },
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<LedgerCategory?> _selectLevelTwoTarget(List<LedgerCategory> targets) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<LedgerCategory>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.selectTargetCategory),
        children: [
          for (final target in targets)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, target),
              child: Text(target.name),
            ),
        ],
      ),
    );
  }

  Future<LevelThreeMigrationTarget?> _selectLevelThreeTarget(
    List<_LevelThreeTargetOption> options,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<LevelThreeMigrationTarget>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.selectTargetCategory),
        children: [
          for (final option in options)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, option.target),
              child: Text(option.label),
            ),
        ],
      ),
    );
  }

  Future<CategoryConflictResolution?> _resolveConflict(
    CategoryMigrationConflict conflict,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await showDialog<_ConflictChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resolveNameConflict),
        content: Text(l10n.categoryConflictMessage(conflict.source.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _ConflictChoice.merge),
            child: Text(l10n.merge),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _ConflictChoice.rename),
            child: Text(l10n.renameAndMove),
          ),
        ],
      ),
    );
    if (choice == _ConflictChoice.merge) return const MergeCategory();
    if (choice != _ConflictChoice.rename || !mounted) return null;
    final name = await _promptNameValue(
      title: l10n.renameAndMove,
      initialValue: conflict.source.name,
    );
    return name == null ? null : RenameAndMoveCategory(name);
  }

  Future<bool> _confirm({
    required String title,
    required String message,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.confirm),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showMessage(String message) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _runOperation(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (error) {
      _showOperationError(error, onRetry: () => _runOperation(operation));
    }
  }

  void _showOperationError(Object error, {VoidCallback? onRetry}) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_errorMessage(context, error)),
        action: onRetry == null
            ? null
            : SnackBarAction(label: l10n.retry, onPressed: onRetry),
      ),
    );
  }

  String _errorMessage(BuildContext context, Object error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is CategoryException) {
      return switch (error.problem) {
        CategoryProblem.emptyName => l10n.categoryNameRequired,
        CategoryProblem.nameTooLong => l10n.categoryNameTooLong,
        CategoryProblem.duplicateName => l10n.categoryNameDuplicate,
        _ => l10n.categoryOperationFailed,
      };
    }
    return l10n.categoryOperationFailed;
  }
}

class _CategoryTreeTile extends StatelessWidget {
  const _CategoryTreeTile({
    required this.tree,
    required this.onAddChild,
    required this.onRenameParent,
    required this.onDeleteParent,
    required this.onRenameChild,
    required this.onDeleteChild,
  });

  final CategoryTree tree;
  final VoidCallback onAddChild;
  final VoidCallback onRenameParent;
  final VoidCallback onDeleteParent;
  final ValueChanged<LedgerCategory> onRenameChild;
  final ValueChanged<LedgerCategory> onDeleteChild;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ExpansionTile(
      key: PageStorageKey(tree.category.id),
      title: Text(tree.category.name),
      controlAffinity: ListTileControlAffinity.leading,
      trailing: PopupMenuButton<_ParentAction>(
        onSelected: (action) {
          switch (action) {
            case _ParentAction.addChild:
              onAddChild();
            case _ParentAction.rename:
              onRenameParent();
            case _ParentAction.delete:
              onDeleteParent();
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _ParentAction.addChild,
            child: Text(l10n.addSubcategory),
          ),
          PopupMenuItem(value: _ParentAction.rename, child: Text(l10n.rename)),
          PopupMenuItem(value: _ParentAction.delete, child: Text(l10n.delete)),
        ],
      ),
      children: [
        for (final child in tree.children)
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 56, right: 8),
            title: Text(child.name),
            trailing: PopupMenuButton<_ChildAction>(
              onSelected: (action) {
                switch (action) {
                  case _ChildAction.rename:
                    onRenameChild(child);
                  case _ChildAction.delete:
                    onDeleteChild(child);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _ChildAction.rename,
                  child: Text(l10n.rename),
                ),
                PopupMenuItem(
                  value: _ChildAction.delete,
                  child: Text(l10n.delete),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories({required this.message, required this.onAdd});

  final String message;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(l10n.addCategory),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.categoryOperationFailed),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}

class _LevelThreeTargetOption {
  const _LevelThreeTargetOption({required this.target, required this.label});

  final LevelThreeMigrationTarget target;
  final String label;
}

enum _ParentAction { addChild, rename, delete }

enum _ChildAction { rename, delete }

enum _LevelTwoDeleteChoice { delete, move }

enum _LevelThreeDeleteChoice { delete, move }

enum _ConflictChoice { merge, rename }
