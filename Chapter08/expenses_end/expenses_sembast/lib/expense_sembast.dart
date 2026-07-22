import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'expense.dart';

class ExpenseSembast {
  static const String expensesStore = 'expenses';

  final StoreRef<int, Map<String, Object?>> _store =
      intMapStoreFactory.store(expensesStore);

  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;

    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, 'expenses.db');

    _database = await databaseFactoryIo.openDatabase(dbPath);
    return _database!;
  }

  Future<int> addExpense(Expense expense) async {
    final db = await _db;
    return _store.add(db, expense.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    final db = await _db;

    final snapshots = await _store.find(
      db,
      finder: Finder(
        sortOrders: [
          SortOrder('createdAt'),
        ],
      ),
    );

    return snapshots.map((snapshot) {
      return Expense.fromMap(
        snapshot.value,
        key: snapshot.key,
      );
    }).toList();
  }

  Future<void> deleteExpense(int key) async {
    final db = await _db;
    await _store.record(key).delete(db);
  }

  Future<void> updateExpense(int key, Expense expense) async {
    final db = await _db;
    await _store.record(key).put(db, expense.toMap());
  }
}