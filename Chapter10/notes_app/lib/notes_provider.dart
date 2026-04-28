import 'package:flutter/foundation.dart';

class NotesProvider extends ChangeNotifier {
  final List<String> _notes = [];

  List<String> get notes => List.unmodifiable(_notes);

  int get noteCount => _notes.length;

  void addNote(String note) {
    if (note.trim().isEmpty) return;
    _notes.add(note.trim());
    notifyListeners();
  }

  void removeNote(int index) {
    _notes.removeAt(index);
    notifyListeners();
  }
}