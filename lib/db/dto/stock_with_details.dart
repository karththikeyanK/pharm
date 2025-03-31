class StockWithDetails {
  final int id;
  final int stockId;
  final String expiryDate;
  final String reminderDate;
  final int reminderQty;
  final int quantity;
  final int loadqty;
  final int free;
  final double unitCost;
  final double profit;
  final double totalCost;
  final double minUnitCost;
  final double maxUnitCost;
  final double minUnitSellPrice;
  final double maxUnitSellPrice;
  final double unitSellPrice;
  final String loadedAt;
  final String barcode;
  final String name;

  StockWithDetails({
    required this.id,
    required this.stockId,
    required this.expiryDate,
    required this.reminderDate,
    required this.reminderQty,
    required this.quantity,
    required this.loadqty,
    required this.free,
    required this.unitCost,
    required this.profit,
    required this.totalCost,
    required this.minUnitCost,
    required this.maxUnitCost,
    required this.minUnitSellPrice,
    required this.maxUnitSellPrice,
    required this.unitSellPrice,
    required this.loadedAt,
    required this.barcode,
    required this.name,
  });

  factory StockWithDetails.fromMap(Map<String, dynamic> map) {
    return StockWithDetails(
      id: map['id'] as int,
      stockId: map['stock_id'] as int,
      expiryDate: map['expiry_date'] as String,
      reminderDate: map['reminder_date'] as String,
      reminderQty: map['reminder_qty'] as int,
      quantity: map['quantity'] as int,
      loadqty: map['loadqty'] as int? ?? 0,
      free: map['free'] as int? ?? 0,
      unitCost: (map['unit_cost'] as num).toDouble(),
      profit: (map['profit'] as num?)?.toDouble() ?? 0.0,
      totalCost: (map['total_cost'] as num).toDouble(),
      minUnitCost: (map['min_unit_cost'] as num).toDouble(),
      maxUnitCost: (map['max_unit_cost'] as num).toDouble(),
      minUnitSellPrice: (map['min_unit_sell_price'] as num).toDouble(),
      maxUnitSellPrice: (map['max_unit_sell_price'] as num).toDouble(),
      unitSellPrice: (map['unit_sell_price'] as num).toDouble(),
      loadedAt: map['loaded_at'] as String,
      barcode: map['barcode'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stock_id': stockId,
      'expiry_date': expiryDate,
      'reminder_date': reminderDate,
      'reminder_qty': reminderQty,
      'quantity': quantity,
      'loadqty': loadqty,
      'free': free,
      'unit_cost': unitCost,
      'profit': profit,
      'total_cost': totalCost,
      'min_unit_cost': minUnitCost,
      'max_unit_cost': maxUnitCost,
      'min_unit_sell_price': minUnitSellPrice,
      'max_unit_sell_price': maxUnitSellPrice,
      'unit_sell_price': unitSellPrice,
      'loaded_at': loadedAt,
      'barcode': barcode,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'StockWithDetails{id: $id, stockId: $stockId, expiryDate: $expiryDate, reminderDate: $reminderDate, reminderQty: $reminderQty, quantity: $quantity, loadqty: $loadqty, free: $free, unitCost: $unitCost, profit: $profit, totalCost: $totalCost, minUnitCost: $minUnitCost, maxUnitCost: $maxUnitCost, minUnitSellPrice: $minUnitSellPrice, maxUnitSellPrice: $maxUnitSellPrice, unitSellPrice: $unitSellPrice, loadedAt: $loadedAt, barcode: $barcode, name: $name}';
  }
}