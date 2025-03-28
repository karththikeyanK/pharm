import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../db/model/stock.dart';
import '../../provider/router_provider.dart';
import '../../provider/stock_detail_provider.dart';
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
  final TextEditingController customerAmountController = TextEditingController();
  final FocusNode quantityFocusNode = FocusNode();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode barcodeFocusNode = FocusNode();
  List<Map<String, dynamic>> items = [];
  List<Stock> stocks = [];

  double balance = 0.0;

  Future<void> addItem() async {
    String barcode = barcodeController.text;
    String name = nameController.text;
    int quantity = int.tryParse(quantityController.text) ?? 0;

    if (barcode.isNotEmpty && name.isNotEmpty) {
      final stock = findStockByBarcode(barcode);
      validateQty(stock, quantity);

      barcodeController.clear();
      nameController.clear();
      quantityController.clear();
      priceController.clear();
      discountController.clear();
    }
  }

  Future<void> validateQty(Stock stock, int qty) async {
    double amount = 0;
    int availableQty = await ref
        .read(stockDetailProvider.notifier)
        .getTotalQuantityByStockId(stock.id!);
    int alreadyAddedQty = getAvailableQty(stock.barcode);
    if (qty > availableQty - alreadyAddedQty) {
      showAlertDialog(
        "Not enough stock available",
        "Available Stock: $availableQty",
        () {context.pop();},
      );
    } else {
      int i = 0;
      int addedQty = 0;
      while (qty > 0) {
        final stockDetail = await ref
            .read(stockDetailProvider.notifier)
            .getNearestExpiryDateByStockId(stock.id!, i + 1);
        if (qty > stockDetail.quantity) {
          qty -= stockDetail.quantity;
          addedQty = stockDetail.quantity;
          showErrorSnackBar(
            "Maybe same stock price/expire date is different. Please check the stock details.",
          );
        } else {
          addedQty = qty;
          qty = 0;

        }
        priceController.text = stockDetail.unitSellPrice.toStringAsFixed(2);
        amount = addedQty * stockDetail.unitSellPrice;
        setState(() {
          items.add({
          "barcode": stock.barcode,
          "name": stock.name,
          "quantity": addedQty,
          "price": stockDetail.unitSellPrice,
          "discount": 0.0,
          "amount": amount,
          "expiryDate": stockDetail.expiryDate,
          "unitCost": stockDetail.unitCost,
          "totalCost": stockDetail.totalCost,
          "profit": stockDetail.profit,
          "minUnitCost": stockDetail.minUnitCost,
          "maxUnitCost": stockDetail.maxUnitCost,
          "minUnitSellPrice": stockDetail.minUnitSellPrice,
          "maxUnitSellPrice": stockDetail.maxUnitSellPrice,
          "unitSellPrice": stockDetail.unitSellPrice,
          });
        });
        i++;
      }
    }
  }

 

  // Show alert dialog
  Future<void> showAlertDialog(
    String title,
    String content,
    VoidCallback func,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: func, // Use the provided function directly
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // show error snackbar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  int getAvailableQty(String barcode) {
    int availableQty = 0;
    for (int i = 0; i < items.length; i++) {
      if (items[i]["barcode"] == barcode) {
        availableQty +=
            (items[i]["quantity"] as num).toInt(); // Explicitly cast to int
      }
    }
    return availableQty;
  }

  Stock findStockByBarcode(String barcode) {
    return stocks.firstWhere(
      (stock) => stock.barcode == barcode,
      orElse: () => Stock.empty(),
    );
  }

  void deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void updateDiscount(int index, double discount) {
    setState(() {
      items[index]["discount"] = discount;
      items[index]["amount"] =
          items[index]["quantity"] * (items[index]["price"] - discount);
    });
  }

  double getTotalAmount() {
    return items.fold(0, (sum, item) => sum + item["amount"]);
  }

  double getBalance() {
  double customerAmount = double.tryParse(customerAmountController.text) ?? 0.0;
  return customerAmount - getTotalAmount();
}

@override
void initState() {
  super.initState();
  customerAmountController.addListener(() {
    setState(() {}); // Rebuild the UI when customer amount changes
  });
}



  @override
  Widget build(BuildContext context) {
    final stockList = ref.watch(stockProvider);
    stocks = stockList;
    return Scaffold(
      appBar: AppBar(
        title: Text('Billing Page', style: TextStyle(color: Colors.white)),
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                child: DataTable(
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
                    (index) => DataRow(
                      cells: [
                        DataCell(Text(items[index]["name"] ?? 'N/A')),
                        DataCell(Text(items[index]["expiryDate"] ?? 'N/A')),
                        DataCell(
                          Text(items[index]["quantity"]?.toString() ?? '0'),
                        ),
                        DataCell(
                          Text(
                            (items[index]["unitCost"] ?? 0.0).toStringAsFixed(
                              2,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            (items[index]["minUnitSellPrice"] ?? 0.0)
                                .toStringAsFixed(2),
                          ),
                        ),
                        DataCell(
                          Text(
                            (items[index]["maxUnitSellPrice"] ?? 0.0)
                                .toStringAsFixed(2),
                          ),
                        ),
                        DataCell(
                          Text(
                            (items[index]["unitSellPrice"] ?? 0.0)
                                .toStringAsFixed(2),
                          ),
                        ),
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
                        DataCell(
                          Text(
                            (items[index]["amount"] ?? 0.0).toStringAsFixed(2),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteItem(index),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Total Amount: ₹${getTotalAmount().toStringAsFixed(2)}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SizedBox(height: 10),
            _buildInputField(controller: customerAmountController, label: "Amount"),
            SizedBox(height: 10),
            Text(
              "Balance: ₹${getBalance().toStringAsFixed(2)}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                double balance = getBalance();
                if (balance < 0) {
                  showErrorSnackBar("Customer amount is less than total amount");
                } else {
                  showAlertDialog(
                    "Success",
                    "Transaction completed successfully",
                    () {
                      context.pop();
                      context.pop();
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                backgroundColor: Colors.blue, // Custom color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              
              child: const Text("Add bill"), // Add the `child` parameter
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    FocusNode? focusNode,
    Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: keyboardType,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
    );
  }
}