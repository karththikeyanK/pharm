class BillDetail{
  final int id;
  final String username;
  final double total;
  final double totalDiscount;
  final String createAt;
  final String status;

  BillDetail({
    required this.id,
    required this.username,
    required this.total,
    required this.totalDiscount,
    required this.createAt,
    required this.status ,
  });

  factory BillDetail.fromMap(Map<String, dynamic> json) {
    return BillDetail(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      total: (json['total_cost'] ?? 0.0).toDouble(),  // Changed from 'total' to 'total_cost'
      totalDiscount: (json['total_discount'] ?? 0.0).toDouble(),
      createAt: json['create_at'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username ?? '',
      'total': total,
      'total_discount': totalDiscount,
      'create_at': createAt,
      'status': status ?? '',
    };
  }
}