import 'dart:math';

import 'package:characters/characters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/time/year_month.dart';
import 'package:ledger/features/categories/domain/category.dart';
import 'package:ledger/features/categories/domain/category_name.dart';
import 'package:ledger/features/statistics/domain/monthly_statistics.dart';
import 'package:ledger/features/transactions/domain/ledger_transaction.dart';

const _amountSeed = 0x4C454447;
const _categorySeed = 0x43415445;
const _statisticsSeed = 0x53544154;
const _percentageSeed = 0x50435447;
const _calendarSeed = 0x44415445;

void main() {
  test('50,000 randomized valid amounts round-trip exactly', () {
    final random = Random(_amountSeed);
    for (var iteration = 0; iteration < 50000; iteration++) {
      var whole = random.nextInt(1000000000);
      var fraction = random.nextInt(100);
      if (whole == 0 && fraction == 0) fraction = 1;
      final expected = whole * 100 + fraction;
      final leadingZeros = List.filled(random.nextInt(5), '0').join();
      final String input;
      if (fraction == 0 && random.nextBool()) {
        input = '$leadingZeros$whole';
      } else if (fraction % 10 == 0 && random.nextBool()) {
        input = '$leadingZeros$whole.${fraction ~/ 10}';
      } else {
        input = '$leadingZeros$whole.${fraction.toString().padLeft(2, '0')}';
      }

      final actual = parseAmountCents(input);
      if (actual != expected) {
        fail(
          'amount seed=$_amountSeed iteration=$iteration '
          'input=$input expected=$expected actual=$actual',
        );
      }
    }
  });

  test('30,000 randomized malformed or out-of-range amounts are rejected', () {
    final random = Random(_amountSeed ^ 0xBAD);
    for (var iteration = 0; iteration < 30000; iteration++) {
      final whole = random.nextInt(1000000000);
      final fraction = random.nextInt(100).toString().padLeft(2, '0');
      final valid = '$whole.$fraction';
      final input = switch (random.nextInt(16)) {
        0 => '',
        1 => '0',
        2 => '0.00',
        3 => '-$valid',
        4 => '+$valid',
        5 => '${valid}e${random.nextInt(10)}',
        6 => '.',
        7 => '$whole.${random.nextInt(1000).toString().padLeft(3, '0')}',
        8 => '$whole.',
        9 => ' $valid',
        10 => '$valid ',
        11 => '$whole..$fraction',
        12 => '${_randomToken(random)}$valid',
        13 => '1000000000.$fraction',
        14 => '１２.３４',
        _ => List.filled(100 + random.nextInt(901), '9').join(),
      };

      try {
        final parsed = parseAmountCents(input);
        fail(
          'amount seed=${_amountSeed ^ 0xBAD} iteration=$iteration '
          'unexpectedly parsed "$input" as $parsed',
        );
      } on TransactionException {
        // Expected rejection.
      }
    }
  });

  test('20,000 randomized Unicode category names trim and normalize', () {
    final random = Random(_categorySeed);
    for (var iteration = 0; iteration < 20000; iteration++) {
      final length = 1 + random.nextInt(30);
      final rawName = List.generate(length, (_) => _randomToken(random)).join();
      final leadingSpaces = List.filled(random.nextInt(4), ' ').join();
      final trailingSpaces = List.filled(random.nextInt(4), ' ').join();
      final input = '$leadingSpaces$rawName$trailingSpaces';
      final parsed = CategoryName.parse(input);
      final normalized = String.fromCharCodes(
        rawName.runes.map(
          (rune) => rune >= 0x41 && rune <= 0x5a ? rune + 0x20 : rune,
        ),
      );

      if (parsed.value != rawName || parsed.normalized != normalized) {
        fail(
          'category seed=$_categorySeed iteration=$iteration '
          'input="$input" value="${parsed.value}" '
          'normalized="${parsed.normalized}"',
        );
      }
      if (parsed.value.characters.length != length) {
        fail(
          'category seed=$_categorySeed iteration=$iteration '
          'expected $length graphemes, got '
          '${parsed.value.characters.length}',
        );
      }
    }
  });

  test(
    'calendar epoch-day conversion is exhaustive from 1900 through 2100',
    () {
      var checkedDates = 0;
      for (var year = 1900; year <= 2100; year++) {
        for (var month = 1; month <= 12; month++) {
          final daysInMonth = DateTime(year, month + 1, 0).day;
          final value = YearMonth(year, month);
          expect(
            value.endEpochDayExclusive - value.startEpochDay,
            daysInMonth,
            reason: 'year=$year month=$month',
          );
          for (var day = 1; day <= daysInMonth; day++) {
            final date = DateTime(year, month, day);
            final roundTrip = epochDayToCalendarDate(
              calendarDateToEpochDay(date),
            );
            if (roundTrip != date) {
              fail('calendar date=$date roundTrip=$roundTrip');
            }
            checkedDates++;
          }
        }
      }
      expect(checkedDates, 73414);
    },
  );

  test('50,000 randomized month defaults stay inside the selected month', () {
    final random = Random(_calendarSeed);
    for (var iteration = 0; iteration < 50000; iteration++) {
      final now = DateTime(
        1970 + random.nextInt(131),
        1 + random.nextInt(12),
        1 + random.nextInt(28),
        random.nextInt(24),
        random.nextInt(60),
      );
      final selected = YearMonth(
        1900 + random.nextInt(now.year - 1899),
        1 + random.nextInt(12),
      );
      final result = selected.defaultTransactionDate(now);
      final expectedDay = min(
        now.day,
        DateTime(selected.year, selected.month + 1, 0).day,
      );
      if (result.year != selected.year ||
          result.month != selected.month ||
          result.day != expectedDay) {
        fail(
          'calendar seed=$_calendarSeed iteration=$iteration '
          'now=$now selected=$selected result=$result',
        );
      }
    }
  });

  test(
    '1,000 randomized statistics datasets satisfy aggregation invariants',
    () {
      final random = Random(_statisticsSeed);
      for (var scenario = 0; scenario < 1000; scenario++) {
        final transactions = <LedgerTransaction>[];
        final expected = <EntryType, Map<int, _ExpectedCategory>>{
          EntryType.income: {},
          EntryType.expense: {},
        };
        final count = random.nextInt(401);
        for (var index = 0; index < count; index++) {
          final type = random.nextBool() ? EntryType.income : EntryType.expense;
          final categoryIndex = random.nextInt(8);
          final categoryId =
              (type == EntryType.income ? 1000 : 100) + categoryIndex * 10;
          final categoryName = '${type.name}-$categoryIndex';
          final hasSubcategory = random.nextInt(10) < 7;
          final subcategoryIndex = hasSubcategory
              ? 1 + random.nextInt(4)
              : null;
          final subcategoryId = subcategoryIndex == null
              ? null
              : categoryId + subcategoryIndex;
          final amount = 1 + random.nextInt(1000000000);
          transactions.add(
            _transaction(
              id: index + 1,
              amountCents: amount,
              entryType: type,
              categoryId: categoryId,
              categoryName: categoryName,
              subcategoryId: subcategoryId,
              subcategoryName: subcategoryIndex == null
                  ? null
                  : 'subcategory-$subcategoryIndex',
            ),
          );
          final category = expected[type]!.putIfAbsent(
            categoryId,
            () => _ExpectedCategory(categoryName),
          );
          category.total += amount;
          if (subcategoryId == null) {
            category.direct += amount;
          } else {
            category.subcategories.update(
              subcategoryId,
              (current) => current + amount,
              ifAbsent: () => amount,
            );
          }
        }

        final statistics = MonthlyStatistics.fromTransactions(transactions);
        _verifyStatistics(statistics, expected, scenario);

        final shuffled = [...transactions]..shuffle(random);
        final shuffledStatistics = MonthlyStatistics.fromTransactions(shuffled);
        if (_statisticsSnapshot(statistics) !=
            _statisticsSnapshot(shuffledStatistics)) {
          fail(
            'statistics seed=$_statisticsSeed scenario=$scenario '
            'changed after input permutation',
          );
        }
      }
    },
  );

  test('50,000 randomized percentage values match a rational oracle', () {
    final random = Random(_percentageSeed);
    for (var iteration = 0; iteration < 50000; iteration++) {
      final total =
          1 +
          random.nextInt(900000000) * 1000000000 +
          random.nextInt(1000000000);
      final ratio = random.nextInt(1000000001);
      final part =
          (BigInt.from(total) * BigInt.from(ratio) ~/ BigInt.from(1000000000))
              .toInt();
      final expected = _percentageOracle(part, total);
      final actual = formatPercentage(partCents: part, totalCents: total);
      if (actual != expected) {
        fail(
          'percentage seed=$_percentageSeed iteration=$iteration '
          'part=$part total=$total expected=$expected actual=$actual',
        );
      }
    }
  });
}

