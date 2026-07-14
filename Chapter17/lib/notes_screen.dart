import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<String> notes = [
    'Buy some fruit',
    'Call Bob',
    'Create a Flutter app',
    'Remember to drink water',
    'Go to the gym',
  ];

  String message = 'Press Ctrl+N or Cmd+N to add a new note.';

  int getColumns(double width) {
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  void addNote() {
    setState(() {
      notes.add('New note ${notes.length + 1}');
      message = 'New note added.';
    });
  }

  Map<ShortcutActivator, VoidCallback> getShortcuts() {
    return {
      const SingleActivator(LogicalKeyboardKey.keyN, control: true): addNote,
      const SingleActivator(LogicalKeyboardKey.keyN, meta: true): addNote,
    };
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: getShortcuts(),
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(title: const Text('Platform Inputs')),
          floatingActionButton: FloatingActionButton(
            onPressed: addNote,
            child: const Icon(Icons.add),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(message),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, BoxConstraints constraints) {
                      final columns = getColumns(constraints.maxWidth);
                      return GridView.builder(
                        itemCount: notes.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.6,
                        ),
                        itemBuilder: (context, index) {
                          return NoteCard(text: notes[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoteCard extends StatefulWidget {
  const NoteCard({super.key, required this.text});

  final String text;

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovering = false;
        });
      },
      child: Card(
        elevation: isHovering ? 8 : 2,
        child: ListTile(
          title: Text(widget.text),
          subtitle: Text(
            isHovering ? 'Pointer is over this card' : 'Move the pointer here',
          ),
        ),
      ),
    );
  }
}
