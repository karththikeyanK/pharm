class Stock {
  int? id;
  String barcode;
  String name;
  String expiryDate;
  int quantity;
  int free;
  double unitCost;
  double totalCost;
  double profit;
  double minUnitCost;
  double maxUnitCost;
  double minUnitSellPrice;
  double maxUnitSellPrice;
  double unitSellPrice;

  Stock({
    this.id,
    required this.barcode,
    required this.name,
    required this.expiryDate,
    required this.quantity,
    required this.free,
    required this.unitCost,
    required this.totalCost,
    required this.profit,
    required this.unitSellPrice,
    required this.minUnitCost,
    required this.maxUnitCost,
    required this.minUnitSellPrice,
    required this.maxUnitSellPrice,

  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'expiry_date': expiryDate,
      'quantity': quantity,
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

  // Create a Stock object from the database map
  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      id: map['id'],
      barcode: map['barcode'],
      name: map['name'],
      expiryDate: map['expiry_date'],
      quantity: map['quantity'],
      free: map['free'],
      unitCost: map['unit_cost'],
      totalCost: map['total_cost'],
      profit: map['profit'],
      unitSellPrice: map['unit_sell_price'],
      minUnitCost: map['min_unit_cost'],
      maxUnitCost: map['max_unit_cost'],
      minUnitSellPrice: map['min_unit_sell_price'],
      maxUnitSellPrice: map['max_unit_sell_price'],
    );
  }

  static Stock empty() {
    return Stock(
      id: 0,
      barcode: '',
      name: '',
      expiryDate: '',
      quantity: 0,
      free: 0,
      unitCost: 0.0,
      totalCost: 0.0,
      profit: 0.0,
      unitSellPrice: 0.0,
      minUnitCost: 0.0,
      maxUnitCost: 0.0,
      minUnitSellPrice: 0.0,
      maxUnitSellPrice: 0.0,
    );

  }

}
