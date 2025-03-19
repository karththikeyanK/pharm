import 'package:flutter/material.dart';

class BillingPage extends StatefulWidget {
  @override
  _BillingPageState createState() => _BillingPageState();//hi
}

class _BillingPageState extends State<BillingPage> {
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  List<Map<String, dynamic>> items = [];

  void addItem() {
    String barcode = barcodeController.text;
    String name = nameController.text;
    int quantity = int.tryParse(quantityController.text) ?? 0;
    double price = double.tryParse(priceController.text) ?? 0.0;
    double amount = quantity * price;

    if (barcode.isNotEmpty && name.isNotEmpty && quantity > 0 && price > 0) {
      setState(() {
        items.add({
          "barcode": barcode,
          "name": name,
          "quantity": quantity,
          "price": price,
          "amount": amount,
        });
      });

      barcodeController.clear();
      nameController.clear();
      quantityController.clear();
      priceController.clear();
    }
  }

  void deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  double getTotalAmount() {
    return items.fold(0, (sum, item) => sum + item["amount"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Billing Page")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: barcodeController,
                    decoration: InputDecoration(labelText: "Barcode"),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Name"),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Price"),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Quantity"),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addItem,
                  child: Text("Add"),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  DataTable(
                    columns: [
                      DataColumn(label: Text("Barcode")),
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Qty")),
                      DataColumn(label: Text("Price")),
                      DataColumn(label: Text("Amount")),
                      DataColumn(label: Text("Action")),
                    ],
                    rows: List.generate(
                      items.length,
                          (index) => DataRow(cells: [
                        DataCell(Text(items[index]["barcode"])),
                        DataCell(Text(items[index]["name"])),
                        DataCell(Text(items[index]["quantity"].toString())),
                        DataCell(Text(items[index]["price"].toStringAsFixed(2))),
                        DataCell(Text(items[index]["amount"].toStringAsFixed(2))),
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
