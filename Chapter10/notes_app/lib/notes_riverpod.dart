import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesRiverpod extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  int get noteCount => state.length;

  void addNote(String note) {
    if (note.trim().isEmpty) return;
    state = [...state, note.trim()];
  }

  void removeNote(int index) {
    final updatedNotes = [...state]..removeAt(index);
    state = updatedNotes;
  }
}

final notesRiverpod = NotifierProvider<NotesRiverpod, List<String>>(
  NotesRiverpod.new,
);