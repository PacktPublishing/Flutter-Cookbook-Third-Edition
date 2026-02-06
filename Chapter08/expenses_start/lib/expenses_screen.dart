import 'package:flutter/material.dart';
import 'expense.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {

  List<Expense> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _items = [];
    setState(() => _loading = false);
  }

  Future<void> _openEditor({Expense? existing}) async {
    final res = await showDialog<_EditorResult>(
      context: context,
      builder: (_) => _ExpenseDialog(existing: existing),
    );
    if (res == null) return;

    if (existing == null) {
    }

    await _load();
  }

  Future<void> _deleteExpense(Expense e) async {
    // Remove from the UI 
    setState(() {
      _items = _items.where((x) => x.id != e.id).toList();
    });

    
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text('Tap + to add an expense'))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final e = _items[i];

                return Dismissible(
                  key: ValueKey(e.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete),
                  ),
                  onDismissed: (_) => _deleteExpense(e),
                  child: ListTile(
                    title: Text(e.title),
                    subtitle: Text(dateFormatter.format(e.createdAt)),
                    trailing: Text('€ ${e.amount.toStringAsFixed(2)}'),
                    onTap: () => _openEditor(existing: e),
                  ),
                );
              },
            ),
    );
  }
}

class _EditorResult {
  final String title;
  final double amount;
  const _EditorResult(this.title, this.amount);
}

class _ExpenseDialog extends StatefulWidget {
  final Expense? existing;
  const _ExpenseDialog({this.existing});

  @override
  State<_ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<_ExpenseDialog> {
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _amount = TextEditingController(
    text: widget.existing != null
        ? widget.existing!.amount.toStringAsFixed(2)
        : '',
  );

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  double _toAmount(String s) => double.tryParse(s.replaceAll(',', '.')) ?? 0;

  void _save() {
    Navigator.pop(context, _EditorResult(_title.text, _toAmount(_amount.text)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'New expense' : 'Edit expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _amount,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
