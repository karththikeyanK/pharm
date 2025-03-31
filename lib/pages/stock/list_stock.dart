import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pharm/db/dto/stock_and_details.dart';
import 'package:pharm/db/model/stock.dart';
import '../../provider/router_provider.dart';
import '../../provider/stock_detail_provider.dart';
import '../../provider/stock_provider.dart';

class ListStockPage extends ConsumerStatefulWidget {
  const ListStockPage({super.key});

  @override
  ListStockPageState createState() => ListStockPageState();
}

class ListStockPageState extends ConsumerState<ListStockPage> {
  Future<List<StockAndDetails>> _fetchStockAndDetails(
    List<Stock> stockList,
  ) async {
    List<StockAndDetails> stockAndDetails = [];
    for (Stock stock in stockList) {
      if (stock.id != null) {
        final detailsList = await ref
            .read(stockDetailProvider.notifier)
            .getStockDetailsByStockId(stock.id!);
        stockAndDetails.add(
          StockAndDetails(stock: stock, stockDetails: detailsList),
        );
      }
    }
    return stockAndDetails;
  }

  @override
  void initState() {
    super.initState();
    ref.read(stockProvider.notifier).loadStocks();
  }


  @override
  Widget build(BuildContext context) {
    final stockList = ref.watch(stockProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stock Inventory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go(ADMIN_SETTINGS),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => GoRouter.of(context).go(ADD_STOCK),
          ),
        ],
      ),
      body:
          stockList.isEmpty
              ? const Center(child: Text('No stocks available'))
              : FutureBuilder<List<StockAndDetails>>(
                future: _fetchStockAndDetails(stockList),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No stock details available'),
                    );
                  }

                  final stockAndDetails = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DataTable(
                            columnSpacing: 16,
                            horizontalMargin: 8,
                            dataRowHeight: 60,
                            headingRowHeight: 60,
                            columns: [
                              _buildDataColumn('Name'),
                              _buildDataColumn('Barcode'),
                              _buildDataColumn('Expiry'),
                              _buildDataColumn("Reminder Date"),
                              _buildDataColumn("Reminder Qty"),
                              _buildDataColumn('Qty'),
                              _buildDataColumn('Load Qty'),
                              _buildDataColumn('Free'),
                              _buildDataColumn('Unit Cost'),
                              _buildDataColumn('Total Cost'),
                              _buildDataColumn('Profit'),
                              _buildDataColumn('Min Unit Cost'),
                              _buildDataColumn('Max Unit Cost'),
                              _buildDataColumn('Min Unit Sell Price'),
                              _buildDataColumn('Max Unit Sell Price'),
                              _buildDataColumn('Unit Sell Price'),
                              _buildDataColumn('Loaded At'),
                              _buildDataColumn('Actions'),
                            ],
                            rows:
                                stockAndDetails.expand((item) {
                                  return item.stockDetails.map((detail) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            item.stock.name,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                        DataCell(Text(item.stock.barcode)),
                                        DataCell(
                                          Text(
                                            detail.expiryDate,
                                            style: TextStyle(
                                              color:
                                                  _isExpired(detail.expiryDate)
                                                      ? Colors.red
                                                      : null,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(detail.reminderDate)),
                                        DataCell(Text('${detail.reminderQty}')),
                                        DataCell(Text('${detail.quantity}')),
                                        DataCell(Text('${detail.loadqty}')),
                                        DataCell(Text('${detail.free}')),
                                        DataCell(
                                          Text(
                                            '${detail.unitCost.toStringAsFixed(2)} LKR',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${detail.totalCost.toStringAsFixed(2)} LKR',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${detail.profit.toStringAsFixed(2)} LKR',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${detail.minUnitCost.toStringAsFixed(2)} LKR',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${detail.maxUnitCost.toStringAsFixed(2)} LKR',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${detail.minUnitSellPrice.toStringAsFixed(2)} LKR',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${detail.maxUnitSellPrice.toStringAsFixed(2)} LKR',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${detail.unitSellPrice.toStringAsFixed(2)} LKR',
                                          ),
                                        ),
                                        DataCell(
                                          Text(formatDate(detail.loadedAt)),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 20,
                                                ),
                                                color: Colors.blue,
                                                onPressed:
                                                    () =>
                                                        _editStock(detail.id!),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                ),
                                                color: Colors.red,
                                                onPressed:
                                                    () => _deleteStock(
                                                      detail.id!,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                                }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => GoRouter.of(context).go(ADD_STOCK),
      ),
    );
  }

  DataColumn _buildDataColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  bool _isExpired(String expiryDate) {
    try {
      final expiry = DateTime.parse(expiryDate);
      return expiry.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  void _editStock(int id) async {
    GoRouter.of(context).go('/update-stock/${id}');
  }

  Future<void> _deleteStock(int id) async {
    showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Delete'),
              content: Text('Are you sure you want to delete this stock?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => context.pop(),
                ),
                TextButton(
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () => {context.pop(), deleteFunc(id)},
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed
  }

  Future<void> deleteFunc(int id) async {
    try {
      await ref.read(stockDetailProvider.notifier).deleteStockDetail(id);
      // Show success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Stock deleted successfully')));

      GoRouter.of(context).go(ADMIN_SETTINGS);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete stock: $e')));
    }
  }

  static String formatDate(String dateTimeString) {
    if (dateTimeString.isEmpty) {
      return '';
    }
    final dateTime = DateTime.parse(dateTimeString);
    final formatter = DateFormat('dd/MM/yyyy HH:mm a');
    return formatter.format(dateTime);
  }
}
