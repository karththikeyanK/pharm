import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../db/model/stock.dart';
import '../../provider/router_provider.dart';
import '../../provider/stock_provider.dart';
import '../../widgets/billing_input.dart';

class BillingPage extends ConsumerStatefulWidget {
  const BillingPage({super.key});

  @override
  BillingPageState createState() => BillingPageState();
}


class BillingPageState extends ConsumerState<BillingPage> {
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final FocusNode quantityFocusNode = FocusNode();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode barcodeFocusNode = FocusNode();
  List<Map<String, dynamic>> items = [];
  List<Stock> stocks = [];

  void addItem() {
    String barcode = barcodeController.text;
    String name = nameController.text;
    int quantity = int.tryParse(quantityController.text) ?? 0;
    double price = double.tryParse(priceController.text) ?? 0.0;
    double discount = double.tryParse(discountController.text) ?? 0.0;
    double amount = (quantity * price) * (1 - discount / 100);

    if (barcode.isNotEmpty && name.isNotEmpty && quantity > 0 && price > 0) {
      final stock = findStockByBarcode(barcode);
      setState(() {
        items.add({
          "barcode": barcode,
          "name": name,
          "quantity": quantity,
          "price": price,
          "discount": discount,
          "amount": amount,
          "expiryDate": stock.expiryDate,
          "unitCost": stock.unitCost,
          "totalCost": stock.totalCost,
          "profit": stock.profit,
          "minUnitCost": stock.minUnitCost,
          "maxUnitCost": stock.maxUnitCost,
          "minUnitSellPrice": stock.minUnitSellPrice,
          "maxUnitSellPrice": stock.maxUnitSellPrice,
          "unitSellPrice": stock.unitSellPrice,
        });
      });

      barcodeController.clear();
      nameController.clear();
      quantityController.clear();
      priceController.clear();
      discountController.clear();
    }
  }

  Stock findStockByBarcode(String barcode) {
    return stocks.firstWhere((stock) => stock.barcode == barcode, orElse: () => Stock.empty());
  }

  void deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void updateDiscount(int index, double discount) {
    setState(() {
      items[index]["discount"] = discount;
      items[index]["amount"] = items[index]["quantity"]*(items[index]["price"]-discount);
    });
  }

  double getTotalAmount() {
    return items.fold(0, (sum, item) => sum + item["amount"]);
  }



  @override
  Widget build(BuildContext context) {
    final stockList = ref.watch(stockProvider);
    stocks = stockList;
    return Scaffold(
      appBar: AppBar(
        title: Text('Billing Page'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            GoRouter.of(context).go(ADMIN_SETTINGS);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            BillingInputSection(
              barcodeController: barcodeController,
              nameController: nameController,
              priceController: priceController,
              quantityController: quantityController,
              quantityFocusNode: quantityFocusNode,
              stockList: stockList,
              addItem: addItem,
              nameFocusNode: nameFocusNode,
              barcodeFocusNode: barcodeFocusNode,
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  DataTable(
                    columns: [
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Expiry Date")),
                      DataColumn(label: Text("Qty")),
                      DataColumn(label: Text("Unit Cost")),
                      DataColumn(label: Text("Min Unit Sell Price")),
                      DataColumn(label: Text("Max Unit Sell Price")),
                      DataColumn(label: Text("Unit Sell Price")),
                      DataColumn(label: Text("Discount (/per)")),
                      DataColumn(label: Text("Amount")),
                      DataColumn(label: Text("Action")),
                    ],
                    rows: List.generate(
                      items.length,
                          (index) => DataRow(cells: [
                            DataCell(Text(items[index]["name"] ?? 'N/A')),
                            DataCell(Text(items[index]["expiryDate"] ?? 'N/A')), // Handling null expiry date
                            DataCell(Text(items[index]["quantity"]?.toString() ?? '0')),
                            DataCell(Text((items[index]["unitCost"] ?? 0.0).toStringAsFixed(2))),
                            DataCell(Text((items[index]["minUnitSellPrice"] ?? 0.0).toStringAsFixed(2))),
                            DataCell(Text((items[index]["maxUnitSellPrice"] ?? 0.0).toStringAsFixed(2))),
                            DataCell(Text((items[index]["unitSellPrice"] ?? 0.0).toStringAsFixed(2))),
                            DataCell(
                              TextField(
                                decoration: InputDecoration(
                                  hintText: "Discount",
                                  border: InputBorder.none,
                                ),
                                controller: discountController,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  barcodeFocusNode.unfocus();
                                  double discount = double.tryParse(value) ?? 0.0;
                                  updateDiscount(index, discount);
                                },
                              ),
                            ),
                            DataCell(Text((items[index]["amount"] ?? 0.0).toStringAsFixed(2))),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteItem(index),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Total Amount: ₹${getTotalAmount().toStringAsFixed(2)}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}