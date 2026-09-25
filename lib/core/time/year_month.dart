import 'dart:math' as math;

class YearMonth {
  const YearMonth(this.year, this.month)
    : assert(month >= DateTime.january && month <= DateTime.december);

  factory YearMonth.fromDate(DateTime date) => YearMonth(date.year, date.month);

  factory YearMonth.current([DateTime? now]) =>
      YearMonth.fromDate(now ?? DateTime.now());

  final int year;
  final int month;

  YearMonth get previous => month == DateTime.january
      ? YearMonth(year - 1, DateTime.december)
      : YearMonth(year, month - 1);

  YearMonth get next => month == DateTime.december
      ? YearMonth(year + 1, DateTime.january)
      : YearMonth(year, month + 1);

  int get startEpochDay => calendarDateToEpochDay(DateTime(year, month));

  int get endEpochDayExclusive => calendarDateToEpochDay(
    month == DateTime.december
        ? DateTime(year + 1, DateTime.january)
        : DateTime(year, month + 1),
  );

  bool isAfter(YearMonth other) =>
      year > other.year || (year == other.year && month > other.month);

  DateTime defaultTransactionDate(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    if (this == YearMonth.fromDate(today)) return today;
    final finalDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, math.min(today.day, finalDay));
  }

  @override
  bool operator ==(Object other) =>
      other is YearMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}';
}

int calendarDateToEpochDay(DateTime date) {
  return DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
}

DateTime epochDayToCalendarDate(int epochDay) {
  final utc = DateTime.fromMillisecondsSinceEpoch(
    epochDay * Duration.millisecondsPerDay,
    isUtc: true,
  );
  return DateTime(utc.year, utc.month, utc.day);
}
