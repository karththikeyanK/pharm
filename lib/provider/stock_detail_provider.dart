import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharm/db/dto/stock_and_details.dart';
import 'package:pharm/db/model/stock_detail.dart';
import '../db/dto/stock_with_details.dart';
import '../db/stock_details_helper.dart';

final stockDetailProvider = StateNotifierProvider<StockDetailNotifier, List<StockDetails>>((ref) {
  return StockDetailNotifier();
});

class StockDetailNotifier extends StateNotifier<List<StockDetails>> {
  StockDetailNotifier() : super([]) {
    loadStockDetails();
  }

  Future<void> loadStockDetails() async {
    try {
      final dbStockDetails = await StockDetailHelper.instance.getAllStockDetails();
      state = dbStockDetails;
    } catch (e) {
      log("Error loading stock details: $e");
    }
  }

  Future<bool> addStockDetail(StockDetails stockDetail) async {
    try {
      await StockDetailHelper.instance.insertStockDetail(stockDetail);
      loadStockDetails();
      return true;
    } catch (e) {
      log("Error adding stock detail: $e");
      return false;
    }
  }

  Future<bool> updateStockDetail(StockDetails stockDetail) async {
    try {
      int r = await StockDetailHelper.instance.updateStockDetail(stockDetail);
      await loadStockDetails();
      return r > 0; // Returns true if rows were affected, false otherwise
    } catch (e) {
      log("Error updating stock detail: $e");
      return false; // Explicitly return false in case of error
    }
  }

  Future<void> deleteStockDetail(int id) async {
    try {
      await StockDetailHelper.instance.deleteStockDetail(id);
      await loadStockDetails();
    } catch (e) {
      log("Error deleting stock detail: $e");
    }
  }

  // Update this method to return the stock details by stock ID
  Future<List<StockDetails>> getStockDetailsByStockId(int stockId) async {
    try {
      return await StockDetailHelper.instance.getStockDetailsByStockId(stockId);
    } catch (e) {
      log("Error loading stock details by stockId: $e");
      return [];
    }
  }

  // get the most nearest expiry date by stock ID
  Future<StockDetails> getNearestExpiryDateByStockId(int stockId,int index) async {
    try {
      return await StockDetailHelper.instance.getNearestExpiryDateByStockId(stockId,index);
    } catch (e) {
      log("Error loading nearest expiry date by stockId: $e");
      return StockDetails.empty();
    }
  }

  // get the total quantity of stock by stock ID
  Future<int> getTotalQuantityByStockId(int stockId) async {
    try {
      return await StockDetailHelper.instance.getTotalQuantityByStockId(stockId);
    } catch (e) {
      log("Error loading total quantity by stockId: $e");
      return 0;
    }
  }

  Future<List<StockWithDetails>> getAllStockAndDetails() async {
    try {
      final stockAndDetails = await StockDetailHelper.instance.getAllStockAndDetails();
      return stockAndDetails;
    } catch (e) {
      log("Error loading all stock and details: $e");
      return [];
    }
  }

  // reduce the quantity of stock by stock ID
  Future<void> reduceStockQuantity(int stockId, int quantity) async {
    try {
      await StockDetailHelper.instance.reduceStockQuantity(stockId, quantity);
      await loadStockDetails();
    } catch (e) {
      log("Error reducing stock quantity: $e");
    }
  }

  Future<StockDetails> getStockDetailsById(int id) async {
    try {
      return await StockDetailHelper.instance.getStockDetailById(id);
    } catch (e) {
      log("Error loading stock detail by ID: $e");
      return StockDetails.empty();
    }
  }
}