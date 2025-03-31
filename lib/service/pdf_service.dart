import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../db/dto/bill_detail.dart';
import '../db/dto/bill_item_detail.dart';
import '../db/model/bill_item.dart';

class PdfService {
  static Future<XFile> generateAndSaveInvoice({
    required BillDetail bill,
    required List<BillItemDetail> items,
    String? customFileName,
  }) async {
    // Generate PDF
    final pdf = pw.Document();
    pdf.addPage(_buildPdfPage(bill, items));
    final bytes = await pdf.save();

    // Get save location
    final directory = await _getSaveDirectory();
    final fileName = customFileName ?? 'Invoice_${bill.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$fileName');

    // Save file
    await file.writeAsBytes(bytes);
    return XFile(file.path);
  }


  static pw.Page _buildPdfPage(BillDetail bill, List<BillItemDetail> items) {
    final netTotal = bill.total - bill.totalDiscount;

    return pw.MultiPage( // Changed from Page to MultiPage
      pageFormat: PdfPageFormat.a4,
      header: (pw.Context context) {
        if (context.pageNumber == 1) {
          return pw.Column(
            children: [
              // Shop Header (only on first page)
              pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Prime Care Pharmacy',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Sarayady, PointPedro', style: pw.TextStyle(fontSize: 14)),
                      pw.Text('Phone: +94 76 607 4582', style: pw.TextStyle(fontSize: 14)),
                      pw.Divider(thickness: 2),
                    ],
                  ),
              ),
              // Invoice Title
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Report generated on: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text('INVOICE',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),
              // Invoice Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice #: ${bill.id}'),
                      pw.Text('Date: ${formatDateTime(bill.createAt)}'),
                      pw.Text('User : ${bill.username}'),
                    ],
                  ),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(_getStatusColor(bill.status).value),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      bill.status,
                      style: pw.TextStyle(color: PdfColors.white),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Text('Items:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
            ],
          );
        }
        return pw.SizedBox(height: 20); // Minimal header for subsequent pages
      },
      footer: (pw.Context context) {
        if (context.pageNumber == context.pagesCount) {
          return pw.Column(
            children: [
              // Summary (only on last page)
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 200,
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Subtotal:'),
                          pw.Text('${bill.total.toStringAsFixed(2)} LKR'),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Discount:'),
                          pw.Text('-${bill.totalDiscount.toStringAsFixed(2)} LKR'),
                        ],
                      ),
                      pw.Divider(),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('TOTAL:',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('${netTotal.toStringAsFixed(2)} LKR',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('Thank you for your business!',
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
              ),
            ],
          );
        }
        return pw.Container(); // Empty footer for non-last pages
      },
      build: (pw.Context context) => [
        // The table will automatically span pages as needed
        createTable(items),
      ],
    );
  }


  static pw.Table createTable(List<BillItemDetail> items){
    return   pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Table Header
        pw.TableRow(
          children: [
            pw.Padding(
              child: pw.Text('Item',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              padding: const pw.EdgeInsets.all(4),
            ),
            pw.Padding(
              child: pw.Text('Qty',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              padding: const pw.EdgeInsets.all(4),
            ),
            pw.Padding(
              child: pw.Text('Unit Price',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              padding: const pw.EdgeInsets.all(4),
            ),
            pw.Padding(
              child: pw.Text('Dis/Per',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              padding: const pw.EdgeInsets.all(4),
            ),
            pw.Padding(
              child: pw.Text('Total',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              padding: const pw.EdgeInsets.all(4),
            ),
          ],
        ),
        // Table Rows
        ...items!.map((item) => pw.TableRow(
          children: [
            pw.Padding(
              child: pw.Text(item.stockName),
              padding: const pw.EdgeInsets.all(4),
            ),
            pw.Padding(
              child: pw.Text(item.quantity.toString()),
              padding: const pw.EdgeInsets.all(4),
            ),
            pw.Padding(
              child: pw.Text('${item.unitSellPrice.toStringAsFixed(2)} LKR'),
              padding: const pw.EdgeInsets.all(4),
            ),
            pw.Padding(
              child: pw.Text('-${item.discount.toStringAsFixed(2)} LKR'),
              padding: const pw.EdgeInsets.all(4),
            ),
            pw.Padding(
              child: pw.Text('${item.totalCost.toStringAsFixed(2)} LKR'),
              padding: const pw.EdgeInsets.all(4),
            ),
          ],
        )).toList(),
      ],
    );
  }
  static Future<Directory> _getSaveDirectory() async {
    Directory directory;
    if (Platform.isWindows) {
      directory = Directory('${Platform.environment['USERPROFILE']}\\Documents\\Pharm\\Bills');
    } else {
      directory = Directory('${Platform.environment['HOME']}/Documents/Pharm/Bills');
    }

    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return directory;
  }

  static Future<void> openFileExplorer(String path) async {
    final directory = File(path).parent;
    if (Platform.isWindows) {
      await Process.run('explorer', [directory.path]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [directory.path]);
    } else {
      await Process.run('xdg-open', [directory.path]);
    }
  }

  static Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'DELETED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


  static String formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final formatter = DateFormat('dd/MM/yyyy HH:mm a');
    return formatter.format(dateTime);
  }
}