String _randomToken(Random random) {
  const tokens = [
    'A',
    'Z',
    'a',
    'z',
    '账',
    '餐',
    'é',
    'ß',
    '🙂',
    '👨‍👩‍👧‍👦',
    'e\u0301',
  ];
  return tokens[random.nextInt(tokens.length)];
}

LedgerTransaction _transaction({
  required int id,
  required int amountCents,
  required EntryType entryType,
  required int categoryId,
  required String categoryName,
  required int? subcategoryId,
  required String? subcategoryName,
}) {
  return LedgerTransaction(
    id: id,
    amountCents: amountCents,
    date: DateTime(2026, 9, 24),
    entryType: entryType,
    categoryId: categoryId,
    categoryName: categoryName,
    subcategoryId: subcategoryId,
    subcategoryName: subcategoryName,
    note: null,
    createdAt: DateTime.utc(2026, 9, 24),
    updatedAt: DateTime.utc(2026, 9, 24),
  );
}

void _verifyStatistics(
  MonthlyStatistics actual,
  Map<EntryType, Map<int, _ExpectedCategory>> expected,
  int scenario,
) {
  final expectedIncome = expected[EntryType.income]!.values.fold<int>(
    0,
    (sum, category) => sum + category.total,
  );
  final expectedExpense = expected[EntryType.expense]!.values.fold<int>(
    0,
    (sum, category) => sum + category.total,
  );
  if (actual.incomeCents != expectedIncome ||
      actual.expenseCents != expectedExpense ||
      actual.balanceCents != expectedIncome - expectedExpense) {
    fail('statistics seed=$_statisticsSeed scenario=$scenario totals mismatch');
  }
  _verifySide(actual.incomeCategories, expected[EntryType.income]!, scenario);
  _verifySide(actual.expenseCategories, expected[EntryType.expense]!, scenario);
}

