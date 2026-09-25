import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/money/cny_formatter.dart';

void main() {
  test('formats zero and explicit positive and negative signs', () {
    expect(formatCnyCents(0, locale: 'en'), '¥0.00');
    expect(
      formatCnyCents(1234, locale: 'en', showPositiveSign: true),
      '+¥12.34',
    );
    expect(formatCnyCents(-1234, locale: 'en'), '−¥12.34');
  });

  test('formats large integer-cent totals without floating point', () {
    expect(
      formatCnyCents(900719925474099300, locale: 'en', showPositiveSign: true),
      '+¥9,007,199,254,740,993.00',
    );
  });
}
