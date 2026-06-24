import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testable_counter_app/counter_screen.dart';

import 'fake_counter_storage.dart';

void main() {
  testWidgets('counter screen matches its golden file', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CounterScreen(storage: FakeCounterStorage())),
    );
    await tester.pump(); // let the async load finish

    await expectLater(
      find.byType(CounterScreen),
      matchesGoldenFile('goldens/counter_initial.png'),
    );
  }, tags: 'golden');
}
