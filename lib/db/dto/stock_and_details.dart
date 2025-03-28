import '../model/stock.dart';
import '../model/stock_detail.dart';

class StockAndDetails {
  Stock stock;
  List<StockDetails> stockDetails;

  StockAndDetails({
    required this.stock,
    required this.stockDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'stock': stock.toMap(),
      'stock_details': stockDetails.map((detail) => detail.toMap()).toList(),
    };
  }

  factory StockAndDetails.fromMap(Map<String, dynamic> map) {
    return StockAndDetails(
      stock: Stock.fromMap(map['stock']),
      stockDetails: (map['stock_details'] as List)
          .map((detail) => StockDetails.fromMap(detail))
          .toList(),
    );
  }

  static StockAndDetails empty() {
    return StockAndDetails(
      stock: Stock.empty(),
      stockDetails: [],
    );
  }
}
