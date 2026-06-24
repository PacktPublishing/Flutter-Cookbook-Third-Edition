import 'counter.dart';
import 'counter_storage.dart';

class CounterController {
  CounterController(this._storage);

  final CounterStorage _storage;
  Counter _counter = Counter();

  int get value => _counter.value;
  bool get isEven => _counter.isEven;

  Future<void> load() async {
    _counter = Counter(await _storage.load());
  }

  Future<void> increment() async {
    _counter.increment();
    await _storage.save(_counter.value);
  }

  Future<void> decrement() async {
    _counter.decrement();
    await _storage.save(_counter.value);
  }

  Future<void> reset() async {
    _counter.reset();
    await _storage.save(_counter.value);
  }
}
