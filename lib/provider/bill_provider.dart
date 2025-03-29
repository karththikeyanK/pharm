import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharm/db/dto/bill_detail.dart';

import '../db/bill_helper.dart';
import '../db/model/bill.dart';

final billProvider = StateNotifierProvider<BillNotifier, List<Bill>>((ref) {
  return BillNotifier();
});

class BillNotifier extends StateNotifier<List<Bill>> {
  BillNotifier() : super([]) {
    loadBills();
  }

  Future<void> loadBills() async {
    try {
      final dbBills = await BillHelper.instance.getAllBills();
      state = dbBills;
    } catch (e) {
      log("Error loading bills: $e");
    }
  }

  Future<int> addBill(Bill bill) async {
    try {
      int r = await BillHelper.instance.insertBill(bill);
      return r;
    } catch (e) {
      log("Error adding bill: $e");
      return 0;
    }
  }

  Future<void> updateBill(Bill bill) async {
    try {
      await BillHelper.instance.updateBill(bill);
      await loadBills();
    } catch (e) {
      log("Error updating bill: $e");
    }
  }

  Future<void> deleteBill(int id) async {
    try {
      await BillHelper.instance.deleteBill(id);
      await loadBills();
    } catch (e) {
      log("Error deleting bill: $e");
    }
  }

  Future<List<Bill>?> getBillByDate(String date) async {
    try {
      final dbBill = await BillHelper.instance.getByDate(date);
      return dbBill;
    } catch (e) {
      log("Error loading bill by date: $e");
      return null;
    }
  }


  Future<List<BillDetail>?> getBillByDateRange(String startDate, String endDate) async {
    try {
      final dbBill = await BillHelper.instance.getByDateRange(startDate, endDate);
      log(dbBill.toString());
      return dbBill;
    } catch (e) {
      log("Error loading bill by date range: $e");
      return null;
    }
  }
}