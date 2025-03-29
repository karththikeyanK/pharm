// ignore_for_file: non_constant_identifier_names
// ignore_for_file: constant_identifier_names
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pharm/db/dto/stock_and_details.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'model/stock.dart';
import 'model/stock_detail.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const int _databaseVersion = 18;

  static const String STOCK_TABLE = 'stock';
  static const String STOCK_DETAIL_TABLE = 'stock_detail';
  static const String USER_TABLE = 'user';
  static const String BILL_TABLE = 'bill';
  static const String BILL_ITEM_TABLE = 'bill_item';

  static const String ID = 'id';
  static const String BARCODE = 'barcode';
  static const String NAME = 'name';
  static const String STOCK_ID = 'stock_id';
  static const String EXPIRY_DATE = 'expiry_date';
  static const String QUANTITY = 'quantity';
  static const String FREE = 'free';
  static const String UNIT_COST = 'unit_cost';
  static const String TOTAL_COST = 'total_cost';
  static const String PROFIT = 'profit';
  static const String MIN_UNIT_COST = 'min_unit_cost';
  static const String MAX_UNIT_COST = 'max_unit_cost';
  static const String PROFIT_PERCENTAGE = 'profit_percentage';
  static const String MIN_UNIT_SELL_PRICE = 'min_unit_sell_price';
  static const String MAX_UNIT_SELL_PRICE = 'max_unit_sell_price';
  static const String UNIT_SELL_PRICE = 'unit_sell_price';
  static const String LOADED_AT = 'loaded_at';
  static const String BILL_ID = 'bill_id';
  static const String USER_ID = 'user_id';
  static const String TOTAL_DISCOUNT = 'total_discount';
  static const String STATUS = 'status';
  static const String CREATE_AT = 'create_at';
  static const String DISCOUNT = 'discount';

  final String CREATE_STOCK = '''
  CREATE TABLE stock (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    barcode TEXT UNIQUE,
    name TEXT
  )
''';

  final String CREATE_STOCK_DETAIL = '''
  CREATE TABLE stock_detail (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    stock_id INTEGER,
    expiry_date TEXT,
    quantity INTEGER,
    loadqty INTEGER ,
    free INTEGER DEFAULT 0,
    unit_cost REAL,
    profit REAL DEFAULT 0,
    total_cost REAL,
    min_unit_cost REAL,
    max_unit_cost REAL,
    profit_percentage REAL,
    min_unit_sell_price REAL,
    max_unit_sell_price REAL,
    unit_sell_price REAL,
    loaded_at TEXT DEFAULT CURRENT_TIMESTAMP,  
    FOREIGN KEY (stock_id) REFERENCES stock(id) ON DELETE CASCADE
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

  final String CREATE_BILL_TABLE = '''
  CREATE TABLE $BILL_TABLE (
    $ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    $USER_ID INTEGER,
    $TOTAL_COST REAL,
    $TOTAL_DISCOUNT REAL,
    $STATUS TEXT,
    $CREATE_AT TEXT,
    FOREIGN KEY ($USER_ID) REFERENCES $USER_TABLE($ID) ON DELETE CASCADE
  )
