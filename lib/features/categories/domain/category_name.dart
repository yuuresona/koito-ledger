import 'package:characters/characters.dart';

import 'category.dart';

class CategoryName {
  const CategoryName._({required this.value, required this.normalized});

  factory CategoryName.parse(String input) {
    final value = input.trim();
    if (value.isEmpty) {
      throw const CategoryException(CategoryProblem.emptyName);
    }
    if (value.characters.length > 30) {
      throw const CategoryException(CategoryProblem.nameTooLong);
    }

    return CategoryName._(
      value: value,
      normalized: _lowercaseEnglishLetters(value),
    );
  }

  final String value;
  final String normalized;
}

String _lowercaseEnglishLetters(String value) {
  return String.fromCharCodes(
    value.runes.map((rune) {
      if (rune >= 0x41 && rune <= 0x5a) {
        return rune + 0x20;
      }
      return rune;
    }),
  );
}
