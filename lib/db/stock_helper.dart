import 'package:sqflite/sqflite.dart';
import '../db/model/stock.dart';
import 'package:pharm/db/db_helper.dart';

class StockHelper {
  // Singleton instance
  static final StockHelper _instance = StockHelper._internal();

  // Getter to access the instance
  static StockHelper get instance => _instance;

  // Private constructor
  StockHelper._internal();

  Future<int> insertStock(Stock stock) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('stock', stock.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Stock>> getAllStocks() async { // Renamed to match provider usage
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('stock');
    return List.generate(maps.length, (i) => Stock.fromMap(maps[i]));
  }

  Future<int> updateStock(Stock stock) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update('stock', stock.toMap(), where: 'id = ?', whereArgs: [stock.id]);
  }

  Future<int> deleteStock(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('stock', where: 'id = ?', whereArgs: [id]);
  }

  Future<Stock>getStockByBarcode(String barcode)async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('stock', where: 'barcode = ?', whereArgs: [barcode]);
    if (maps.isNotEmpty) {
      return Stock.fromMap(maps.first);
    }
    return Stock.empty();
  }

  Future<Stock> getStockByName(String name) async {
    final db = await DatabaseHelper.instance.database;

    String lowercaseName = name.toLowerCase();
    final List<Map<String, dynamic>> maps = await db.query(
      'stock',
      where: 'LOWER(name) = ?',
      whereArgs: [lowercaseName],
    );

    if (maps.isNotEmpty) {
      return Stock.fromMap(maps.first);
    }
    return Stock.empty();
  }

  Future<Stock> getStockById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('stock', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Stock.fromMap(maps.first);
    }
    return Stock.empty();
  }

}
