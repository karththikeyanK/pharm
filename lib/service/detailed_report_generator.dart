import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pharm/db/dto/bill_and_details.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../db/dto/bill_detail.dart';

class DetailedReportGenerator {
  static Future<XFile> generateAndSaveInvoice({
    required List<BillAndDetails> billAndDetails,
    required String customFileName,
  }) async {
    // Generate PDF using MultiPage approach
    final pdf = pw.Document();
    pdf.addPage(_buildPdfPage(billAndDetails, customFileName));
    final bytes = await pdf.save();

    // Get save location
    final directory = await _getSaveDirectory();
    final fileName = customFileName;
    final file = File('${directory.path}/$fileName');

    // Save file
    await file.writeAsBytes(bytes);
    return XFile(file.path);
  }

  static Future<Directory> _getSaveDirectory() async {
    Directory directory;
    if (Platform.isWindows) {
      directory = Directory(
        '${Platform.environment['USERPROFILE']}\\Documents\\Pharm\\DetailedReports',
      );
    } else {
      directory = Directory(
        '${Platform.environment['HOME']}/Documents/Pharm/DetailedReports',
      );
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

  static String formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final formatter = DateFormat('dd/MM/yyyy HH:mm a');
    return formatter.format(dateTime);
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      children: [
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
              pw.Text(
                'Sarayady, PointPedro',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                'Phone: +94 76 607 4582',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 2),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.MultiPage _buildPdfPage(
    List<BillAndDetails> billAndDetails,
    String dateRange,
  ) {
    double totalAmount = 0;
    double totalDiscount = 0;
    List<BillDetail> billDetails =
        billAndDetails.map((bill) => bill.billDetail).toList();
    billAndDetails.forEach((bill) {
      totalAmount += bill.billDetail.total;
      totalDiscount += bill.billDetail.totalDiscount;
    });
    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          // Header Section (appears only once at the top)
          _buildHeader(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Report generated on: ${formatDateTime(DateTime.now().toString())}',
                style: pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              'DETAILED REPORT - $dateRange',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 16),
          // Summary Section
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.5, color: PdfColors.blue400),
              borderRadius: pw.BorderRadius.circular(6),
              color: PdfColors.blue50,
            ),
            padding: pw.EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            margin: pw.EdgeInsets.only(bottom: 20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      "SUMMARY REPORT",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                  ],
                ),
                pw.Divider(
                  height: 16,
                  thickness: 0.5,
                  color: PdfColors.blue200,
                ),

                // Stats in a nicely spaced layout
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Total Bills",
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.Text(
                          billAndDetails.length.toString(),
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          "Total Amount",
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.Text(
                          "${totalAmount.toStringAsFixed(2)} LKR",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green700,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          "Total Discount",
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.Text(
                          "${totalDiscount.toStringAsFixed(2)} LKR",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bills Section
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
            columnWidths: {
              0: pw.FlexColumnWidth(1.5), // ID
              1: pw.FlexColumnWidth(3), // User
              2: pw.FlexColumnWidth(2), // Date
              3: pw.FlexColumnWidth(2), // Total
              4: pw.FlexColumnWidth(2), // Discount
              5: pw.FlexColumnWidth(2), // Status
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children:
                    ['Bill ID', 'User', 'Date', 'Total', 'Dis/Per', 'Status']
                        .map(
                          (text) => pw.Padding(
                            padding: pw.EdgeInsets.all(6),
                            child: pw.Text(
                              text,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
          ...billDetails.expand((billD) => [_buildBillSummary(billD)]),
          pw.SizedBox(height: 16),
          ...billAndDetails.expand((bill) => _buildBillWithItems(bill)),
        ];
      },
    );
  }

  // Summary table for bills
  static pw.Widget _buildBillSummary(BillDetail bill) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
      columnWidths: {
        0: pw.FlexColumnWidth(1.5), // ID
        1: pw.FlexColumnWidth(3), // User
        2: pw.FlexColumnWidth(2), // Date
        3: pw.FlexColumnWidth(2), // Total
        4: pw.FlexColumnWidth(2), // Discount
        5: pw.FlexColumnWidth(2), // Status
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.2)),
          ),
          children:
              [
                    bill.id.toString(),
                    bill.username,
                    formatDateTime(bill.createAt),
                    '${bill.total.toStringAsFixed(2)} LKR',
                    '${bill.totalDiscount.toStringAsFixed(2)} LKR',
                    bill.status,
                  ]
                  .map(
                    (text) => pw.Padding(
                      padding: pw.EdgeInsets.all(6),
                      child: pw.Text(text, style: pw.TextStyle(fontSize: 10)),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  // Build a complete bill section with its items
  static List<pw.Widget> _buildBillWithItems(BillAndDetails bill) {
    return [
      // Bill information section
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 0.5, color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(4),
          color: PdfColors.grey50,
        ),
        padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: pw.EdgeInsets.only(bottom: 8), // Reduced space between bills
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // First row - Bill ID and Status
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Bill #${bill.billDetail.id}",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: _getStatusColor(bill.billDetail.status),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: pw.Text(
                    bill.billDetail.status,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ],
            ),

            // Second row - Customer and Date (smaller font)
            pw.Text(
              "User : ${bill.billDetail.username}   -   ${formatDateTime(bill.billDetail.createAt)}",
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),

            // Third row - Amounts in compact format
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Total: ${bill.billDetail.total.toStringAsFixed(2)} LKR",
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  "Discount: ${bill.billDetail.totalDiscount.toStringAsFixed(2)} LKR",
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 16),

      // Items table with bill ID in header
      pw.Table(
        border: pw.TableBorder.all(width: 0.5),
        children: [
          // Table header with bill ID
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey200),
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text(
                  "Items for Bill #${bill.billDetail.id}",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          // Column headers
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey100),
            children:
                ["Item", "Qty", "Unit Price", "Discount", "Total"]
                    .map(
                      (text) => pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          text,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          // Items rows
          ...bill.billItems
              .map(
                (item) => pw.TableRow(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.2)),
                  ),
                  children:
                      [
                            item.stockName,
                            item.quantity.toString(),
                            "${item.unitSellPrice.toStringAsFixed(2)} LKR",
                            "${item.discount.toStringAsFixed(2)} LKR",
                            "${item.totalCost.toStringAsFixed(2)} LKR",
                          ]
                          .map(
                            (text) => pw.Padding(
                              padding: pw.EdgeInsets.all(6),
                              child: pw.Text(
                                text,
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                          )
                          .toList(),
                ),
              )
              .toList(),
        ],
        columnWidths: {
          0: pw.FlexColumnWidth(3),
          1: pw.FlexColumnWidth(1),
          2: pw.FlexColumnWidth(1.5),
          3: pw.FlexColumnWidth(1.5),
          4: pw.FlexColumnWidth(1.5),
        },
      ),

      // Space between bills
      pw.SizedBox(height: 24),
      pw.Divider(thickness: 1),
      pw.SizedBox(height: 24),
    ];
  }

  static PdfColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ACTIVE': return PdfColors.green;
      case 'pending': return PdfColors.orange;
      case 'DELETED': return PdfColors.red;
      default: return PdfColors.blue;
    }
  }
}
