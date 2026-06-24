import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:testable_counter_app/counter_storage.dart';

void main() {
  group('FileCounterStorage', () {
    late Directory tempDir;
    late FileCounterStorage storage;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('counter_test');
      storage = FileCounterStorage(File('${tempDir.path}/counter.json'));
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('load returns 0 when the file does not exist', () {
      expect(storage.load(), completion(0));
    });

    test('save writes the value and load reads it back', () async {
      await storage.save(7);
      expect(await storage.load(), 7);
    });
  });
}
