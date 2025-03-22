import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pharm/provider/router_provider.dart';

import '../../db/model/stock.dart';
import '../../provider/stock_provider.dart';

class AddStockPage extends ConsumerStatefulWidget {
  const AddStockPage({super.key});

  @override
  AddStockPageState createState() => AddStockPageState();
}

class AddStockPageState extends ConsumerState<AddStockPage> {
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
  final TextEditingController minUnitSellPriceController = TextEditingController();
  final TextEditingController maxUnitSellPriceController = TextEditingController();

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

  void addStock(BuildContext context, WidgetRef ref) {
    if (!_formKey.currentState!.validate()) return;

    Stock stock = Stock(
      barcode: barcodeController.text.trim(),
      name: nameController.text.trim(),
      expiryDate: expiryDateController.text.trim(),
      quantity: int.tryParse(quantityController.text) ?? 0,
      free: int.tryParse(freeController.text) ?? 0,
      unitCost: double.tryParse(unitCostController.text) ?? 0.0,
      totalCost: double.tryParse(totalCostController.text) ?? 0.0,
      profit: double.tryParse(profitController.text) ?? 1.2,
      unitSellPrice: double.tryParse(unitSellPriceController.text) ?? 0.0,
      minUnitCost: double.tryParse(minUnitCostController.text) ?? 0.0,
      maxUnitCost: double.tryParse(maxUnitCostController.text) ?? 0.0,
      minUnitSellPrice: double.tryParse(minUnitSellPriceController.text) ?? 0.0,
      maxUnitSellPrice: double.tryParse(maxUnitSellPriceController.text) ?? 0.0,
    );

    ref.read(stockProvider.notifier).addStock(stock);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${stock.name} added successfully!'), backgroundColor: Colors.green),
    );

    GoRouter.of(context).go(VIEW_STOCK);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Stock', style: TextStyle(fontSize: 24,color: Colors.white, fontWeight: FontWeight.bold)),
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
              // First Row: Barcode, Product Name, Expiry Date, Quantity
              Row(
                children: [
                  Expanded(child: _buildTextField(barcodeController, 'Barcode')),
                  SizedBox(width: 16),
                  Expanded(child: _buildTextField(nameController, 'Product Name')),
                  SizedBox(width: 16),
                  Expanded(child: _buildDateField(context)),
                  SizedBox(width: 16),
                  Expanded(child: _buildNumberField(quantityController, 'Quantity')),
                ],
              ),
              SizedBox(height: 16),

              // Second Row: Free Items, Unit Cost, Total Cost, Profit
              Row(
                children: [
                  Expanded(child: _buildNumberField(freeController, 'Free Items')),
                  SizedBox(width: 16),
                  Expanded(child: _buildNumberField(unitCostController, 'Unit Cost')),
                  SizedBox(width: 16),
                  Expanded(child: _buildNumberField(totalCostController, 'Total Cost')),
                  SizedBox(width: 16),
                  Expanded(child: _buildNumberField(profitController, 'Profit')),
                ],
              ),
              SizedBox(height: 16),

              // Third Row: Unit Sell Price, Min Unit Cost, Max Unit Cost, Min Unit Sell Price
              Row(
                children: [
                  Expanded(child: _buildNumberField(unitSellPriceController, 'Unit Sell Price')),
                  SizedBox(width: 16),
                  Expanded(child: _buildNumberField(minUnitCostController, 'Min Unit Cost')),
                  SizedBox(width: 16),
                  Expanded(child: _buildNumberField(maxUnitCostController, 'Max Unit Cost')),
                  SizedBox(width: 16),
                  Expanded(child: _buildNumberField(minUnitSellPriceController, 'Min Unit Sell Price')),
                ],
              ),
              SizedBox(height: 16),

              // Fourth Row: Max Unit Sell Price
              Row(
                children: [
                  Expanded(child: _buildNumberField(maxUnitSellPriceController, 'Max Unit Sell Price')),
                ],
              ),
              SizedBox(height: 20),
// Add Stock Button
              SizedBox(
                width: 200, // Set a specific width for the button
                child: ElevatedButton(
                  onPressed: () => addStock(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Add Stock',
                    style: TextStyle(fontSize: 16,color: Colors.white),

                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      // validator: (value) => value!.isEmpty ? 'Required field' : null,
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      // validator: (value) => (value == null || value.isEmpty) ? 'Required field' : null,
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
      validator: (value) => value!.isEmpty ? 'Select an expiry date' : null,
    );
  }
}