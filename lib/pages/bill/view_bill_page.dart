import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pharm/db/dto/bill_detail.dart';

import '../../provider/bill_provider.dart';
import '../../provider/router_provider.dart';

class BillTable extends ConsumerStatefulWidget {
  const BillTable({super.key});

  @override
  ConsumerState<BillTable> createState() => _BillTableState();
}

class _BillTableState extends ConsumerState<BillTable> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  late Future<List<BillDetail>?> billsFuture;

  @override
  void initState() {
    super.initState();
    billsFuture = _fetchBills();
  }

  Future<List<BillDetail>?> _fetchBills() async {
    try {
      return await ref.read(billProvider.notifier).getBillByDateRange(
        DateFormat('yyyy-MM-dd').format(startDate),
        DateFormat('yyyy-MM-dd').format(endDate),
      );
    } catch (e) {
      debugPrint("Error loading bill by date range: $e");
      return null;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
        billsFuture = _fetchBills();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Bills', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            GoRouter.of(context).go(ADMIN_SETTINGS);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Pickers & Search Button
            Row(
              children: [
                _buildDateSelector('Start Date', startDate, () => _selectDate(context, true)),
                const SizedBox(width: 10),
                _buildDateSelector('End Date', endDate, () => _selectDate(context, false)),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      billsFuture = _fetchBills();
                    });
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bill Table
            Expanded(
              child: FutureBuilder<List<BillDetail>?>(
                future: billsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No bills found for the selected date range'));
                  }

                  final bills = snapshot.data!;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      border: TableBorder.all(width: 1, color: Colors.grey),
                      columns: const [
                        DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Discount', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: bills.map((bill) {
                        return DataRow(cells: [
                          DataCell(Text(bill.id.toString())),
                          DataCell(Text(bill.username)),
                          DataCell(Text(bill.total.toStringAsFixed(2))),
                          DataCell(Text(bill.totalDiscount.toStringAsFixed(2))),
                          DataCell(Text(_formatDate(bill.createAt))),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20),
          const SizedBox(width: 5),
          Text('$label: ${DateFormat('yyyy-MM-dd').format(date)}'),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);
    } catch (e) {
      return dateStr;
    }
  }
}