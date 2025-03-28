import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharm/db/dto/stock_and_details.dart';
import 'package:pharm/db/model/stock.dart';
import '../../db/model/stock_detail.dart';
import '../../provider/router_provider.dart';
import '../../provider/stock_detail_provider.dart';
import '../../provider/stock_provider.dart';

class ListStockPage extends ConsumerStatefulWidget {
  const ListStockPage({super.key});

  @override
  ListStockPageState createState() => ListStockPageState();
}


class ListStockPageState extends ConsumerState<ListStockPage> {

  Future<List<StockAndDetails>> _fetchStockAndDetails(List<Stock> stockList) async {
    List<StockAndDetails> stockAndDetails = [];
    for (Stock stock in stockList) {
      if (stock.id != null) {
        final detailsList = await ref.read(stockDetailProvider.notifier).getStockDetailsByStockId(stock.id!);
        stockAndDetails.add(StockAndDetails(stock: stock, stockDetails: detailsList));
      }
    }
    return stockAndDetails;
  }

  @override
  Widget build(BuildContext context) {
    final stockList = ref.watch(stockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stock List',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
          : FutureBuilder<List<StockAndDetails>>(
        future: _fetchStockAndDetails(stockList),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No stock details available'));
          } else {
            final stockAndDetails = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Barcode', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Expiry Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Free Items', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Unit Cost', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Total Cost', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Profit', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Min Unit Cost', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Max Unit Cost', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Min Unit Sell Price', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Max Unit Sell Price', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Unit Sell Price', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: stockAndDetails.expand((item) {
                    return item.stockDetails.map((detail) {
                      return DataRow(cells: [
                        DataCell(Text(item.stock.name)),  // Stock Name
                        DataCell(Text(item.stock.barcode)), // Stock Barcode
                        DataCell(Text(detail.expiryDate)), // Expiry Date
                        DataCell(Text(detail.quantity.toString())), // Quantity
                        DataCell(Text(detail.free.toString())), // Free Items
                        DataCell(Text(detail.unitCost.toStringAsFixed(2))), // Unit Cost
                        DataCell(Text(detail.totalCost.toStringAsFixed(2))), // Total Cost
                        DataCell(Text(detail.profit.toStringAsFixed(2))), // Profit
                        DataCell(Text(detail.minUnitCost.toStringAsFixed(2))), // Min Unit Cost
                        DataCell(Text(detail.maxUnitCost.toStringAsFixed(2))), // Max Unit Cost
                        DataCell(Text(detail.minUnitSellPrice.toStringAsFixed(2))), // Min Unit Sell Price
                        DataCell(Text(detail.maxUnitSellPrice.toStringAsFixed(2))), // Max Unit Sell Price
                        DataCell(Text(detail.unitSellPrice.toStringAsFixed(2))), // Unit Sell Price
                      ]);
                    });
                  }).toList(),


                ),
              ),
            );
          }
        },
      ),
    );
  }

}