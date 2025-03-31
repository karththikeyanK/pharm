import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/bill_item_helper.dart';
import '../../db/dto/bill_detail.dart';
import '../../db/dto/bill_item_detail.dart';
import '../../db/model/bill_item.dart';
import '../../provider/bill_item_provide.dart';
import '../../service/pdf_service.dart';
import '../../utill/download_confirmation_dialog.dart';

class ViewBillDetailsDialog extends ConsumerWidget {
  final BillDetail bill;

  const ViewBillDetailsDialog({super.key, required this.bill});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billItemsFuture = ref.read(billItemProvider.notifier).getBillItemByBillId(bill.id);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bill #${bill.id}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${bill.createAt}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Customer Info
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 24),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              bill.username,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(bill.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            bill.status,
                            style: TextStyle(
                              color: _getStatusColor(bill.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bill Items
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<BillItemDetail>?>(
                  future: billItemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(child: Text('Failed to load items'));
                    }

                    final items = snapshot.data!;
                    return _buildItemsTable(items);
                  },
                ),
                const SizedBox(height: 24),

                // Summary
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal', '${bill.total.toStringAsFixed(2)} LKR'),
                        const SizedBox(height: 8),
                        _buildSummaryRow('Discount', '-${bill.totalDiscount.toStringAsFixed(2)} LKR',
                            color: Colors.red),
                        const Divider(height: 24, thickness: 1),
                        _buildSummaryRow(
                          'Total',
                          '${(bill.total - bill.totalDiscount).toStringAsFixed(2)} LKR',
                          isBold: true,
                          fontSize: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Footer Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _printBill(context),
                      child: const Row(
                        children: [
                          Icon(Icons.print),
                          SizedBox(width: 8),
                          Text('Print'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      onPressed: () async {
                        final items = await BillItemHelper.instance.getByBillId(bill.id);
                        try {
                          final invoiceFile = await PdfService.generateAndSaveInvoice(
                            bill: bill,
                            items: items,
                            customFileName: 'Invoice_${bill.id}.pdf',
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
                      },
                      child: const Icon(Icons.download),
                      tooltip: 'Download Invoice',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsTable(List<BillItemDetail> items) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 16,
          headingRowHeight: 40,
          dataRowHeight: 48,
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
          columns: const [
            DataColumn(label: Text('Item')),
            DataColumn(label: Text('Qty'), numeric: true),
            DataColumn(label: Text('Unit Price'), numeric: true),
            DataColumn(label: Text('Dis/Per'), numeric: true),
            DataColumn(label: Text('Total'), numeric: true),
          ],
          rows: items.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item.stockName)),
                DataCell(Text(item.quantity.toString())),
                DataCell(Text('${item.unitSellPrice.toStringAsFixed(2)} LKR')),
                DataCell(Text(
                  '-${item.discount.toStringAsFixed(2)} LKR',
                  style: TextStyle(color: Colors.red.shade600),
                )),
                DataCell(Text(
                  '${item.totalCost.toStringAsFixed(2)} LKR',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {
    Color? color,
    bool isBold = false,
    double fontSize = 16,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _printBill(BuildContext context) {
    // Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Printing bill...')),
    );
  }
}


