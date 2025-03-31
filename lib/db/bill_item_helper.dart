import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:pharm/db/db_helper.dart';
import 'dto/bill_item_detail.dart';
import 'model/bill_item.dart';

class BillItemHelper {
  static final BillItemHelper _instance = BillItemHelper._internal();

  static BillItemHelper get instance => _instance;

  BillItemHelper._internal();

  String createAt = DatabaseHelper.CREATE_AT;

  Future<int> insertBillItem(BillItem billItem) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(
      DatabaseHelper.BILL_ITEM_TABLE,
      billItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BillItemDetail>> getByBillId(int billId) async {
    final db = await DatabaseHelper.instance.database;
    String query = '''
      SELECT bi.id, bi.bill_id, bi.stock_id, bi.quantity, bi.unit_sell_price, bi.total_cost, bi.discount, s.name as stock_name
      FROM ${DatabaseHelper.BILL_ITEM_TABLE} bi
      JOIN ${DatabaseHelper.STOCK_TABLE} s
      ON bi.stock_id = s.id
      WHERE bi.bill_id = $billId
    ''';
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return List.generate(maps.length, (i) => BillItemDetail.fromMap(maps[i]));
  }

  Future<List<BillItem>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.BILL_ITEM_TABLE);
    return List.generate(maps.length, (i) => BillItem.fromMap(maps[i]));
  }

  Future<int> updateBillItem(BillItem billItem) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      DatabaseHelper.BILL_ITEM_TABLE,
      billItem.toMap(),
      where: '${DatabaseHelper.ID} = ?',
      whereArgs: [billItem.id],
    );
  }

  Future<int> deleteBillItem(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      DatabaseHelper.BILL_ITEM_TABLE,
      where: '${DatabaseHelper.ID} = ?',
      whereArgs: [id],
    );
  }
}