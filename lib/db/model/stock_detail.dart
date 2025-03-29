class StockDetails {
  int? id;
  int? stockId;
  String expiryDate;
  int quantity;
  int loadqty;
  int free;
  double unitCost;
  double totalCost;
  double profit;
  double minUnitCost;
  double maxUnitCost;
  double minUnitSellPrice;
  double maxUnitSellPrice;
  double unitSellPrice;

  StockDetails({
    required this.id,
    required this.stockId,
    required this.expiryDate,
    required this.quantity,
    required this.loadqty,
    required this.free,
    required this.unitCost,
    required this.totalCost,
    required this.profit,
    required this.minUnitCost,
    required this.maxUnitCost,
    required this.minUnitSellPrice,
    required this.maxUnitSellPrice,
    required this.unitSellPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stock_id': stockId,
      'expiry_date': expiryDate,
      'quantity': quantity,
      'loadqty': loadqty,
      'free': free,
      'unit_cost': unitCost,
      'total_cost': totalCost,
      'profit': profit,
      'min_unit_cost': minUnitCost,
      'max_unit_cost': maxUnitCost,
      'min_unit_sell_price': minUnitSellPrice,
      'max_unit_sell_price': maxUnitSellPrice,
      'unit_sell_price': unitSellPrice,
    };
  }

  factory StockDetails.fromMap(Map<String, dynamic> map) {
    return StockDetails(
      id: map['id'],
      stockId: map['stock_id'],
      expiryDate: map['expiry_date'],
      quantity: map['quantity'],
      loadqty: map['loadqty'] ?? 0,
      free: map['free'] ?? 0,
      unitCost: map['unit_cost'],
      totalCost: map['total_cost'],
      profit: map['profit'] ?? 0.0,
      minUnitCost: map['min_unit_cost'],
      maxUnitCost: map['max_unit_cost'],
      minUnitSellPrice: map['min_unit_sell_price'],
      maxUnitSellPrice: map['max_unit_sell_price'],
      unitSellPrice: map['unit_sell_price'],
    );
  }

  static Future<StockDetails> empty() {
    return Future.value(
      StockDetails(
        id: 0,
        stockId: 0,
        expiryDate: '',
        quantity: 0,
        loadqty: 0,
        free: 0,
        profit: 0.0,
        unitCost: 0.0,
        totalCost: 0.0,
        minUnitCost: 0.0,
        maxUnitCost: 0.0,
        minUnitSellPrice: 0.0,
        maxUnitSellPrice: 0.0,
        unitSellPrice: 0.0,
      ),
    );
  }
}
