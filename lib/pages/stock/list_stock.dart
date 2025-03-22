import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../provider/router_provider.dart';
import '../../provider/stock_provider.dart';

class ListStockPage extends ConsumerStatefulWidget {
  const ListStockPage({super.key});

  @override
  ListStockPageState createState() => ListStockPageState();
}

class ListStockPageState extends ConsumerState<ListStockPage> {
  @override
  Widget build(BuildContext context) {
    final stockList = ref.watch(stockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock List', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            GoRouter.of(context).go(ADMIN_SETTINGS);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              GoRouter.of(context).go(ADD_STOCK);
            },
          ),
        ],
      ),
      body: stockList.isEmpty
          ? const Center(child: Text('No stocks available'))
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: DataTable(
            border: TableBorder.all(color: Colors.grey),
            columns: const [
              DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Barcode', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Expiry Date', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Free', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Unit Cost', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Total Cost', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Profit', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Min Unit Cost', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Max Unit Cost', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Min Unit Sell Price', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Max Unit Sell Price', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Unit Sell Price', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: stockList.map((stock) {
              return DataRow(cells: [
                DataCell(Text(stock.name)),
                DataCell(Text(stock.barcode)),
                DataCell(Text(stock.expiryDate)),
                DataCell(Text(stock.quantity.toString())),
                DataCell(Text(stock.free.toString())),
                DataCell(Text('${stock.unitCost.toStringAsFixed(2)}')),
                DataCell(Text('${stock.totalCost.toStringAsFixed(2)}')),
                DataCell(Text('${stock.profit.toStringAsFixed(2)}')),
                DataCell(Text('${stock.minUnitCost.toStringAsFixed(2)}')),
                DataCell(Text('${stock.maxUnitCost.toStringAsFixed(2)}')),
                DataCell(Text('${stock.minUnitSellPrice.toStringAsFixed(2)}')),
                DataCell(Text('${stock.maxUnitSellPrice.toStringAsFixed(2)}')),
                DataCell(Text('${stock.unitSellPrice.toStringAsFixed(2)}')),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}