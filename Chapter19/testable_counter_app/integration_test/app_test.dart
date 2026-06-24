import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:testable_counter_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('counts up and shows the result', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    // The device may still hold a value from a previous run, so start at zero.
    await tester.tap(find.byTooltip('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
    }

    expect(find.text('3'), findsOneWidget);
    expect(find.text('Odd'), findsOneWidget);
  });
}
