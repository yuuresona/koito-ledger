import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/time/year_month.dart';
import '../../../l10n/app_localizations.dart';
import '../../categories/data/category_repository.dart';
import '../../categories/domain/category.dart';
import '../data/transaction_repository.dart';
import '../domain/ledger_transaction.dart';

Future<DateTime?> showTransactionFormSheet({
  required BuildContext context,
  required TransactionRepository transactionRepository,
  required CategoryRepository categoryRepository,
  required YearMonth selectedMonth,
  LedgerTransaction? transaction,
  DateTime Function()? now,
}) async {
  final draft = transaction == null
      ? await transactionRepository.loadDraft()
      : null;
  if (!context.mounted) return null;
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => TransactionFormSheet(
      transactionRepository: transactionRepository,
      categoryRepository: categoryRepository,
      selectedMonth: selectedMonth,
      transaction: transaction,
      initialDraft: draft,
      now: now,
    ),
  );
}

class TransactionFormSheet extends StatefulWidget {
  const TransactionFormSheet({
    required this.transactionRepository,
    required this.categoryRepository,
    required this.selectedMonth,
    required this.transaction,
    required this.initialDraft,
    this.now,
    super.key,
  });

  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;
  final YearMonth selectedMonth;
  final LedgerTransaction? transaction;
  final TransactionDraft? initialDraft;
  final DateTime Function()? now;

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late EntryType _entryType;
  late DateTime _date;
  int? _categoryId;
  int? _subcategoryId;
  String? _categoryError;
  bool _saving = false;
  bool _dirty = false;
  bool _suppressDirty = false;
  bool _allowPop = false;
  bool _closing = false;
  bool _completed = false;

