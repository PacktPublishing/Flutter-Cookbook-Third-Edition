import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:testable_counter_app/counter_controller.dart';
import 'package:testable_counter_app/counter_storage.dart';

import 'counter_controller_mockito_test.mocks.dart';

@GenerateMocks([CounterStorage])
void main() {
  test('increment saves the incremented value', () async {
    final storage = MockCounterStorage();
    when(storage.save(any)).thenAnswer((_) async {});

    final controller = CounterController(storage);
    await controller.increment();

    verify(storage.save(1)).called(1);
  });
}
