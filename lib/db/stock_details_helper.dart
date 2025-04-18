import 'package:pharm/db/dto/stock_with_details.dart';
import 'package:pharm/db/model/stock_detail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pharm/db/db_helper.dart';

class StockDetailHelper{

  static final StockDetailHelper _instance = StockDetailHelper._internal();

  static StockDetailHelper get instance => _instance;

  StockDetailHelper._internal();

  Future<int> insertStockDetail(StockDetails stockDetail) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('stock_detail', stockDetail.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<StockDetails>> getAllStockDetails() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('stock_detail');
    return List.generate(maps.length, (i) => StockDetails.fromMap(maps[i]));
  }


  Future<int> updateStockDetail(StockDetails stockDetail) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update('stock_detail', stockDetail.toMap(), where: 'id = ?', whereArgs: [stockDetail.id]);
  }


  Future<int> deleteStockDetail(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('stock_detail', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<StockDetails>> getStockDetailsByStockId(int stockId) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('stock_detail', where: 'stock_id = ?', whereArgs: [stockId]);
    return List.generate(maps.length, (i) => StockDetails.fromMap(maps[i]));
  }

  Future<StockDetails> getNearestExpiryDateByStockId(int stockId, int index) async {
    if (index <= 0) {
      throw ArgumentError("Index must be greater than 0.");
    }

    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_detail',
      where: 'stock_id = ? AND quantity > 0', // Filter by stock ID
      whereArgs: [stockId],
      orderBy: 'expiry_date ASC', // Sort by expiry date (ascending)
      limit: index, // Limit the results to `index` items
    );
    if (maps.length < index) {
      throw Exception("Not enough items found for the given index.");
    }
    return StockDetails.fromMap(maps[index - 1]);
  }

  Future<int>getTotalQuantityByStockId(int stockId) async{
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT SUM(quantity) as total_quantity FROM stock_detail WHERE stock_id = ?', [stockId]);
    return maps[0]['total_quantity'];
  }

  Future<List<StockWithDetails>>  getAllStockAndDetails() {
    return DatabaseHelper.instance.database.then((db) async {
      final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM stock_detail INNER JOIN stock ON stock_detail.stock_id = stock.id');
      return List.generate(maps.length, (i) => StockWithDetails.fromMap(maps[i]));
    });
  }

  // reduce the quantity of stock by stock ID
  Future<int> reduceStockQuantity(int id, int quantity) async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawUpdate('UPDATE stock_detail SET quantity = quantity - ? WHERE id = ?', [quantity, id]);
  }


  Future<StockDetails> getStockDetailById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('stock_detail', where: 'id = ?', whereArgs: [id]);
    return StockDetails.fromMap(maps[0]);
  }



}
