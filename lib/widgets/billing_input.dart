import 'package:flutter/material.dart';
import 'package:flutter_searchable_dropdown/flutter_searchable_dropdown.dart';

import '../db/model/stock.dart';

class BillingInputSection extends StatelessWidget {
  final TextEditingController barcodeController;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final FocusNode quantityFocusNode;
  final FocusNode nameFocusNode;
  final FocusNode barcodeFocusNode;
  final List<Stock> stockList;
  final VoidCallback addItem;

  const BillingInputSection({
    Key? key,
    required this.barcodeController,
    required this.nameController,
    required this.priceController,
    required this.quantityController,
    required this.quantityFocusNode,
    required this.nameFocusNode,
    required this.barcodeFocusNode,
    required this.stockList,
    required this.addItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Barcode Input
        Expanded(
          child: _buildInputField(
            controller: barcodeController,
            label: "Barcode",
            focusNode: barcodeFocusNode,
            onSubmitted: onBarcodeEntered,
          ),
        ),
        const SizedBox(width: 10),

        // Name Input with Dropdown Search
        Expanded(
          child: _buildNameAutocomplete(),
        ),
        const SizedBox(width: 10),

        // Price Input
        Expanded(
          child: _buildInputField(
            controller: priceController,
            label: "Price",
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 10),

        // Quantity Input
        Expanded(
          child: _buildInputField(
            controller: quantityController,
            label: "Quantity",
            keyboardType: TextInputType.number,
            focusNode: quantityFocusNode,
            onSubmitted: (value) {
              // Validate and add item when Enter is pressed in the quantity field
              if (_validateStockSelection()) {
                addItem();
              }
            },
          ),
        ),
        const SizedBox(width: 10),

        // Add Item Button
        ElevatedButton(
          onPressed: addItem,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            backgroundColor: Colors.blue, // Custom color
            foregroundColor: Colors.white, // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
          ),
          child: const Text("Add"), // Add the `child` parameter
        ),
      ],
    );
  }

  // Reusable Input Field Widget
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

  Widget _buildNameAutocomplete() {
    return Autocomplete<Stock>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Stock>.empty();
        }
        return stockList.where((item) => item.name
            .toLowerCase()
            .contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (Stock selection) {
        // Update both controllers when an option is selected
        barcodeController.text = selection.barcode;
        nameController.text = selection.name;
        priceController.text = selection.unitSellPrice.toStringAsFixed(2);
        quantityFocusNode.requestFocus();
      },
      fieldViewBuilder: (
          context,
          textEditingController,
          focusNode,
          onFieldSubmitted,
          ) {
        // Synchronize the textEditingController with the nameController
        textEditingController.text = nameController.text;

        return TextField(
          controller: textEditingController,
          decoration: InputDecoration(
            labelText: "Name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          focusNode: focusNode,
          onChanged: (text) {
            nameController.text = text;
          },
        );
      },
      displayStringForOption: (Stock option) => option.name,
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options.elementAt(index);
                return ListTile(
                  title: Text(option.name),
                  onTap: () {
                    onSelected(option);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Validate if a stock item is selected
  bool _validateStockSelection() {
    return barcodeController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        priceController.text.isNotEmpty;
  }

  void onBarcodeEntered(String barcode) {
    nameController.text = '';
    final stockItem = stockList.firstWhere(
          (item) => item.barcode == barcode,
      orElse: () => Stock.empty(),
    );

    if (stockItem.barcode.isNotEmpty) {
      print("Stock Name: ${stockItem.name}");
      nameFocusNode.requestFocus();
      // barcodeController.text = "${stockItem.name}-${stockItem.barcode}";
      nameController.text = stockItem.name;
      priceController.text = stockItem.unitSellPrice.toStringAsFixed(2);
      quantityFocusNode.requestFocus();
    }
  }
}

