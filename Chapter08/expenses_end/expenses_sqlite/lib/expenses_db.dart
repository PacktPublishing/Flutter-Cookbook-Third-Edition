import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'expense.dart';

class ExpensesDb {
  ExpensesDb._();
  static final instance = ExpensesDb._();

  static const _dbName = 'expenses.db';
  static const _table = 'expenses';

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), _dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<List<Expense>> getExpenses() async {
    final rows = await (await db).query(
      _table,
      orderBy: 'created_at DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<void> insert(Expense e) async {
    await (await db).insert(_table, e.toMap());
  }

  Future<void> update(Expense e) async {
    await (await db).update(
      _table,
      e.toMap(),
      where: 'id = ?',
      whereArgs: [e.id],
    );
  }

  Future<void> delete(int id) async {
    await (await db).delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}


