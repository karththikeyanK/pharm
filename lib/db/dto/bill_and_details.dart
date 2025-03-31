import 'package:pharm/db/dto/bill_detail.dart';
import '../model/bill_item.dart';
import 'bill_item_detail.dart';

class BillAndDetails{
  final BillDetail billDetail;
  final List<BillItemDetail> billItems;

  BillAndDetails({
    required this.billDetail,
    required this.billItems,
  });

  factory BillAndDetails.fromMap(Map<String, dynamic> map) {
    return BillAndDetails(
      billDetail: BillDetail.fromMap(map['bill_detail']),
      billItems: (map['bill_items'] as List)
          .map((item) => BillItemDetail.fromMap(item))
          .toList(),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'bill_detail': billDetail.toMap(),
      'bill_items': billItems.map((item) => item.toMap()).toList(),
    };
  }


}