''';

  final String CREATE_BILL_ITEMS = '''
  CREATE TABLE $BILL_ITEM_TABLE (
    $ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    $BILL_ID INTEGER,
    $STOCK_ID INTEGER,
    $QUANTITY INTEGER,
    $UNIT_SELL_PRICE REAL,
    $TOTAL_COST REAL,
    $DISCOUNT REAL,
    FOREIGN KEY ($BILL_ID) REFERENCES $BILL_TABLE($ID) ON DELETE CASCADE,
    FOREIGN KEY ($STOCK_ID) REFERENCES $STOCK_TABLE($ID) ON DELETE CASCADE
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
    await db.execute(CREATE_STOCK_DETAIL);
    await db.execute(CREATE_BILL_TABLE);
    await db.execute(CREATE_BILL_ITEMS);
  }


  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 18) {
      // want to drop databse
      await db.execute('DROP TABLE IF EXISTS $STOCK_TABLE');
      await db.execute('DROP TABLE IF EXISTS $STOCK_DETAIL_TABLE');
      await db.execute('DROP TABLE IF EXISTS $USER_TABLE');
      await db.execute('DROP TABLE IF EXISTS $BILL_TABLE');
      await db.execute('DROP TABLE IF EXISTS $BILL_ITEM_TABLE');

      await db.execute(CREATE_USER_TABLE);
      await db.execute(CREATE_STOCK);
      await db.execute(CREATE_STOCK_DETAIL);
      await db.execute(CREATE_BILL_TABLE);
      await db.execute(CREATE_BILL_ITEMS);
      insertUser(db);
      await _insertInitialStock(db);
    }
  }

  Future<void> insertUser(Database db) async {
    await db.insert(USER_TABLE, {
      'username': '1010',
      'password': '1234',
      'role': 'admin',
    });
  }

  Future<void> _insertInitialStock(Database db) async {
    List<StockAndDetails> stockAndDetails = [
      StockAndDetails(
        stock: Stock(barcode: "FR001", name: "Apple"),
        stockDetails: [
          StockDetails(
            id: null,
            stockId: 1,
            expiryDate: "2024-12-31",
            quantity: 50,
            loadqty: 50,
            free: 5,
            unitCost: 1.5,
            totalCost: 75.0,
            profit: 15.0,
            minUnitCost: 1.2,
            maxUnitCost: 1.8,
            minUnitSellPrice: 1.5,
            maxUnitSellPrice: 2.2,
            unitSellPrice: 2.0,
          ),
          StockDetails(
            id: null,
            stockId: 1,
            expiryDate: "2025-01-15",
            quantity: 40,
            loadqty: 40,
            free: 4,
            unitCost: 1.4,
            totalCost: 56.0,
            profit: 10.0,
            minUnitCost: 1.1,
            maxUnitCost: 1.7,
            minUnitSellPrice: 1.4,
            maxUnitSellPrice: 2.0,
            unitSellPrice: 1.9,
          ),
          StockDetails(
            id: null,
            stockId: 1,
            expiryDate: "2025-03-10",
            quantity: 60,
            loadqty: 60,
            free: 6,
            unitCost: 1.6,
            totalCost: 96.0,
            profit: 18.0,
            minUnitCost: 1.3,
            maxUnitCost: 1.9,
            minUnitSellPrice: 1.6,
            maxUnitSellPrice: 2.3,
            unitSellPrice: 2.1,
          ),
        ],
      ),
      StockAndDetails(
        stock: Stock(barcode: "FR002", name: "Banana"),
        stockDetails: [
          StockDetails(
            id: null,
            stockId: 2,
            expiryDate: "2024-11-15",
            quantity: 30,
            loadqty: 30,
            free: 3,
            unitCost: 0.5,
            totalCost: 15.0,
            profit: 5.0,
            minUnitCost: 0.4,
            maxUnitCost: 0.6,
            minUnitSellPrice: 0.7,
            maxUnitSellPrice: 1.0,
            unitSellPrice: 0.8,
          ),
          StockDetails(
            id: null,
            stockId: 2,
            expiryDate: "2025-01-20",
            quantity: 25,
            loadqty: 25,
            free: 2,
            unitCost: 0.45,
            totalCost: 11.25,
            profit: 4.5,
            minUnitCost: 0.35,
            maxUnitCost: 0.55,
            minUnitSellPrice: 0.6,
            maxUnitSellPrice: 0.9,
            unitSellPrice: 0.75,
          ),
          StockDetails(
            id: null,
            stockId: 2,
            expiryDate: "2025-02-28",
            quantity: 35,
            loadqty: 35,
            free: 4,
            unitCost: 0.55,
            totalCost: 19.25,
            profit: 6.0,
            minUnitCost: 0.45,
            maxUnitCost: 0.65,
            minUnitSellPrice: 0.8,
            maxUnitSellPrice: 1.1,
            unitSellPrice: 0.9,
          ),
        ],
      ),
      StockAndDetails(
        stock: Stock(barcode: "FR003", name: "Orange"),
        stockDetails: [
          StockDetails(
            id: null,
            stockId: 3,
            expiryDate: "2024-10-05",
            quantity: 40,
            loadqty: 40,
            free: 4,
            unitCost: 0.9,
            totalCost: 36.0,
            profit: 7.2,
            minUnitCost: 0.75,
            maxUnitCost: 1.1,
            minUnitSellPrice: 1.0,
            maxUnitSellPrice: 1.5,
            unitSellPrice: 1.3,
          ),
          StockDetails(
            id: null,
            stockId: 3,
            expiryDate: "2025-01-10",
            quantity: 45,
            loadqty: 45,
            free: 5,
            unitCost: 1.0,
            totalCost: 45.0,
            profit: 9.0,
            minUnitCost: 0.85,
            maxUnitCost: 1.2,
            minUnitSellPrice: 1.1,
            maxUnitSellPrice: 1.6,
            unitSellPrice: 1.4,
          ),
          StockDetails(
            id: null,
            stockId: 3,
            expiryDate: "2025-02-25",
            quantity: 55,
            loadqty: 55,
            free: 6,
            unitCost: 1.1,
            totalCost: 60.5,
            profit: 12.0,
            minUnitCost: 0.95,
            maxUnitCost: 1.3,
            minUnitSellPrice: 1.2,
            maxUnitSellPrice: 1.7,
            unitSellPrice: 1.5,
          ),
        ],
      ),
    ];

    for (StockAndDetails stockData in stockAndDetails) {
      // Insert Stock and get its ID
      int stockId = await db.insert(STOCK_TABLE, {
        'barcode': stockData.stock.barcode,
        'name': stockData.stock.name,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      // Insert all StockDetails related to the Stock
      for (StockDetails detail in stockData.stockDetails) {
        detail.stockId = stockId;
        await db.insert(
          STOCK_DETAIL_TABLE,
          detail.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
  }
}
