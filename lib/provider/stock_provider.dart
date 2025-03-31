import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/model/stock.dart';
import '../db/stock_helper.dart'; // Import stock database helper

final stockProvider = StateNotifierProvider<StockNotifier, List<Stock>>((ref) {
  return StockNotifier();
});

class StockNotifier extends StateNotifier<List<Stock>> {
  StockNotifier() : super([]) {
    loadStocks(); // Load stocks when the provider is initialized
  }

  Future<void> loadStocks() async {
    try {
      final dbStocks = await StockHelper.instance.getAllStocks();
      state = dbStocks;
    } catch (e) {
      log("Error loading stocks: $e");
    }
  }

  Future<bool> addStock(Stock stock) async {
    try {
      await StockHelper.instance.insertStock(stock);
      await loadStocks();
      return true; // Success
    } catch (e) {
      log("Error adding stock: $e");
      return false; // Failure
    }
  }


  Future<void> updateStock(Stock stock) async {
    try {
      await StockHelper.instance.updateStock(stock);
      await loadStocks();
    } catch (e) {
      log("Error updating stock: $e");
    }
  }

  Future<void> deleteStock(int id) async {
    try {
      await StockHelper.instance.deleteStock(id);
      await loadStocks();
    } catch (e) {
      print("Error deleting stock: $e");
    }
  }

  Future<Stock?> getStockByName(String name) async {
    try {
      final dbStock = await StockHelper.instance.getStockByName(name);
      return dbStock; // Return the stock directly
    } catch (e) {
      print("Error loading stock by name: $e");
      return null; // Return null if there's an error
    }
  }


  Future<Stock?> getStockByBarcode(String barcode) async {
    try {
      final dbStock = await StockHelper.instance.getStockByBarcode(barcode);
      return dbStock; // Return the stock directly
    } catch (e) {
      print("Error loading stock by barcode: $e");
      return null; // Return null if there's an error
    }
  }

  Future<Stock?> getStockById(int id) async {
    try {
      final dbStock = await StockHelper.instance.getStockById(id);
      return dbStock; // Return the stock directly
    } catch (e) {
      print("Error loading stock by id: $e");
      return null; // Return null if there's an error
    }
  }



}