  bool get _isEditing => widget.transaction != null;
  DateTime get _now => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    final draft = widget.initialDraft;
    _amountController = TextEditingController(
      text: transaction == null
          ? draft?.amountText ?? ''
          : amountCentsToInput(transaction.amountCents),
    );
    _noteController = TextEditingController(
      text: transaction?.note ?? draft?.note ?? '',
    );
    _entryType =
        transaction?.entryType ?? draft?.entryType ?? EntryType.expense;
    _categoryId = transaction?.categoryId ?? draft?.categoryId;
    _subcategoryId = transaction?.subcategoryId ?? draft?.subcategoryId;
    _date =
        transaction?.date ?? widget.selectedMonth.defaultTransactionDate(_now);
    _amountController.addListener(_markDirty);
    _noteController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _amountController
      ..removeListener(_markDirty)
      ..dispose();
    _noteController
      ..removeListener(_markDirty)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope<DateTime>(
      canPop: !_saving && (_isEditing || _allowPop),
      onPopInvokedWithResult: _handlePop,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? l10n.editTransaction : l10n.newTransaction,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(context)
                          .closeButtonTooltip,
                      onPressed: _saving
                          ? null
                          : () => Navigator.maybePop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SegmentedButton<EntryType>(
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
                    setState(() {
                      _entryType = selection.single;
                      _categoryId = null;
                      _subcategoryId = null;
                      _categoryError = null;
                      _dirty = true;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('transaction-amount'),
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    hintText: l10n.amountHint,
                    prefixText: '¥',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  validator: (value) => _amountError(context, value ?? ''),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.date),
                  subtitle: Text(
                    DateFormat.yMMMMd(
                      Localizations.localeOf(context).toLanguageTag(),
                    ).format(_date),
                  ),
                  trailing: const Icon(Icons.calendar_month_outlined),
                  onTap: _pickDate,
                ),
                StreamBuilder<List<CategoryTree>>(
                  stream: widget.categoryRepository.watchTrees(_entryType),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _CategoryLoadError(onRetry: () => setState(() {}));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _buildCategoryFields(context, snapshot.data!);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('transaction-note'),
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: l10n.note,
                    border: const OutlineInputBorder(),
                  ),
                  maxLength: maximumTransactionNoteCharacters,
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_isEditing)
                      TextButton.icon(
                        onPressed: _saving ? null : _confirmDelete,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l10n.delete),
                      )
                    else
                      TextButton(
                        onPressed: _saving ? null : _clearDraft,
                        child: Text(l10n.clearDraft),
                      ),
                    const Spacer(),
                    FilledButton(
                      key: const Key('save-transaction'),
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFields(BuildContext context, List<CategoryTree> trees) {
    final l10n = AppLocalizations.of(context)!;
    final selectedTree = _treeById(trees, _categoryId);
    final effectiveCategoryId = selectedTree?.category.id;
    final selectedSubcategory = selectedTree?.children
        .where((category) => category.id == _subcategoryId)
        .firstOrNull;
    final effectiveSubcategoryId = selectedSubcategory?.id;

    if (trees.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: _createLevelTwo,
            icon: const Icon(Icons.add),
            label: Text(l10n.createCategory),
          ),
          if (_categoryError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _categoryError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: KeyedSubtree(
                key: ValueKey(
                  'category-${_entryType.name}-$effectiveCategoryId-${trees.length}',
                ),
                child: DropdownMenu<int>(
                  key: const Key('transaction-category'),
                  initialSelection: effectiveCategoryId,
                  label: Text(l10n.category),
                  expandedInsets: EdgeInsets.zero,
                  dropdownMenuEntries: [
                    for (final tree in trees)
                      DropdownMenuEntry(
                        value: tree.category.id,
                        label: tree.category.name,
                      ),
                  ],
                  onSelected: (value) {
                    setState(() {
                      _categoryId = value;
                      _subcategoryId = null;
                      _categoryError = null;
                      _dirty = true;
                    });
                  },
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.addCategory,
              onPressed: _createLevelTwo,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (_categoryError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _categoryError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: KeyedSubtree(
                key: ValueKey(
                  'subcategory-$effectiveCategoryId-$effectiveSubcategoryId-${selectedTree?.children.length ?? 0}',
                ),
                child: DropdownMenu<int>(
                  key: const Key('transaction-subcategory'),
                  initialSelection: effectiveSubcategoryId ?? 0,
                  enabled: selectedTree != null,
                  label: Text(l10n.subcategory),
                  expandedInsets: EdgeInsets.zero,
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: 0, label: l10n.none),
                    for (final category in selectedTree?.children ?? const [])
                      DropdownMenuEntry(
                        value: category.id,
                        label: category.name,
                      ),
                  ],
                  onSelected: (value) {
                    setState(() {
                      _subcategoryId = value == 0 ? null : value;
                      _dirty = true;
                    });
                  },
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.addSubcategory,
              onPressed: selectedTree == null ? null : _createLevelThree,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final today = DateTime(_now.year, _now.month, _now.day);
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1),
      lastDate: today,
    );
    if (result != null) {
      setState(() {
        _date = result;
        _dirty = true;
      });
    }
  }

  Future<void> _createLevelTwo() async {
    final category = await _showCreateCategoryDialog();
    if (category == null || !mounted) return;
    setState(() {
      _categoryId = category.id;
      _subcategoryId = null;
      _categoryError = null;
      _dirty = true;
    });
  }

  Future<void> _createLevelThree() async {
    final parentId = _categoryId;
    if (parentId == null) return;
    final category = await _showCreateCategoryDialog(parentId: parentId);
    if (category == null || !mounted) return;
    setState(() {
      _subcategoryId = category.id;
      _dirty = true;
    });
  }

  Future<LedgerCategory?> _showCreateCategoryDialog({int? parentId}) async {
    return showDialog<LedgerCategory>(
      context: context,
      builder: (context) => _CreateCategoryDialog(
        repository: widget.categoryRepository,
        entryType: _entryType,
        parentId: parentId,
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _categoryError = null);
    if (!_formKey.currentState!.validate()) return;
    TransactionInput input;
    try {
      input = TransactionInput.parse(
        amountText: _amountController.text,
        date: _date,
        entryType: _entryType,
        categoryId: _categoryId,
        subcategoryId: _subcategoryId,
        note: _noteController.text,
        now: _now,
      );
    } on TransactionException catch (error) {
      if (error.problem == TransactionProblem.categoryRequired ||
          error.problem == TransactionProblem.categoryInvalid ||
          error.problem == TransactionProblem.subcategoryInvalid) {
        setState(() => _categoryError = _transactionError(context, error));
      } else {
        _showSaveError(error, onRetry: _save);
      }
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await widget.transactionRepository.update(
          transactionId: widget.transaction!.id,
          input: input,
        );
      } else {
        await widget.transactionRepository.create(input);
      }
      if (!mounted) return;
      _completed = true;
      _allowPop = true;
      Navigator.pop(context, input.date);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      if (error is TransactionException &&
          (error.problem == TransactionProblem.categoryInvalid ||
              error.problem == TransactionProblem.subcategoryInvalid)) {
        setState(() => _categoryError = _transactionError(context, error));
      }
      _showSaveError(error, onRetry: _save);
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.deleteTransaction),
            content: Text(l10n.deleteTransactionConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    await _delete();
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    try {
      await widget.transactionRepository.delete(widget.transaction!.id);
      if (!mounted) return;
      _completed = true;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.transactionDeleteFailed),
          action: SnackBarAction(label: l10n.retry, onPressed: _delete),
        ),
      );
    }
  }

  Future<void> _clearDraft() async {
    setState(() => _saving = true);
    try {
      await widget.transactionRepository.clearDraft();
      if (!mounted) return;
      _suppressDirty = true;
      _amountController.clear();
      _noteController.clear();
      setState(() {
        _entryType = EntryType.expense;
        _categoryId = null;
        _subcategoryId = null;
        _categoryError = null;
        _date = widget.selectedMonth.defaultTransactionDate(_now);
        _dirty = false;
        _saving = false;
      });
      _suppressDirty = false;
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSaveError(error, onRetry: _clearDraft);
    }
  }

  Future<void> _handlePop(bool didPop, DateTime? result) async {
    if (didPop || _saving || _isEditing || _allowPop || _closing) return;
    _closing = true;
    try {
      if (_dirty && !_completed) {
        await widget.transactionRepository.saveDraft(_currentDraft());
      }
      if (!mounted) return;
      setState(() => _allowPop = true);
      Navigator.pop(context);
    } catch (error) {
      _closing = false;
      if (mounted) {
        _showSaveError(error, onRetry: () => _handlePop(false, null));
      }
    }
  }

  TransactionDraft _currentDraft() {
    return TransactionDraft(
      amountText: _amountController.text,
      entryType: _entryType,
      categoryId: _categoryId,
      subcategoryId: _subcategoryId,
      note: _noteController.text,
    );
  }

  void _markDirty() {
    if (!_suppressDirty && !_isEditing) _dirty = true;
  }

  void _showSaveError(Object error, {required VoidCallback onRetry}) {
    final l10n = AppLocalizations.of(context)!;
    final message = error is TransactionException
        ? _transactionError(context, error)
        : l10n.transactionSaveFailed;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: l10n.retry, onPressed: onRetry),
      ),
    );
  }
}

