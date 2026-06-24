import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testable_counter_app/counter_screen.dart';
import 'package:testable_counter_app/counter_storage.dart';

import 'fake_counter_storage.dart';

Future<void> pumpCounterScreen(
  WidgetTester tester,
  CounterStorage storage,
) async {
  await tester.pumpWidget(MaterialApp(home: CounterScreen(storage: storage)));
  await tester.pump(); // let the async load() finish, then rebuild
}

void main() {
  testWidgets('shows the saved value on launch', (tester) async {
    await pumpCounterScreen(tester, FakeCounterStorage()..stored = 5);

    expect(find.text('5'), findsOneWidget);
    expect(find.text('Odd'), findsOneWidget);
  });

  testWidgets('increments the value when + is tapped', (tester) async {
    await pumpCounterScreen(tester, FakeCounterStorage());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('Even'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('Odd'), findsOneWidget);
  });

  testWidgets('shows a SnackBar when decrementing below zero', (tester) async {
    await pumpCounterScreen(tester, FakeCounterStorage());

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(find.text("Counter can't go below zero"), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });
}
