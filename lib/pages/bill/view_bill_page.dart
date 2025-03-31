import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pharm/db/dto/bill_detail.dart';
import 'package:pharm/pages/bill/view_detail_bill.dart';
import 'package:pharm/provider/bill_item_provide.dart';

import '../../db/dto/bill_and_details.dart';
import '../../provider/bill_provider.dart';
import '../../provider/router_provider.dart';
import '../../service/detailed_report_generator.dart';
import '../../utill/download_confirmation_dialog.dart';

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
        title: const Text('Bill Management', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).go(ADMIN_SETTINGS),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // Filter Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Filter Bills',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end, // This is the key line
                          children: [
                            // Start Date
                            _buildStyledDateSelector(
                              context: context,
                              label: 'Start Date',
                              date: startDate,
                              onTap: () => _selectDate(context, true),
                            ),
                            const SizedBox(width: 24),

                            // End Date
                            _buildStyledDateSelector(
                              context: context,
                              label: 'End Date',
                              date: endDate,
                              onTap: () => _selectDate(context, false),
                            ),
                            const SizedBox(width: 24),

                            // Search Button
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: () {
                                  setState(() {
                                    billsFuture = _fetchBills();
                                  });
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.search, size: 20),
                                    SizedBox(width: 8),
                                    Text('Search', style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Results Section
                Expanded(
                  child: FutureBuilder<List<BillDetail>?>(
                    future: billsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load bills',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${snapshot.error}',
                                style: const TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long, color: Colors.grey.shade400, size: 48),
                              const SizedBox(height: 16),
                              const Text(
                                'No bills found',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your date range',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        );
                      }

                      final bills = snapshot.data!;
                      final totalSales = bills.fold(0.0, (sum, bill) => sum + bill.total+bill.totalDiscount);
                      final totalDiscounts = bills.fold(0.0, (sum, bill) => sum + bill.totalDiscount);
                      final netTotal = totalSales - totalDiscounts;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column - Bills Table
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                // Results Count
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${bills.length} ${bills.length == 1 ? 'bill' : 'bills'} found',
                                          style: TextStyle(
                                            color: Colors.blue.shade800,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Bills Table
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: DataTable(
                                              columnSpacing: 32,
                                              horizontalMargin: 16,
                                              headingRowHeight: 48,
                                              dataRowHeight: 56,
                                              headingTextStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade800,
                                                fontSize: 14,
                                              ),
                                              dataTextStyle: const TextStyle(fontSize: 14),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey.shade200),
                                              ),
                                              columns: const [
                                                DataColumn(label: Text('ID')),
                                                DataColumn(label: Text('User')),
                                                DataColumn(label: Text('Total'), numeric: true),
                                                DataColumn(label: Text('Discount'), numeric: true),
                                                DataColumn(label: Text('Date')),
                                                DataColumn(label: Text('Actions')),
                                              ],
                                              rows: bills.map((bill) {
                                                return DataRow(
                                                  cells: [
                                                    DataCell(Text('#${bill.id}')),
                                                    DataCell(Text(bill.username)),
                                                    DataCell(
                                                      Text(
                                                        '${bill.total.toStringAsFixed(2)} LKR',
                                                        style: TextStyle(
                                                          color: Colors.green.shade700,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        '${bill.totalDiscount.toStringAsFixed(2)} LKR',
                                                        style: TextStyle(
                                                          color: Colors.orange.shade700,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(Text(_formatDate(bill.createAt))),
                                                    DataCell(
                                                      Row(
                                                        children: [
                                                          _buildActionButton(
                                                            icon: Icons.visibility,
                                                            color: Colors.blue,
                                                            onPressed: () => _viewBillDetails(bill),
                                                            tooltip: 'View details',
                                                          ),
                                                          const SizedBox(width: 8),
                                                          _buildActionButton(
                                                            icon: Icons.delete,
                                                            color: Colors.red,
                                                            onPressed: () => _confirmDeleteBill(bill),
                                                            tooltip: 'Delete bill',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Right Column - Summary and Reports
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                // Summary Card
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sales Summary',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        _buildSummaryRow(
                                            'Total Sales',
                                            '${totalSales.toStringAsFixed(2)} LKR',
                                            Icons.attach_money,
                                            Colors.green
                                        ),
                                        const SizedBox(height: 12),
                                        _buildSummaryRow(
                                            'Total Discounts',
                                            '${totalDiscounts.toStringAsFixed(2)} LKR',
                                            Icons.discount,
                                            Colors.orange
                                        ),
                                        const SizedBox(height: 12),
                                        _buildSummaryRow(
                                            'Net Total',
                                            '${netTotal.toStringAsFixed(2)} LKR',
                                            Icons.account_balance_wallet,
                                            Colors.blue
                                        ),
                                        const SizedBox(height: 20),
                                        Divider(color: Colors.grey.shade300),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Date Range: ${_formatDate(startDate.toString())} to ${_formatDate(endDate.toString())}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Reports Card
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Generate Reports',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        // SizedBox(
                                        //   width: double.infinity,
                                        //   child: ElevatedButton.icon(
                                        //     onPressed: () => {},
                                        //     style: ElevatedButton.styleFrom(
                                        //       backgroundColor: Colors.blue.shade700,
                                        //       foregroundColor: Colors.white,
                                        //       padding: const EdgeInsets.symmetric(vertical: 16),
                                        //       shape: RoundedRectangleBorder(
                                        //         borderRadius: BorderRadius.circular(10),
                                        //       ),
                                        //     ),
                                        //     icon: const Icon(Icons.download),
                                        //     label: const Text('General Report'),
                                        //   ),
                                        // ),
                                        // const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () =>  downloadDetailReport(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue.shade700,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            icon: const Icon(Icons.download),
                                            label: const Text('Detailed Report'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> downloadDetailReport() async {
    // First await the billsFuture to get the actual list
    final List<BillDetail>? billsList = await billsFuture;

    if (billsList == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No bills data available')),
      );
      return;
    }

    List<BillAndDetails> bills = [];
    for (var bill in billsList) {
      final billItems = await ref.read(billItemProvider.notifier).getBillItemByBillId(bill.id);

      bills.add(BillAndDetails(
        billDetail: bill,
        billItems: billItems ?? [], // Provide empty list if null
      ));
    }

    String dateRange = '${_formatDate2(startDate.toString())}_${_formatDate2(endDate.toString())}';

    try {
      final invoiceFile = await DetailedReportGenerator.generateAndSaveInvoice(
        billAndDetails: bills,
        customFileName: dateRange,
      );

      await showDialog(
        context: context,
        builder: (context) => DownloadConfirmationDialog(
          filePath: invoiceFile.path,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

// Helper Widget for Summary Rows
  Widget _buildSummaryRow(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStyledDateSelector({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 180,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Select date',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null ? Colors.grey.shade800 : Colors.grey.shade500,
                  ),
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, size: 20, color: color),
          onPressed: onPressed,
          splashRadius: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }

  // Example methods you'll need to implement:
  void _viewBillDetails(BillDetail bill) {
    showDialog(
      context: context,
      builder: (context) => ViewBillDetailsDialog(bill: bill),
    );
  }

  void _confirmDeleteBill(BillDetail bill) {
    // Show a confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete bill #${bill.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBill(bill.id);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBill(int billId) async {
    // Implement bill deletion logic
    try {
      int r = await ref.read(billProvider.notifier).deleteBillByStatus(billId);
      setState(() {
        billsFuture = _fetchBills(); // Refresh the list
      });
     if(r>0) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Bill deleted successfully')),
       );
     }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete bill: $e')),
      );
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDate2(String dateStr) {
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return dateStr;
    }
  }
}