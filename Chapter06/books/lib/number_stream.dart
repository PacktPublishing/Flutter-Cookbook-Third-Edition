import 'dart:async';

class NumberStream {
  final controller = StreamController<int>();

  void addNumberToSink(int newNumber) {
    controller.sink.add(newNumber);
  }

  addError() {
    controller.sink.addError('error');
  }

  close() {
    controller.close();
  }
}
