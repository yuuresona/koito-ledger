import 'package:intl/intl.dart';

String formatCnyCents(
  int amountCents, {
  required String locale,
  bool showPositiveSign = false,
}) {
  final magnitude = amountCents.abs();
  final whole = magnitude ~/ 100;
  final fraction = magnitude.remainder(100).toString().padLeft(2, '0');
  final prefix = amountCents < 0
      ? '−'
      : amountCents > 0 && showPositiveSign
      ? '+'
      : '';
  return '$prefix¥${NumberFormat.decimalPattern(locale).format(whole)}.$fraction';
}
