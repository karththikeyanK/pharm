import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pharm/db/model/stock_detail.dart';
import 'package:pharm/provider/router_provider.dart';
import 'package:pharm/provider/stock_detail_provider.dart';

import '../../db/model/stock.dart';
import '../../provider/stock_provider.dart';

class AddStockPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends ConsumerState<AddStockPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController freeController = TextEditingController();
  final TextEditingController unitCostController = TextEditingController();
  final TextEditingController totalCostController = TextEditingController();
  final TextEditingController profitController = TextEditingController();
  final TextEditingController unitSellPriceController = TextEditingController();
  final TextEditingController minUnitCostController = TextEditingController();
  final TextEditingController maxUnitCostController = TextEditingController();
  final TextEditingController minUnitSellPriceController =
      TextEditingController();
  final TextEditingController maxUnitSellPriceController =
      TextEditingController();

  bool stockFound = false;
  bool stockCreated = false;
  Stock? currentStock;

  List<StockDetails> stockDetailsList = [];

  @override
  void initState() {
    super.initState();
    stockFound = false;
  }

  void _searchStock() async {
    final barcode = barcodeController.text.trim();
    final name = nameController.text.trim();

    if (barcode.isNotEmpty) {
      currentStock = await ref
          .read(stockProvider.notifier)
          .getStockByBarcode(barcode);
    } else if (name.isNotEmpty) {
      currentStock = await ref
          .read(stockProvider.notifier)
          .getStockByName(name);
    }

    if (!mounted) return;

    setState(() {
      stockFound =
          currentStock != null &&
          currentStock!.id != null &&
          currentStock!.id! > 0;
      if (stockFound) {
        loadStocks(currentStock!.barcode);
      }
    });

    if (!mounted) return;

    if (stockFound) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock found!'), backgroundColor: Colors.green),
      );
    } else {
      if (barcode.isNotEmpty && name.isNotEmpty) {
        addStock(context, ref);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('please enter barcode and name to add stock!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void loadStocks(String barcode) async {
    if (currentStock != null) {
      List<StockDetails> stockDetails = await ref
          .read(stockDetailProvider.notifier)
          .getStockDetailsByStockId(currentStock!.id!);

      setState(() {
        stockDetailsList = stockDetails;
      });

      _populateFieldsWithStock(currentStock!);
    }
  }

  void _populateFieldsWithStock(Stock stock) {
    barcodeController.text = stock.barcode;
    nameController.text = stock.name;
  }

  void _selectExpiryDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        expiryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> addStock(BuildContext context, WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    Stock stock = Stock(
      barcode: barcodeController.text.trim(),
      name: nameController.text.trim(),
    );


    bool success = await ref.read(stockProvider.notifier).addStock(stock);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${stock.name} added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add stock!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addStockDetails() async {
    StockDetails stockDetails = StockDetails(
      expiryDate: expiryDateController.text.trim(),
      quantity: int.tryParse(quantityController.text) ?? 0,
      loadqty: int.tryParse(quantityController.text) ?? 0,
      free: int.tryParse(freeController.text) ?? 0,
      unitCost: double.tryParse(unitCostController.text) ?? 0.0,
      totalCost: double.tryParse(totalCostController.text) ?? 0.0,
      profit: double.tryParse(profitController.text) ?? 0.0,
      minUnitCost: double.tryParse(minUnitCostController.text) ?? 0.0,
      maxUnitCost: double.tryParse(maxUnitCostController.text) ?? 0.0,
      minUnitSellPrice: double.tryParse(minUnitSellPriceController.text) ?? 0.0,
      maxUnitSellPrice: double.tryParse(maxUnitSellPriceController.text) ?? 0.0,
      unitSellPrice: double.tryParse(unitSellPriceController.text) ?? 0.0,
      id: null,
      stockId: currentStock!.id,
    );

    bool success = await ref
        .read(stockDetailProvider.notifier)
        .addStockDetail(stockDetails);

    if (!mounted) return; // Ensure the widget is still in the tree

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock details added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      GoRouter.of(context).go(VIEW_STOCK);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add stock details!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Stock',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            GoRouter.of(context).go(ADMIN_SETTINGS);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 46),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(barcodeController, 'Barcode'),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(nameController, 'Product Name'),
                  ),
                  SizedBox(width: 16),
                  buildElevatedButton(
                    label: 'Search/Add Stock',
                    onPressed: _searchStock,
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildStockDetailsInput(),
              SizedBox(height: 16),
              if (stockFound) ...[
                Text(
                  'Total Quantity: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildStockDetailsTable(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      controller: expiryDateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Expiry Date',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () => _selectExpiryDate(context),
        ),
      ),
    );
  }

  Widget _buildStockDetailsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Expiry Date')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('Free')),
          DataColumn(label: Text('Unit Cost')),
          DataColumn(label: Text('Total Cost')),
          DataColumn(label: Text('Profit')),
          DataColumn(label: Text('Min Unit Cost')),
          DataColumn(label: Text('Max Unit Cost')),
          DataColumn(label: Text('Min Unit Sell Price')),
          DataColumn(label: Text('Max Unit Sell Price')),
          DataColumn(label: Text('Unit Sell Price')),
        ],
        rows:
            stockDetailsList.map((detail) {
              return DataRow(
                cells: [
                  DataCell(Text(detail.expiryDate)),
                  DataCell(Text(detail.quantity.toString())),
                  DataCell(Text(detail.free.toString())),
                  DataCell(Text(detail.unitCost.toString())),
                  DataCell(Text(detail.totalCost.toString())),
                  DataCell(Text(detail.profit.toString())),
                  DataCell(Text(detail.minUnitCost.toString())),
                  DataCell(Text(detail.maxUnitCost.toString())),
                  DataCell(Text(detail.minUnitSellPrice.toString())),
                  DataCell(Text(detail.maxUnitSellPrice.toString())),
                  DataCell(Text(detail.unitSellPrice.toString())),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget buildElevatedButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[800], // Background color
        foregroundColor: Colors.white, // Text color
        padding: EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ), // Button padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        elevation: 5, // Button shadow
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }


  Widget _buildStockDetailsInput() {
    return Column(
      children: [
        SizedBox(height: 16),
        // Add test Please input your new stock details
        Text(
          'Please input your new stock details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildNumberField(quantityController, 'Quantity')),
            SizedBox(width: 16),
            Expanded(child: _buildNumberField(freeController, 'Free')),
            SizedBox(width: 16),
            Expanded(child: _buildNumberField(unitCostController, 'Unit Cost')),
            SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(totalCostController, 'Total Cost'),
            ),
          ],
        ),
        SizedBox(height: 16),

        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildNumberField(profitController, 'Profit')),
            SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                unitSellPriceController,
                'Unit Sell Price',
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(minUnitCostController, 'Min Unit Cost'),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(maxUnitCostController, 'Max Unit Cost'),
            ),
          ],
        ),
        SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _buildDateField(context)),
            SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                minUnitSellPriceController,
                'Min Unit Sell Price',
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                maxUnitSellPriceController,
                'Max Unit Sell Price',
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        buildElevatedButton(
          label: 'Add Stock Details',
          onPressed: _addStockDetails,
        ),
      ],
    );
  }
}
