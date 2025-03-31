// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:pharm/db/dto/bill_detail.dart';
import 'package:pharm/db/model/bill.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pharm/db/db_helper.dart';

class BillHelper {
  static final BillHelper _instance = BillHelper._internal();

  static BillHelper get instance => _instance;

  BillHelper._internal();

  String createAt = DatabaseHelper.CREATE_AT;
  String ID = DatabaseHelper.ID;
  String USER_ID = DatabaseHelper.USER_ID;
  String TOTAL_COST = DatabaseHelper.TOTAL_COST;
  String TOTAL_DISCOUNT = DatabaseHelper.TOTAL_DISCOUNT;
  String STATUS = DatabaseHelper.STATUS;

  Future<int> insertBill(Bill bill) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(
      DatabaseHelper.BILL_TABLE,
      bill.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Bill>> getByDate(String date) async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.BILL_TABLE,
      where: '$createAt = ?',
      whereArgs: [date],
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  Future<List<BillDetail>> getByDateRange(String startDate, String endDate) async {
    startDate = "$startDate 00:00:00";
    endDate = "$endDate 23:59:59";

    log("Fetching bills from $startDate to $endDate");

    final db = await DatabaseHelper.instance.database;

    // Ensure foreign keys are enabled
    await db.execute("PRAGMA foreign_keys = ON;");

    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.$ID, u.username AS username, b.$TOTAL_COST, b.$TOTAL_DISCOUNT, b.$STATUS, b.$createAt
      FROM ${DatabaseHelper.BILL_TABLE} b
      LEFT JOIN ${DatabaseHelper.USER_TABLE} u ON b.$USER_ID = u.$ID
      WHERE b.$STATUS = 'ACTIVE' AND b.$createAt BETWEEN ? AND ?  
      ORDER BY b.$createAt DESC
    ''', [startDate, endDate]);

    log("Fetched ${maps.length} bills.");
    return List.generate(maps.length, (i) => BillDetail.fromMap(maps[i]));
  }

  Future<int> deleteBill(int id) async {
    try{
      final db = await DatabaseHelper.instance.database;
      return await db.rawUpdate('''
      UPDATE ${DatabaseHelper.BILL_TABLE}
      SET $STATUS = 'DELETED'
      WHERE $ID = ?
    ''', [id]);
    }catch(e){
      log("Error deleting bill: $e");
      return 0;
    }
  }


  Future<List<Bill>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.BILL_TABLE);
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  Future<int> updateBill(Bill bill) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      DatabaseHelper.BILL_TABLE,
      bill.toMap(),
      where: '${DatabaseHelper.ID} = ?',
      whereArgs: [bill.id],
    );
  }

  Future<int> deleteBillByStatus(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      DatabaseHelper.BILL_TABLE,
      where: '${DatabaseHelper.ID} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Bill>> getAllBills() async{
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.BILL_TABLE);
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }


}
