class Bill {
  final int? id;
  final int userId;
  final double total;
  final double totalDiscount;
  final String createAt;

  Bill({
    required this.id,
    required this.userId,
    required this.total,
    required this.totalDiscount,
    required this.createAt,
  });

  factory Bill.fromMap(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      userId: json['user_id'],
      total: json['total_cost'].toDouble(),
      totalDiscount: json['total_discount'].toDouble(),
      createAt: json['create_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'total_cost': total,
      'total_discount': totalDiscount,
      'create_at': createAt,
    };
  }


}