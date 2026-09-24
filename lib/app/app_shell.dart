import 'package:flutter/material.dart';

import '../features/categories/application/category_application_service.dart';
import '../features/categories/data/category_repository.dart';
import '../features/categories/presentation/category_management_page.dart';
import '../l10n/app_localizations.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.categoryRepository,
    required this.categoryService,
    super.key,
  });

  final CategoryRepository categoryRepository;
  final CategoryApplicationService categoryService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _railBreakpoint = 600.0;
  int _selectedIndex = 0;

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
        _Placeholder(message: l10n.transactionsPlaceholder),
        _Placeholder(message: l10n.statisticsPlaceholder),
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

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
