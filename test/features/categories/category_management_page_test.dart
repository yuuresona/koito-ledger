import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/app/ledger_app.dart';

import '../../helpers/test_database.dart';

void main() {
  testWidgets('creates and displays a category hierarchy', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(LedgerApp(database: database));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('manage-categories')));
    await tester.pumpAndSettle();
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('No expense categories yet.'), findsOneWidget);

    await _addCategory(tester, 'Food');
    expect(find.text('Food'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add subcategory'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Lunch');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    expect(find.text('Lunch'), findsOneWidget);
  });

  testWidgets('keeps a duplicate-name dialog open with a clear error', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(LedgerApp(database: database));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('manage-categories')));
    await tester.pumpAndSettle();

    await _addCategory(tester, 'Food');
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), ' food ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('A sibling category already uses this name.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}

Future<void> _addCategory(WidgetTester tester, String name) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), name);
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}
