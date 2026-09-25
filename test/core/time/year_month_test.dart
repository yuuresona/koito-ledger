import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/time/year_month.dart';

void main() {
  test('past-month default clamps the current day to the final day', () {
    expect(
      const YearMonth(2024, 2).defaultTransactionDate(DateTime(2024, 9, 30)),
      DateTime(2024, 2, 29),
    );
    expect(
      const YearMonth(2023, 2).defaultTransactionDate(DateTime(2024, 9, 30)),
      DateTime(2023, 2, 28),
    );
  });

  test('current-month default uses today', () {
    expect(
      const YearMonth(2026, 9).defaultTransactionDate(DateTime(2026, 9, 24)),
      DateTime(2026, 9, 24),
    );
  });

  test('epoch-day conversion preserves calendar dates across the epoch', () {
    for (final date in [DateTime(1960, 2, 29), DateTime(2026, 9, 24)]) {
      expect(epochDayToCalendarDate(calendarDateToEpochDay(date)), date);
    }
  });
}
