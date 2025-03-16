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
      print("Error loading stocks: $e");
    }
  }

  Future<void> addStock(Stock stock) async {
    try {
      await StockHelper.instance.insertStock(stock);
      loadStocks(); // Refresh state
    } catch (e) {
      print("Error adding stock: $e");
    }
  }

  Future<void> updateStock(Stock stock) async {
    try {
      await StockHelper.instance.updateStock(stock);
      await loadStocks();
    } catch (e) {
      print("Error updating stock: $e");
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
}
