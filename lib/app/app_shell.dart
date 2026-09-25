import 'package:flutter/material.dart';

import '../core/time/year_month.dart';
import '../features/categories/application/category_application_service.dart';
import '../features/categories/data/category_repository.dart';
import '../features/categories/presentation/category_management_page.dart';
import '../features/statistics/data/statistics_repository.dart';
import '../features/statistics/presentation/statistics_page.dart';
import '../features/transactions/data/transaction_repository.dart';
import '../features/transactions/domain/ledger_transaction.dart';
import '../features/transactions/presentation/transaction_form_sheet.dart';
import '../features/transactions/presentation/transactions_page.dart';
import '../l10n/app_localizations.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.categoryRepository,
    required this.categoryService,
    required this.transactionRepository,
    required this.statisticsRepository,
    super.key,
  });

  final CategoryRepository categoryRepository;
  final CategoryApplicationService categoryService;
  final TransactionRepository transactionRepository;
  final StatisticsRepository statisticsRepository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _railBreakpoint = 600.0;
  int _selectedIndex = 0;
  YearMonth _selectedMonth = YearMonth.current();
  bool _transactionFormOpen = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.receipt_long_outlined),
        selectedIcon: const Icon(Icons.receipt_long),
        label: l10n.transactions,
      ),
      NavigationDestination(
        icon: const Icon(Icons.bar_chart_outlined),
        selectedIcon: const Icon(Icons.bar_chart),
        label: l10n.statistics,
      ),
    ];

    final content = IndexedStack(
      index: _selectedIndex,
      children: [
        TransactionsPage(
          repository: widget.transactionRepository,
          selectedMonth: _selectedMonth,
          onMonthChanged: _selectMonth,
          onEdit: _openExistingTransaction,
        ),
        StatisticsPage(
          repository: widget.statisticsRepository,
          selectedMonth: _selectedMonth,
          onMonthChanged: _selectMonth,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= _railBreakpoint;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            actions: [
              if (_selectedIndex == 0)
                IconButton(
                  key: const Key('manage-categories'),
                  tooltip: l10n.manageCategories,
                  onPressed: _openCategories,
                  icon: const Icon(Icons.category_outlined),
                ),
            ],
          ),
          body: useRail
              ? Row(
                  children: [
                    SafeArea(
                      top: false,
                      child: NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: _selectDestination,
                        labelType: NavigationRailLabelType.all,
                        destinations: [
                          NavigationRailDestination(
                            icon: const Icon(Icons.receipt_long_outlined),
                            selectedIcon: const Icon(Icons.receipt_long),
                            label: Text(l10n.transactions),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.bar_chart_outlined),
                            selectedIcon: const Icon(Icons.bar_chart),
                            label: Text(l10n.statistics),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: SafeArea(top: false, child: content)),
                  ],
                )
              : SafeArea(top: false, child: content),
          floatingActionButton: _selectedIndex == 0
              ? FloatingActionButton(
                  key: const Key('add-transaction'),
                  tooltip: l10n.addTransaction,
                  onPressed: _openNewTransaction,
                  child: const Icon(Icons.add),
                )
              : null,
          bottomNavigationBar: useRail
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectDestination,
                  destinations: destinations,
                ),
        );
      },
    );
  }

  void _selectDestination(int index) {
    setState(() => _selectedIndex = index);
  }

  void _selectMonth(YearMonth month) {
    setState(() => _selectedMonth = month);
  }

  Future<void> _openNewTransaction() async {
    await _openTransaction();
  }

  Future<void> _openExistingTransaction(LedgerTransaction transaction) async {
    await _openTransaction(transaction);
  }

  Future<void> _openTransaction([LedgerTransaction? transaction]) async {
    if (_transactionFormOpen) return;
    _transactionFormOpen = true;
    try {
      final savedDate = await showTransactionFormSheet(
        context: context,
        transactionRepository: widget.transactionRepository,
        categoryRepository: widget.categoryRepository,
        selectedMonth: _selectedMonth,
        transaction: transaction,
      );
      if (savedDate != null && mounted) {
        setState(() => _selectedMonth = YearMonth.fromDate(savedDate));
      }
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.transactionSaveFailed)));
    } finally {
      _transactionFormOpen = false;
    }
  }

  void _openCategories() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoryManagementPage(
          repository: widget.categoryRepository,
          service: widget.categoryService,
        ),
      ),
    );
  }
}
