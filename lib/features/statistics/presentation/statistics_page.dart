import 'package:flutter/material.dart';

import '../../../core/money/cny_formatter.dart';
import '../../../core/time/year_month.dart';
import '../../../l10n/app_localizations.dart';
import '../../categories/domain/category.dart';
import '../../transactions/presentation/month_navigator.dart';
import '../data/statistics_repository.dart';
import '../domain/monthly_statistics.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({
    required this.repository,
    required this.selectedMonth,
    required this.onMonthChanged,
    super.key,
  });

  final StatisticsRepository repository;
  final YearMonth selectedMonth;
  final ValueChanged<YearMonth> onMonthChanged;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Stream<MonthlyStatistics> _statistics;

  @override
  void initState() {
    super.initState();
    _statistics = widget.repository.watchMonth(widget.selectedMonth);
  }

  @override
  void didUpdateWidget(covariant StatisticsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.selectedMonth != widget.selectedMonth) {
      _statistics = widget.repository.watchMonth(widget.selectedMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MonthNavigator(
          selectedMonth: widget.selectedMonth,
          onChanged: widget.onMonthChanged,
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<MonthlyStatistics>(
            stream: _statistics,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _StatisticsLoadError(onRetry: _retry);
              }
              final statistics = snapshot.data;
              if (statistics == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return _StatisticsList(statistics: statistics);
            },
          ),
        ),
      ],
    );
  }

  void _retry() {
    setState(() {
      _statistics = widget.repository.watchMonth(widget.selectedMonth);
    });
  }
}

class _StatisticsList extends StatelessWidget {
  const _StatisticsList({required this.statistics});

  final MonthlyStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return ListView(
      children: [
        _SummaryRow(
          label: l10n.income,
          amount: formatCnyCents(
            statistics.incomeCents,
            locale: locale,
            showPositiveSign: true,
          ),
        ),
        _SummaryRow(
          label: l10n.expense,
          amount: formatCnyCents(-statistics.expenseCents, locale: locale),
        ),
        _SummaryRow(
          label: l10n.balance,
          amount: formatCnyCents(
            statistics.balanceCents,
            locale: locale,
            showPositiveSign: true,
          ),
        ),
        const Divider(height: 1),
        if (!statistics.hasTransactions)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.noTransactionsThisMonth,
              textAlign: TextAlign.center,
            ),
          )
        else ...[
          if (statistics.incomeCategories.isNotEmpty)
            _StatisticsSection(
              key: const Key('statistics-income-section'),
              title: l10n.income,
              entryType: EntryType.income,
              totalCents: statistics.incomeCents,
              categories: statistics.incomeCategories,
            ),
          if (statistics.expenseCategories.isNotEmpty)
            _StatisticsSection(
              key: const Key('statistics-expense-section'),
              title: l10n.expense,
              entryType: EntryType.expense,
              totalCents: statistics.expenseCents,
              categories: statistics.expenseCategories,
            ),
        ],
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      dense: true,
      title: Text(
        l10n.labeledAmount(label, amount),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _StatisticsSection extends StatelessWidget {
  const _StatisticsSection({
    required this.title,
    required this.entryType,
    required this.totalCents,
    required this.categories,
    super.key,
  });

  final String title;
  final EntryType entryType;
  final int totalCents;
  final List<CategoryStatistics> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        for (final category in categories) ...[
          _AmountRow(
            key: ValueKey('statistics-category-${category.id}'),
            name: category.name,
            amountCents: category.amountCents,
            totalCents: totalCents,
            entryType: entryType,
          ),
          if (category.hasMixedAssignments)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _AmountRow(
                key: ValueKey('statistics-no-subcategory-${category.id}'),
                name: AppLocalizations.of(context)!.noSubcategory,
                amountCents: category.directAmountCents,
                totalCents: totalCents,
                entryType: entryType,
              ),
            ),
          for (final subcategory in category.subcategories)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _AmountRow(
                key: ValueKey('statistics-subcategory-${subcategory.id}'),
                name: subcategory.name,
                amountCents: subcategory.amountCents,
                totalCents: totalCents,
                entryType: entryType,
              ),
            ),
        ],
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.name,
    required this.amountCents,
    required this.totalCents,
    required this.entryType,
    super.key,
  });

  final String name;
  final int amountCents;
  final int totalCents;
  final EntryType entryType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final directedAmount = entryType == EntryType.income
        ? amountCents
        : -amountCents;
    final amount = formatCnyCents(
      directedAmount,
      locale: locale,
      showPositiveSign: true,
    );
    final percentage = formatPercentage(
      partCents: amountCents,
      totalCents: totalCents,
    )!;
    return ListTile(
      dense: true,
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(l10n.amountAndPercentage(amount, percentage)),
    );
  }
}

class _StatisticsLoadError extends StatelessWidget {
  const _StatisticsLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.statisticsLoadFailed, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
