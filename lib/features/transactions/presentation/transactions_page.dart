import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/money/cny_formatter.dart';
import '../../../core/time/year_month.dart';
import '../../../l10n/app_localizations.dart';
import '../../categories/domain/category.dart';
import '../data/transaction_repository.dart';
import '../domain/ledger_transaction.dart';
import 'month_navigator.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({
    required this.repository,
    required this.selectedMonth,
    required this.onMonthChanged,
    required this.onEdit,
    super.key,
  });

  final TransactionRepository repository;
  final YearMonth selectedMonth;
  final ValueChanged<YearMonth> onMonthChanged;
  final ValueChanged<LedgerTransaction> onEdit;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
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
          child: StreamBuilder<List<LedgerTransaction>>(
            stream: widget.repository.watchMonth(widget.selectedMonth),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _LoadError(onRetry: () => setState(() {}));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final transactions = snapshot.data!;
              if (transactions.isEmpty) {
                return const _EmptyTransactions();
              }
              return _TransactionList(
                transactions: transactions,
                onEdit: widget.onEdit,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions, required this.onEdit});

  final List<LedgerTransaction> transactions;
  final ValueChanged<LedgerTransaction> onEdit;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    int? currentEpochDay;
    for (final transaction in transactions) {
      final epochDay = calendarDateToEpochDay(transaction.date);
      if (epochDay != currentEpochDay) {
        currentEpochDay = epochDay;
        children.add(_DateHeader(date: transaction.date));
      }
      children.add(
        _TransactionTile(
          transaction: transaction,
          onTap: () => onEdit(transaction),
        ),
      );
    }
    return ListView(children: children);
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        DateFormat.yMMMMEEEEd(locale).format(date),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.onTap});

  final LedgerTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final path = transaction.subcategoryName == null
        ? transaction.categoryName
        : l10n.categoryPath(
            transaction.categoryName,
            transaction.subcategoryName!,
          );
    final type = transaction.entryType == EntryType.income
        ? l10n.income
        : l10n.expense;
    final note = transaction.note;
    final subtitle = note == null || note.isEmpty
        ? type
        : l10n.transactionTypeAndNote(type, note);
    final directedAmount = transaction.entryType == EntryType.income
        ? transaction.amountCents
        : -transaction.amountCents;
    final currency = formatCnyCents(
      directedAmount,
      locale: Localizations.localeOf(context).toLanguageTag(),
      showPositiveSign: true,
    );
    return ListTile(
      key: ValueKey('transaction-${transaction.id}'),
      title: Text(path, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(currency, style: Theme.of(context).textTheme.titleSmall),
      onTap: onTap,
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 48),
            const SizedBox(height: 12),
            Text(l10n.noTransactionsThisMonth),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(l10n.retry),
      ),
    );
  }
}
