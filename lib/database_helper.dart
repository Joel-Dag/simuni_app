// lib/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('simuni_local_vault.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Core transactions table
    await db.execute('''
      CREATE TABLE transactions (
        reference_number TEXT PRIMARY KEY,
        depositor_name TEXT NOT NULL,
        amount REAL NOT NULL,
        transaction_date TEXT NOT NULL,
        raw_sms_body TEXT NOT NULL,
        is_matched_to_debt INTEGER DEFAULT 0
      )
    ''');

    // 2. Client Debt tracker table
    await db.execute('''
      CREATE TABLE debtors (
        id TEXT PRIMARY KEY,
        client_name TEXT NOT NULL UNIQUE,
        total_debt REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 3. Fixed expenses table (For computing the Safe-to-Spend limits)
    await db.execute('''
      CREATE TABLE fixed_expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        due_date TEXT NOT NULL,
        is_recurring INTEGER DEFAULT 1
      )
    ''');
  }

  // Inserts a parsed transaction; ignores completely if reference code already exists
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore, // Anti-duplicate guard
    );
  }

  // Fetches full transaction history sorted cleanly by date descending
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    const orderBy = 'transaction_date DESC';
    final result = await db.query('transactions', orderBy: orderBy);

    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  // Aggregate function to fetch total income over the past 30 days (for Cash Runway checks)
  Future<double> getThirtyDayVelocity() async {
    final db = await instance.database;
    final DateTime thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE transaction_date >= ?
    ''', [thirtyDaysAgo.toIso8601String()]);

    if (result.first['total'] == null) return 0.0;
    return (result.first['total'] as num).toDouble();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}