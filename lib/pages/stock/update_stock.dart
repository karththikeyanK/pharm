import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pharm/db/model/stock_detail.dart';
import 'package:pharm/provider/stock_detail_provider.dart';
import '../../db/model/stock.dart';
import '../../provider/router_provider.dart';
import '../../provider/stock_provider.dart';

class UpdateStockPage extends ConsumerStatefulWidget {
  final int stockDetailsId;

  UpdateStockPage({required this.stockDetailsId});

  @override
  ConsumerState<UpdateStockPage> createState() => _UpdateStockPageState();
}

class _UpdateStockPageState extends ConsumerState<UpdateStockPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController reminderDateController = TextEditingController();
  final TextEditingController reminderQtyController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController loadqtyController = TextEditingController();
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

  Stock? currentStock;
  StockDetails? currentStockDetails;

  @override
  void initState() {
    super.initState();
    _loadStockDetails();
  }

  Future<void> _loadStockDetails() async {
    StockDetails? stockDetails = await ref
        .read(stockDetailProvider.notifier)
        .getStockDetailsById(widget.stockDetailsId);

    if (stockDetails != null) {
      Stock? stock = await ref
          .read(stockProvider.notifier)
          .getStockById(stockDetails.stockId!);

      setState(() {
        currentStockDetails = stockDetails;
        currentStock = stock;
        _populateFields(stockDetails, stock);
      });
    }
  }

  void _populateFields(StockDetails stockDetails, Stock? stock) {
    barcodeController.text = stock?.barcode ?? '';
    nameController.text = stock?.name ?? '';
    expiryDateController.text = stockDetails.expiryDate;
    reminderDateController.text = stockDetails.reminderDate;
    reminderQtyController.text = stockDetails.reminderQty.toString();
    quantityController.text = stockDetails.quantity.toString();
    freeController.text = stockDetails.free.toString();
    unitCostController.text = stockDetails.unitCost.toString();
    totalCostController.text = stockDetails.totalCost.toString();
    profitController.text = stockDetails.profit.toString();
    minUnitCostController.text = stockDetails.minUnitCost.toString();
    maxUnitCostController.text = stockDetails.maxUnitCost.toString();
    minUnitSellPriceController.text = stockDetails.minUnitSellPrice.toString();
    maxUnitSellPriceController.text = stockDetails.maxUnitSellPrice.toString();
    unitSellPriceController.text = stockDetails.unitSellPrice.toString();
    loadqtyController.text = stockDetails.loadqty.toString();
  }

  Future<void> _updateStockDetails() async {
    StockDetails updatedStockDetails = StockDetails(
      id: currentStockDetails!.id,
      stockId: currentStock!.id,
      expiryDate: expiryDateController.text.trim(),
      reminderDate: reminderDateController.text.trim(),
      reminderQty: int.tryParse(reminderQtyController.text) ?? 0,
      quantity: int.tryParse(quantityController.text) ?? 0,
      free: int.tryParse(freeController.text) ?? 0,
      unitCost: double.tryParse(unitCostController.text) ?? 0.0,
      totalCost: double.tryParse(totalCostController.text) ?? 0.0,
      profit: double.tryParse(profitController.text) ?? 0.0,
      minUnitCost: double.tryParse(minUnitCostController.text) ?? 0.0,
      maxUnitCost: double.tryParse(maxUnitCostController.text) ?? 0.0,
      minUnitSellPrice: double.tryParse(minUnitSellPriceController.text) ?? 0.0,
      maxUnitSellPrice: double.tryParse(maxUnitSellPriceController.text) ?? 0.0,
      unitSellPrice: double.tryParse(unitSellPriceController.text) ?? 0.0,
      loadedAt: currentStockDetails!.loadedAt,
      loadqty: int.tryParse(loadqtyController.text) ?? 0,
    );

    bool success = await ref.read(stockDetailProvider.notifier).updateStockDetail(updatedStockDetails);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock details updated!'),
          backgroundColor: Colors.green,
        ),
      );
      GoRouter.of(context).go(VIEW_STOCK);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Stock',
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
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 46),
            Row(
              children: [
                Expanded(child: _buildTextField(barcodeController, 'Barcode')),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(nameController, 'Product Name'),
                ),
                SizedBox(width: 16),
                buildElevatedButton(
                  label: 'Update Stock',
                  onPressed: () => updateStock(currentStock!.id!),
                ),
              ],
            ),
            SizedBox(height: 16),

            _buildStockDetailsInput(),
          ],
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

  Widget _buildStockDetailsInput() {
    return Column(
      children: [
        SizedBox(height: 16),
        // Add test Please input your new stock details
        Text(
          'Please Update your new stock details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildNumberField(quantityController, 'Available Qty')),
            SizedBox(width: 16),
            Expanded(child: _buildNumberField(loadqtyController, 'Load Quantity')),
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
            Expanded(
              child: _buildDateField(
                context,
                'Expiry Date',
                expiryDateController,
                true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                context,
                'Reminder Date',
                reminderDateController,
                false,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                reminderQtyController,
                'Reminder Quantity',
              ),
            ),
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
        SizedBox(height: 16),
        buildElevatedButton(
          label: 'Update Stock Details',
          onPressed: _updateStockDetails,
        ),
      ],
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

  Widget _buildDateField(
    BuildContext context,
    String lable,
    TextEditingController controller,
    bool isExpire,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: lable,
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () => _selectExpiryDate(context, isExpire),
        ),
      ),
    );
  }

  void _selectExpiryDate(BuildContext context, bool isExpire) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isExpire) {
          expiryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          reminderDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  void updateStock(int id) async{
    Stock u_stock = Stock(
      barcode: barcodeController.text.trim(),
      name: nameController.text.trim(),
      id: id,
    );

    await ref.read(stockProvider.notifier).updateStock(u_stock);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stock updated!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
