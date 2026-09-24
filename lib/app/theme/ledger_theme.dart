import 'package:flutter/material.dart';

abstract final class LedgerTheme {
  static ThemeData light(ColorScheme? dynamicScheme) => ThemeData(
    useMaterial3: true,
    colorScheme:
        dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
  );

  static ThemeData dark(ColorScheme? dynamicScheme) => ThemeData(
    useMaterial3: true,
    colorScheme:
        dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
  );
}
