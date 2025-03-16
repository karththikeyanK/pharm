import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const int _databaseVersion = 3; // Increment when modifying schema

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
    if (oldVersion < 2) {
      // delete user and stock
      await db.execute('DROP TABLE IF EXISTS user');
      await db.execute('DROP TABLE IF EXISTS stock');

      // create new user and stock
      await db.execute(CREATE_USER_TABLE);
      await db.execute(CREATE_STOCK);
    }
  }
}
