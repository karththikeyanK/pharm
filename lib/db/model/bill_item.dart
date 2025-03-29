class BillItem {
  final int id;
  final int billId;
  final int stockId;
  final int quantity;
  final double unitSellPrice;
  final double totalCost;
  final double discount;

  BillItem({
    required this.id,
    required this.billId,
    required this.stockId,
    required this.quantity,
    required this.unitSellPrice,
    required this.totalCost,
    required this.discount,
  });

  factory BillItem.fromMap(Map<String, dynamic> json) {
    return BillItem(
      id: json['id'],
      billId: json['bill_id'],
      stockId: json['stock_id'],
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
      'stock_id': stockId,
      'quantity': quantity,
      'unit_sell_price': unitSellPrice,
      'total_cost': totalCost,
      'discount': discount,
    };
  }
}
