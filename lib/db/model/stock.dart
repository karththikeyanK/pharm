class Stock {
  int? id;
  String barcode;
  String name;

  Stock({
    this.id,
    required this.barcode,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
    };
  }

  // Create a Stock object from the database map
  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      id: map['id'],
      barcode: map['barcode'],
      name: map['name'],
    );
  }

  static Stock empty() {
    return Stock(
      id: 0,
      barcode: '',
      name: '',
    );

  }

}
