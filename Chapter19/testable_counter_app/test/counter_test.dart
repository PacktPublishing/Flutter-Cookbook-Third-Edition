import 'package:flutter_test/flutter_test.dart';
import 'package:testable_counter_app/counter.dart';

void main() {
  group('Counter', () {
    late Counter counter;

    setUp(() {
      counter = Counter();
    });

    test('starts at zero', () {
      expect(counter.value, isZero);
    });

    test('increment increases the value by one', () {
      counter.increment();
      expect(counter.value, equals(1));
    });

    test('decrement decreases the value by one', () {
      counter = Counter(5);
      counter.decrement();
      expect(counter.value, 4);
    });

    test('reset returns the value to zero', () {
      counter = Counter(9);
      counter.reset();
      expect(counter.value, isZero);
    });

    group('isEven', () {
      test('is true for an even value', () {
        expect(Counter(4).isEven, isTrue);
      });

      test('is false for an odd value', () {
        expect(Counter(3).isEven, isFalse);
      });
    });

    test('decrement at zero throws a StateError', () {
      expect(() => counter.decrement(), throwsStateError);
    });

    test('a failed decrement leaves the value unchanged', () {
      expect(() => counter.decrement(), throwsStateError);
      expect(counter.value, isZero);
    });
  });
}
