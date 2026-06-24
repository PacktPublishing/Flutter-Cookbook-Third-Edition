import 'package:testable_counter_app/counter_storage.dart';

class FakeCounterStorage implements CounterStorage {
  int stored = 0;

  @override
  Future<int> load() async => stored;

  @override
  Future<void> save(int value) async => stored = value;
}