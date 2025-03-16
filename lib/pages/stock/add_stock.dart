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
      appBar: AppBar(title: Text('Add Stock')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(barcodeController, 'Barcode'),
              _buildTextField(nameController, 'Product Name'),
              _buildDateField(context),
              _buildNumberField(quantityController, 'Quantity'),
              _buildNumberField(freeController, 'Free Items'),
              _buildNumberField(unitCostController, 'Unit Cost'),
              _buildNumberField(totalCostController, 'Total Cost'),
              _buildNumberField(profitController, 'Profit'),
              _buildNumberField(unitSellPriceController, 'Unit Sell Price'),
              _buildNumberField(minUnitCostController, 'Min Unit Cost'),
              _buildNumberField(maxUnitCostController, 'Max Unit Cost'),
              _buildNumberField(minUnitSellPriceController, 'Min Unit Sell Price'),
              _buildNumberField(maxUnitSellPriceController, 'Max Unit Sell Price'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => addStock(context, ref),
                child: Text('Add Stock'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) => value!.isEmpty ? 'Required field' : null,
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) => (value == null || value.isEmpty) ? 'Required field' : null,
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
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
      ),
    );
  }
}
