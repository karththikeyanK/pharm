import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharm/constant/appconstant.dart';
import 'package:pharm/db/model/bill.dart';
import 'package:pharm/db/model/bill_item.dart';
import 'package:pharm/provider/bill_item_provide.dart';
import '../../db/dto/stock_with_details.dart';
import '../../db/model/stock.dart';
import '../../provider/bill_provider.dart';
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
  final TextEditingController searchController = TextEditingController();
  final FocusNode quantityFocusNode = FocusNode();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode barcodeFocusNode = FocusNode();
  List<Map<String, dynamic>> items = [];
  List<Stock> stocks = [];
  List<StockWithDetails> stockDetails = [];
  List<StockWithDetails> temp = [];
  bool isLoading = true;


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
    }else{
      barcodeController.clear();
      nameController.clear();

      showErrorSnackBar("Please Try again!");
    }
  }

  Future<void> validateQty(Stock stock, int qty) async {
    double amount = 0;
    int availableQty = await ref
        .read(stockDetailProvider.notifier)
        .getTotalQuantityByStockId(stock.id!);
    int alreadyAddedQty = getAvailableQty(stock.barcode);
    if (qty > availableQty - alreadyAddedQty) {
      showStyledDialog(
        context: context,
        title: 'Stock Alert',
        content: 'Not enough stock available\nAvailable Stock: $availableQty',
        icon: Icons.inventory_2,
        iconColor: Colors.orange.shade700,
        confirmText: 'OK',
        confirmColor: Colors.blue.shade800,
        onConfirm: () => context.pop(),
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
          "stockId": stock.id,
          "stockDetailId": stockDetail.id,
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



  Future<void> showStyledDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'OK',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
    Color? cancelColor,
    IconData? icon,
    Color? iconColor,
    bool barrierDismissible = true,
  }) async {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300), // Set your desired max width here
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Icon(
                      icon,
                      size: 48,
                      color: iconColor ?? theme.primaryColor,
                    ),
                  ),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (cancelText != null)
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onCancel?.call();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: cancelColor ??
                              (isDarkMode ? Colors.white70 : Colors.grey.shade700),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: Text(cancelText),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor ?? theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        elevation: 2,
                      ),
                      child: Text(confirmText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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

  double getDiscount() {
    return items.fold(0, (sum, item) => sum + (item["discount"]*item["quantity"]));
  }

@override
void initState() {
  super.initState();
  customerAmountController.addListener(() {
    setState(() {}); // Rebuild the UI when customer amount changes
  });
  _fetchStockDetails();
}

  Future<void> _fetchStockDetails() async {
    final data = await ref.read(stockDetailProvider.notifier).getAllStockAndDetails();
    final filteredData = data.where((item) => item.quantity > 0).toList();
    setState(() {
      stockDetails = filteredData;
      temp = filteredData;
      isLoading = false;
    }); // Update the UI after fetching the data
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
        child: Row(
          children:[
            Expanded(
              flex: 7,
              child: Padding(
                padding: EdgeInsets.all(10.0),
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
                        scrollDirection: Axis.vertical, // Enable horizontal scrolling
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text("Name")),
                            DataColumn(label: Text("Exp Date")),
                            DataColumn(label: Text("Qty")),
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
                                DataCell(Text(items[index]["quantity"]?.toString() ?? '0'),),
                                DataCell(Text((items[index]["minUnitSellPrice"] ?? 0.0).toStringAsFixed(2),),),
                                DataCell(Text((items[index]["maxUnitSellPrice"] ?? 0.0).toStringAsFixed(2),),),
                                DataCell(Text((items[index]["unitSellPrice"] ?? 0.0).toStringAsFixed(2),),),
                                DataCell(
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: "0.0",
                                      border: InputBorder.none,
                                    ),
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
                    paymentSection()
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3, // 30% width
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.5), // Border color & width
                  borderRadius: BorderRadius.circular(8.0), // Optional: Rounded corners
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.0), // Add padding inside the right section
                  child: _searchStock(), // Call the function to build the search stock section
                ),
              ),
            )
          ]
        ),
      ),
    );
  }

  Widget paymentSection(){
    return Column(
      children: [
        const SizedBox(height: 24),

        // Horizontal Amount Cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Total Amount
                _buildCompactAmountCard(
                  title: "Total",
                  amount: getTotalAmount(),
                  icon: Icons.receipt,
                  color: Colors.blue.shade700,
                  width: 250,
                ),
                const SizedBox(width: 12),

                // Discount
                _buildCompactAmountCard(
                  title: "Discount",
                  amount: getDiscount(),
                  icon: Icons.discount,
                  color: Colors.orange.shade700,
                  width: 250,
                ),
                const SizedBox(width: 12),

                // Customer Amount Input (Compact)
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payments, size: 20, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text(
                            "Paid",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: customerAmountController,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: "0.00",
                          prefixText: "LKR ",
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Balance Display
        Center(
          child: Container(
            width: 250,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: getBalance() < 0
                  ? Colors.red.shade100
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                children: [
                  const TextSpan(text: "Balance: "),
                  TextSpan(
                    text: "LKR ${getBalance().toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: getBalance() < 0
                          ? Colors.red.shade800
                          : Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Submit Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ElevatedButton(
            onPressed: () {
              double balance = getBalance();
              if (balance < 0) {
                showErrorSnackBar("Payment insufficient by LKR ${balance.abs().toStringAsFixed(2)}");
              } else {
                addBill();
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              "PROCESS PAYMENT",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }


  // Compact Amount Card Widget
  Widget _buildCompactAmountCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "LKR ${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchStock() {
    return Column(
      children: [
        _buildInputField(controller: searchController, label: "Search Stock"),
        SizedBox(height: 10),

        ElevatedButton(
          onPressed: () async {
            await _fetchStockDetails();
            _filterStocks(searchController.text);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            "SEARCH STOCK",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),

        SizedBox(height: 10),

        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
          :_buildStockList()// Function to build and display stock list
        ),
      ],
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

  Future<void> addBill() async {
    log("User ID: ${AppsConstant.userId}");
    Bill bill = Bill(
      id: null,
      userId: AppsConstant.userId,
      total: double.parse((getTotalAmount() as num).toStringAsFixed(2)),
      totalDiscount: getDiscount(),
      createAt: DateTime.now().toString(),
      status: "ACTIVE",
    );

    int r = await ref.read(billProvider.notifier).addBill(bill);
    if (r < 1 ) {
      showErrorSnackBar("Error adding bill");
      return;
    }else{
      List<BillItem> billItems = items.map((item) {
        return BillItem(
          id: null,
          billId: r,
          stockId: item["stockId"],
          quantity: item["quantity"],
          unitSellPrice: item["unitSellPrice"],
          discount: item["discount"],
          totalCost: double.parse((item["amount"] as num).toStringAsFixed(2)),
        );
      }).toList();

      for (BillItem billItem in billItems) {
       await ref.read(billItemProvider.notifier).addBillItem(billItem);
      }

      for (int i = 0; i < items.length; i++) {
        int stockDetailId = items[i]["stockDetailId"];
        int quantity = items[i]["quantity"];
        await ref.read(stockDetailProvider.notifier).reduceStockQuantity(stockDetailId, quantity);
      }

      setState(() {
        items.clear();
        customerAmountController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bill added successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
    }

  Widget _buildStockList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Expiry Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Min Price', style: TextStyle(fontWeight: FontWeight.bold))),
            // DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: temp.map((detail) {
            return DataRow(
              cells: [
                DataCell(Text(detail.name)),
                DataCell(Text(detail.expiryDate)),
                DataCell(Text(detail.quantity.toString())),
                DataCell(Text(detail.minUnitSellPrice.toStringAsFixed(2))),
                // DataCell(Text(detail.unitSellPrice.toStringAsFixed(2))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Filter function
  void _filterStocks(String query) {
    if (query.isEmpty) {
      // If search is empty, show all items
      setState(() {
        temp = stockDetails;
      });
      return;
    }

    setState(() {
      temp = stockDetails.where((stock) {
        // Search by name (case insensitive)
        final nameMatch = stock.name.toLowerCase().contains(query.toLowerCase());
        // Search by barcode (case insensitive)
        final barcodeMatch = stock.barcode.toLowerCase().contains(query.toLowerCase());
        // Search by expiry date
        final expiryMatch = stock.expiryDate.toLowerCase().contains(query.toLowerCase());

        // Return true if any field matches
        return nameMatch || barcodeMatch || expiryMatch;
      }).toList();
    });
  }

}