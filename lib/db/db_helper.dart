import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'model/stock.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const int _databaseVersion = 6; // Increment when modifying schema

  final String CREATE_STOCK = '''
    CREATE TABLE stock (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      barcode TEXT UNIQUE,
      name TEXT,
      expiry_date TEXT,  
      quantity INTEGER,  
      free INTEGER DEFAULT 0,  
      unit_cost REAL,
      profit REAL DEFAULT 0,    
      total_cost REAL,  
      min_unit_cost REAL, 
      max_unit_cost REAL, 
      profit_percentage REAL,  
      min_unit_sell_price REAL, 
      max_unit_sell_price REAL, 
      unit_sell_price REAL  
    )
  ''';

  final String CREATE_USER_TABLE = '''
    CREATE TABLE user (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      username TEXT UNIQUE,
      password TEXT,
      role TEXT
    )
  ''';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, fileName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // Handle database upgrades
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(CREATE_USER_TABLE);
    await db.execute(CREATE_STOCK);
  }


  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      _insertInitialStock(db);
    }
  }

  Future<void> _insertInitialStock(Database db) async {
    List<Stock> stockItems = [
      Stock(barcode: "FR001", name: "Apple", expiryDate: "2024-12-31", quantity: 50, free: 5, unitCost: 1.5, totalCost: 75.0, profit: 15.0, unitSellPrice: 2.0, minUnitCost: 1.2, maxUnitCost: 1.8, minUnitSellPrice: 1.5, maxUnitSellPrice: 2.2),
      Stock(barcode: "FR002", name: "Banana", expiryDate: "2024-11-15", quantity: 30, free: 3, unitCost: 0.5, totalCost: 15.0, profit: 5.0, unitSellPrice: 0.8, minUnitCost: 0.4, maxUnitCost: 0.6, minUnitSellPrice: 0.7, maxUnitSellPrice: 1.0),
      Stock(barcode: "FR003", name: "Orange", expiryDate: "2024-12-20", quantity: 40, free: 4, unitCost: 1.0, totalCost: 40.0, profit: 10.0, unitSellPrice: 1.5, minUnitCost: 0.9, maxUnitCost: 1.3, minUnitSellPrice: 1.2, maxUnitSellPrice: 1.8),
      Stock(barcode: "FR004", name: "Grapes", expiryDate: "2024-10-30", quantity: 25, free: 2, unitCost: 2.0, totalCost: 50.0, profit: 10.0, unitSellPrice: 2.5, minUnitCost: 1.8, maxUnitCost: 2.2, minUnitSellPrice: 2.0, maxUnitSellPrice: 2.8),
      Stock(barcode: "FR005", name: "Watermelon", expiryDate: "2024-09-25", quantity: 10, free: 1, unitCost: 3.0, totalCost: 30.0, profit: 5.0, unitSellPrice: 4.0, minUnitCost: 2.5, maxUnitCost: 3.5, minUnitSellPrice: 3.0, maxUnitSellPrice: 4.5),
      Stock(barcode: "FR006", name: "Strawberry", expiryDate: "2024-11-10", quantity: 15, free: 2, unitCost: 2.5, totalCost: 37.5, profit: 7.5, unitSellPrice: 3.2, minUnitCost: 2.2, maxUnitCost: 3.0, minUnitSellPrice: 2.8, maxUnitSellPrice: 3.6),
      Stock(barcode: "FR007", name: "Pineapple", expiryDate: "2024-10-18", quantity: 20, free: 2, unitCost: 2.0, totalCost: 40.0, profit: 10.0, unitSellPrice: 2.8, minUnitCost: 1.8, maxUnitCost: 2.5, minUnitSellPrice: 2.3, maxUnitSellPrice: 3.2),
      Stock(barcode: "FR008", name: "Mango", expiryDate: "2024-11-30", quantity: 25, free: 3, unitCost: 2.2, totalCost: 55.0, profit: 12.0, unitSellPrice: 3.0, minUnitCost: 2.0, maxUnitCost: 2.8, minUnitSellPrice: 2.5, maxUnitSellPrice: 3.4),
      Stock(barcode: "FR009", name: "Peach", expiryDate: "2024-12-05", quantity: 20, free: 2, unitCost: 1.8, totalCost: 36.0, profit: 6.0, unitSellPrice: 2.5, minUnitCost: 1.5, maxUnitCost: 2.2, minUnitSellPrice: 2.0, maxUnitSellPrice: 2.8),
      Stock(barcode: "FR010", name: "Cherry", expiryDate: "2024-09-15", quantity: 15, free: 1, unitCost: 3.5, totalCost: 52.5, profit: 10.0, unitSellPrice: 4.5, minUnitCost: 3.0, maxUnitCost: 4.0, minUnitSellPrice: 4.0, maxUnitSellPrice: 5.0),
    ];

    for (Stock stock in stockItems) {
      await db.insert('stock', stock.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}