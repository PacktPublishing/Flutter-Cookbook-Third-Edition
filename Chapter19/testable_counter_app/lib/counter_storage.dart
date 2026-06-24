import 'dart:convert';
import 'dart:io';

abstract class CounterStorage {
  Future<int> load();
  Future<void> save(int value);
}

class FileCounterStorage implements CounterStorage {
  FileCounterStorage(this.file);

  final File file;

  @override
  Future<int> load() async {
    if (!await file.exists()) {
      return 0;
    }
    final contents = await file.readAsString();
    final data = jsonDecode(contents) as Map<String, dynamic>;
    return data['value'] as int;
  }

  @override
  Future<void> save(int value) async {
    await file.writeAsString(jsonEncode({'value': value}));
  }
}
