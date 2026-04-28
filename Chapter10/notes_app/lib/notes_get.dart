import 'package:get/get.dart';

class NotesController extends GetxService {
  
  final RxList<String> notes = <String>[].obs;

  int get noteCount => notes.length;

  void addNote(String note) {
    if (note.trim().isEmpty) return;
    notes.add(note.trim());
  }

  void removeNote(int index) {
    notes.removeAt(index);
  }
}