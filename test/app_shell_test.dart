import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/app/ledger_app.dart';
import 'package:ledger/core/time/year_month.dart';
import 'package:intl/intl.dart';

import 'helpers/test_database.dart';

void main() {
  testWidgets('phone uses bottom navigation and switches destinations', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(LedgerApp(database: database));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('No transactions this month.'), findsOneWidget);

    await tester.tap(find.text('Statistics').last);
    await tester.pumpAndSettle();
    expect(find.text('Income ¥0.00'), findsOneWidget);
    expect(find.text('No transactions this month.'), findsOneWidget);
  });

  testWidgets('tablet uses navigation rail and switches destinations', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(LedgerApp(database: database));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.text('Statistics').last);
    await tester.pumpAndSettle();
    expect(find.text('Income ¥0.00'), findsOneWidget);
    expect(find.text('No transactions this month.'), findsOneWidget);
  });

  testWidgets('theme follows system brightness', (tester) async {
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;

    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(LedgerApp(database: database));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpWidget(LedgerApp(key: UniqueKey(), database: database));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );
  });

  testWidgets('transactions and statistics share the selected month', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(LedgerApp(database: database));
    await tester.pumpAndSettle();

    final previous = YearMonth.current().previous;
    final previousLabel = DateFormat.yMMMM('en')
        .format(DateTime(previous.year, previous.month));
    await tester.tap(find.byKey(const Key('previous-month')));
    await tester.pumpAndSettle();
    expect(find.text(previousLabel), findsOneWidget);

    await tester.tap(find.text('Statistics').last);
    await tester.pumpAndSettle();
    expect(find.text(previousLabel), findsOneWidget);
  });
}
