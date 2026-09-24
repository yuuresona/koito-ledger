import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/app/ledger_app.dart';

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
    expect(find.text('Transactions will appear here.'), findsOneWidget);

    await tester.tap(find.text('Statistics').last);
    await tester.pumpAndSettle();
    expect(find.text('Monthly statistics will appear here.'), findsOneWidget);
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
    expect(find.text('Monthly statistics will appear here.'), findsOneWidget);
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
}
