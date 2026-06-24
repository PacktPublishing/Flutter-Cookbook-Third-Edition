class Counter {
  int _value;

  Counter([this._value = 0]);

  int get value => _value;

  bool get isEven => _value % 2 == 0;

  void increment() => _value++;

  void decrement() {
    if (_value == 0) {
      throw StateError('Counter cannot go below zero');
    }
    _value--;
  }

  void reset() => _value = 0;
}