void _verifySide(
  List<CategoryStatistics> actual,
  Map<int, _ExpectedCategory> expected,
  int scenario,
) {
  final expectedIds = expected.keys.toList()..sort();
  final actualIds = actual.map((category) => category.id).toList();
  if (!_listEquals(actualIds, expectedIds)) {
    fail(
      'statistics seed=$_statisticsSeed scenario=$scenario '
      'category ids expected=$expectedIds actual=$actualIds',
    );
  }
  for (final category in actual) {
    final expectedCategory = expected[category.id]!;
    if (category.name != expectedCategory.name ||
        category.amountCents != expectedCategory.total ||
        category.directAmountCents != expectedCategory.direct ||
        category.amountCents !=
            category.directAmountCents +
                category.subcategories.fold<int>(
                  0,
                  (sum, subcategory) => sum + subcategory.amountCents,
                ) ||
        category.hasMixedAssignments !=
            (expectedCategory.direct > 0 &&
                expectedCategory.subcategories.isNotEmpty)) {
      fail(
        'statistics seed=$_statisticsSeed scenario=$scenario '
        'category=${category.id} invariant mismatch',
      );
    }
    final expectedSubcategoryIds = expectedCategory.subcategories.keys.toList()
      ..sort();
    final actualSubcategoryIds = category.subcategories
        .map((subcategory) => subcategory.id)
        .toList();
    if (!_listEquals(actualSubcategoryIds, expectedSubcategoryIds)) {
      fail(
        'statistics seed=$_statisticsSeed scenario=$scenario '
        'category=${category.id} subcategory order mismatch',
      );
    }
    for (final subcategory in category.subcategories) {
      if (subcategory.amountCents !=
          expectedCategory.subcategories[subcategory.id]) {
        fail(
          'statistics seed=$_statisticsSeed scenario=$scenario '
          'subcategory=${subcategory.id} amount mismatch',
        );
      }
    }
  }
}

String _statisticsSnapshot(MonthlyStatistics statistics) {
  String side(List<CategoryStatistics> categories) => categories
      .map(
        (category) =>
            '${category.id}:${category.name}:${category.amountCents}:'
            '${category.directAmountCents}:'
            '${category.subcategories.map((subcategory) => '${subcategory.id}:${subcategory.amountCents}').join(',')}',
      )
      .join('|');
  return '${statistics.incomeCents}/${statistics.expenseCents}/'
      '${side(statistics.incomeCategories)}/${side(statistics.expenseCategories)}';
}

String _percentageOracle(int part, int total) {
  final scaled = BigInt.from(part) * BigInt.from(10000);
  final totalBig = BigInt.from(total);
  if (part > 0 && scaled < totalBig) return '<0.01%';
  final hundredths =
      ((scaled * BigInt.two + totalBig) ~/ (totalBig * BigInt.two)).toInt();
  return '${hundredths ~/ 100}.'
      '${hundredths.remainder(100).toString().padLeft(2, '0')}%';
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

class _ExpectedCategory {
  _ExpectedCategory(this.name);

  final String name;
  int total = 0;
  int direct = 0;
  final Map<int, int> subcategories = {};
}
