import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/bill_item_helper.dart';
import '../db/model/bill_item.dart';

final billItemProvider = StateNotifierProvider<BillItemProvider, List<BillItem>>((ref) {
  return BillItemProvider();
});

class BillItemProvider extends StateNotifier<List<BillItem>> {
  BillItemProvider() : super([]) {
    loadBillItems();
  }

  Future<void> loadBillItems() async {
    try {
      final dbBillItems = await BillItemHelper.instance.getAll();
      state = dbBillItems;
    } catch (e) {
      log("Error loading bill items: $e");
    }
  }

  Future<bool> addBillItem(BillItem billItem) async {
    try {
      int result = await BillItemHelper.instance.insertBillItem(billItem);
      log(result.toString());
      await loadBillItems();
      return true;
    } catch (e) {
      log("Error adding bill item: $e");
      return false;
    }
  }

  Future<void> updateBillItem(BillItem billItem) async {
    try {
      await BillItemHelper.instance.updateBillItem(billItem);
      await loadBillItems();
    } catch (e) {
      log("Error updating bill item: $e");
    }
  }

  Future<void> deleteBillItem(int id) async {
    try {
      await BillItemHelper.instance.deleteBillItem(id);
      await loadBillItems();
    } catch (e) {
      log("Error deleting bill item: $e");
    }
  }

  Future<List<BillItem>?> getBillItemByBillId(int billId) async {
    try {
      final dbBillItem = await BillItemHelper.instance.getByBillId(billId);
      return dbBillItem;
    } catch (e) {
      log("Error loading bill item by billId: $e");
      return null;
    }
  }
}