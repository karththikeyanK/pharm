import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/stock_provider.dart';

class ListStockPage extends ConsumerStatefulWidget {
  const ListStockPage({super.key});

  @override
  ListStockPageState createState() => ListStockPageState();
}

class ListStockPageState extends ConsumerState<ListStockPage> {
  @override
  Widget build(BuildContext context) {
    // Fetching the stock list from the provider
    final stockList = ref.watch(stockProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Stock List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to Add Stock page
              Navigator.pushNamed(context, '/add-stock');
            },
          ),
        ],
      ),
      body: stockList.isEmpty
          ? Center(
        child: Text('No stocks available'),
      )
          : ListView.builder(
        itemCount: stockList.length,
        itemBuilder: (context, index) {
          final stock = stockList[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(stock.name),
              subtitle: Text('Barcode: ${stock.barcode}\nExpiry: ${stock.expiryDate}'),
              isThreeLine: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Quantity: ${stock.quantity}'),
                  Text('Cost: \$${stock.unitCost.toStringAsFixed(2)}'),
                  Text('Selling Price: \$${stock.unitSellPrice.toStringAsFixed(2)}'),
                ],
              ),
              onTap: () {
                // Navigate to Edit Stock page
                Navigator.pushNamed(context, '/edit-stock', arguments: stock);
              },
            ),
          );
        },
      ),
    );
  }
}
