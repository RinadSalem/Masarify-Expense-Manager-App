

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/expense_model.dart';

class DatabaseService {
  
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

 
  static const String _dbName = 'expense_manager.db';
  static const int _dbVersion = 1;

  static const String tableUsers = 'users';
  static const String tableExpenses = 'expenses';

  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  
  Future<Database> _initDatabase() async {
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
    );
  }

  
  Future<void> _createTables(Database db, int version) async {
    
    await db.execute('''
      CREATE TABLE $tableUsers (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT    NOT NULL,
        password TEXT    NOT NULL,
        email TEXT,   
        age INTEGER   
      )
    ''');

    
    await db.execute('''
      CREATE TABLE $tableExpenses (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id  INTEGER NOT NULL,
        title    TEXT    NOT NULL,
        amount   REAL    NOT NULL,
        date     TEXT    NOT NULL,
        category TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $tableUsers(id) ON DELETE CASCADE
      )
    ''');
  }

 
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert(
      tableUsers,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }


  Future<UserModel?> loginUser(String name, String password) async {
    final db = await database;
    final results = await db.query(
      tableUsers,
      where: 'name = ? AND password = ?',
      whereArgs: [name, password],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

 
  Future<bool> userExists(String name) async {
    final db = await database;
    final results = await db.query(
      tableUsers,
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    return results.isNotEmpty;
  }

 
  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await database;
    return await db.insert(
      tableExpenses,
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  
  Future<List<ExpenseModel>> getExpensesByUser(int userId) async {
    final db = await database;
    final results = await db.query(
      tableExpenses,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
 
    return results.map((row) => ExpenseModel.fromMap(row)).toList();
  }

  
  Future<List<ExpenseModel>> getExpensesByCategory(
    int userId,
    String category,
  ) async {
    final db = await database;
    final results = await db.query(
      tableExpenses,
      where: 'user_id = ? AND category = ?',
      whereArgs: [userId, category],
      orderBy: 'date DESC',
    );
    return results.map((row) => ExpenseModel.fromMap(row)).toList();
  }

  
  Future<int> updateExpense(ExpenseModel expense) async {
    final db = await database;
    return await db.update(
      tableExpenses,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }


  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalExpenses(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $tableExpenses WHERE user_id = ?',
      [userId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }


  Future<Map<String, double>> getExpensesByCategories(int userId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM $tableExpenses
      WHERE user_id = ?
      GROUP BY category
      ORDER BY total DESC
    ''', [userId]);

    final map = <String, double>{};
    for (final row in results) {
      map[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return map;
  }

  Future<Map<String, double>> getMonthlyExpenses(int userId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT strftime('%Y-%m', date) as month, SUM(amount) as total
      FROM $tableExpenses
      WHERE user_id = ?
      GROUP BY month
      ORDER BY month ASC
      LIMIT 6
    ''', [userId]);

    final map = <String, double>{};
    for (final row in results) {
      map[row['month'] as String] = (row['total'] as num).toDouble();
    }
    return map;
  }

  

  Future<double> getCurrentMonthTotal(int userId) async {
    final db = await database;
    final now = DateTime.now();
    final monthStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM $tableExpenses
      WHERE user_id = ? AND strftime('%Y-%m', date) = ?
    ''', [userId, monthStr]);
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> ensureBudgetTable() async {
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS budgets (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id    INTEGER NOT NULL UNIQUE,
        amount     REAL    NOT NULL,
        month      TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $tableUsers(id)
      )
    ''');
  }

  Future<void> saveBudget(int userId, double amount, String month) async {
    await ensureBudgetTable();
    final db = await database;
    await db.insert(
      'budgets',
      {'user_id': userId, 'amount': amount, 'month': month},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<double?> getBudget(int userId) async {
    await ensureBudgetTable();
    final db = await database;
    final results = await db.query(
      'budgets',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return (results.first['amount'] as num).toDouble();
  }

 
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
