// lib/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  factory DatabaseHelper() => instance;
  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'simuni_ledger.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        referenceNumber TEXT UNIQUE,
        amount REAL,
        depositorName TEXT,
        transactionDate TEXT
      )
    ''');
  }

  Future<int> insertTransaction(TransactionModel tx) async {
    Database db = await instance.database;
    return await db.insert(
      'transactions',
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<TransactionModel>> fetchTransactions() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'transactionDate DESC');
    
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }
}