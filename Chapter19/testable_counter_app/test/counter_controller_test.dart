import 'package:flutter_test/flutter_test.dart';
import 'package:testable_counter_app/counter_controller.dart';

import 'fake_counter_storage.dart';

void main() {
  group('CounterController', () {
    test('load restores the saved value', () async {
      final storage = FakeCounterStorage()..stored = 5;
      final controller = CounterController(storage);

      await controller.load();

      expect(controller.value, 5);
    });

    test('increment saves the new value', () async {
      final storage = FakeCounterStorage();
      final controller = CounterController(storage);

      await controller.increment();

      expect(controller.value, 1);
      expect(storage.stored, 1);
    });
  });
}
