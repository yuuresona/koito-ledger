import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/time/year_month.dart';
import '../../../l10n/app_localizations.dart';

class MonthNavigator extends StatelessWidget {
  const MonthNavigator({
    required this.selectedMonth,
    required this.onChanged,
    this.now,
    super.key,
  });

  final YearMonth selectedMonth;
  final ValueChanged<YearMonth> onChanged;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = YearMonth.current(now);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key('previous-month'),
          tooltip: l10n.previousMonth,
          onPressed: () => onChanged(selectedMonth.previous),
          icon: const Icon(Icons.chevron_left),
        ),
        TextButton(
          key: const Key('select-month'),
          onPressed: () => _selectMonth(context, current),
          child: Text(
            DateFormat.yMMMM(locale)
                .format(DateTime(selectedMonth.year, selectedMonth.month)),
          ),
        ),
        IconButton(
          key: const Key('next-month'),
          tooltip: l10n.nextMonth,
          onPressed: selectedMonth == current
              ? null
              : () => onChanged(selectedMonth.next),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Future<void> _selectMonth(BuildContext context, YearMonth current) async {
    final result = await showDialog<YearMonth>(
      context: context,
      builder: (context) => _MonthPickerDialog(
        initialMonth: selectedMonth,
        currentMonth: current,
      ),
    );
    if (result != null) onChanged(result);
  }
}

class _MonthPickerDialog extends StatefulWidget {
  const _MonthPickerDialog({
    required this.initialMonth,
    required this.currentMonth,
  });

  final YearMonth initialMonth;
  final YearMonth currentMonth;

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.initialMonth.year;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return AlertDialog(
      title: Text(l10n.selectMonth),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => setState(() => _year -= 1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('$_year', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  onPressed: _year >= widget.currentMonth.year
                      ? null
                      : () => setState(() => _year += 1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: [
                for (var month = 1; month <= 12; month++)
                  _monthButton(context, locale, month),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  Widget _monthButton(BuildContext context, String locale, int month) {
    final value = YearMonth(_year, month);
    final isFuture = value.isAfter(widget.currentMonth);
    final isSelected = value == widget.initialMonth;
    return isSelected
        ? FilledButton(
            onPressed: isFuture ? null : () => Navigator.pop(context, value),
            child: Text(DateFormat.MMM(locale).format(DateTime(_year, month))),
          )
        : TextButton(
            onPressed: isFuture ? null : () => Navigator.pop(context, value),
            child: Text(DateFormat.MMM(locale).format(DateTime(_year, month))),
          );
  }
}