CategoryTree? _treeById(List<CategoryTree> trees, int? id) {
  for (final tree in trees) {
    if (tree.category.id == id) return tree;
  }
  return null;
}

String? _amountError(BuildContext context, String value) {
  try {
    parseAmountCents(value);
    return null;
  } on TransactionException catch (error) {
    return _transactionError(context, error);
  }
}

String _transactionError(BuildContext context, TransactionException error) {
  final l10n = AppLocalizations.of(context)!;
  return switch (error.problem) {
    TransactionProblem.amountRequired => l10n.amountRequired,
    TransactionProblem.amountInvalid => l10n.amountInvalid,
    TransactionProblem.amountZero => l10n.amountZero,
    TransactionProblem.amountTooLarge => l10n.amountTooLarge,
    TransactionProblem.futureDate => l10n.futureDateNotAllowed,
    TransactionProblem.noteTooLong => l10n.noteTooLong,
    TransactionProblem.categoryRequired ||
    TransactionProblem.categoryInvalid => l10n.categoryRequired,
    TransactionProblem.subcategoryInvalid => l10n.subcategoryInvalid,
    TransactionProblem.transactionNotFound => l10n.transactionSaveFailed,
  };
}

String _categoryOperationError(BuildContext context, Object error) {
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

class _CreateCategoryDialog extends StatefulWidget {
  const _CreateCategoryDialog({
    required this.repository,
    required this.entryType,
    required this.parentId,
  });

  final CategoryRepository repository;
  final EntryType entryType;
  final int? parentId;

  @override
  State<_CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<_CreateCategoryDialog> {
  final _controller = TextEditingController();
  String? _errorText;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        widget.parentId == null ? l10n.addCategory : l10n.addSubcategory,
      ),
      content: TextField(
        autofocus: true,
        controller: _controller,
        decoration: InputDecoration(
          labelText: l10n.categoryName,
          errorText: _errorText,
        ),
        onSubmitted: _saving ? null : (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _errorText = null;
    });
    try {
      final category = widget.parentId == null
          ? await widget.repository.createLevelTwo(
              entryType: widget.entryType,
              name: _controller.text,
            )
          : await widget.repository.createLevelThree(
              parentId: widget.parentId!,
              name: _controller.text,
            );
      if (mounted) Navigator.pop(context, category);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorText = _categoryOperationError(context, error);
      });
    }
  }
}

class _CategoryLoadError extends StatelessWidget {
  const _CategoryLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(l10n.retry),
      ),
    );
  }
}
