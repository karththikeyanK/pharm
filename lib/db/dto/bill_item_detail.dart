class BillItemDetail {
  final int? id;
  final int billId;
  final String stockName;
  final int quantity;
  final double unitSellPrice;
  final double totalCost;
  final double discount;

  BillItemDetail({
    required this.id,
    required this.billId,
    required this.stockName,
    required this.quantity,
    required this.unitSellPrice,
    required this.totalCost,
    required this.discount,
  });

  factory BillItemDetail.fromMap(Map<String, dynamic> json) {
    return BillItemDetail(
      id: json['id'],
      billId: json['bill_id'],
      stockName: json['stock_name'],
      quantity: json['quantity'],
      unitSellPrice: json['unit_sell_price'].toDouble(),
      totalCost: json['total_cost'].toDouble(),
      discount: json['discount'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bill_id': billId,
      'stock_name': stockName,
      'quantity': quantity,
      'unit_sell_price': unitSellPrice,
      'total_cost': totalCost,
      'discount': discount,
    };
  }

  BillItemDetail copyWith({
    int? id,
    int? billId,
    String? stockName,
    int? quantity,
    double? unitSellPrice,
    double? totalCost,
    double? discount,
  }) {
    return BillItemDetail(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      stockName: stockName ?? this.stockName,
      quantity: quantity ?? this.quantity,
      unitSellPrice: unitSellPrice ?? this.unitSellPrice,
      totalCost: totalCost ?? this.totalCost,
      discount: discount ?? this.discount,
    );
  }

  @override
  String toString() {
    return 'BillItemDetail{id: $id, billId: $billId, stockName: $stockName, quantity: $quantity, unitSellPrice: $unitSellPrice, totalCost: $totalCost, discount: $discount}';
  }
}