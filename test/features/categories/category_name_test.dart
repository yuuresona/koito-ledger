import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/features/categories/domain/category.dart';
import 'package:ledger/features/categories/domain/category_name.dart';

void main() {
  test('trims outer whitespace and folds English letter case', () {
    final name = CategoryName.parse('  Food 中A  ');

    expect(name.value, 'Food 中A');
    expect(name.normalized, 'food 中a');
  });

  test('counts user-perceived Unicode characters', () {
    final thirtyEmoji = List.filled(30, '😀').join();
    expect(CategoryName.parse(thirtyEmoji).value, thirtyEmoji);

    expect(
      () => CategoryName.parse('$thirtyEmoji😀'),
      throwsA(
        isA<CategoryException>().having(
          (error) => error.problem,
          'problem',
          CategoryProblem.nameTooLong,
        ),
      ),
    );
  });

  test('rejects names that are empty after trimming', () {
    expect(
      () => CategoryName.parse('   '),
      throwsA(
        isA<CategoryException>().having(
          (error) => error.problem,
          'problem',
          CategoryProblem.emptyName,
        ),
      ),
    );
  });
}
