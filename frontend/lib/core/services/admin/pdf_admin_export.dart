import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PdfExportService {
  static Future<Uint8List> generateSalesReportPdf({
    required String range,
    required List<dynamic> topCustomers,
    required List<dynamic> topMenuItems,
    required Map<String, dynamic> revenueData,
    required Map<String, dynamic> ordersData,
    required Map<String, dynamic> salesData,
  }) async {

    final font = await PdfGoogleFonts.robotoRegular();
    final bold = await PdfGoogleFonts.robotoBold();

    final pdf = pw.Document();

    final sectionTitle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
    );

    final normal = pw.TextStyle(font: font, fontSize: 10);
    final titleStyle = pw.TextStyle(font: bold, fontSize: 20);

    

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),

        build: (context) => [
          // HEADER
          pw.Text('SALES & BUSINESS REPORT', style: titleStyle),
          pw.SizedBox(height: 6),
          pw.Text('Range: $range', style: normal),
          pw.Text(
            'Generated: ${DateTime.now()}',
            style: normal,
          ),

          pw.SizedBox(height: 20),
          pw.Divider(),

          // REVENUE
          pw.Text('Revenue Summary', style: sectionTitle),
          pw.SizedBox(height: 8),

          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: revenueData.entries.map((e) {
                final value = e.value.toString();

                return _statRow(
                  e.key.toString(),
                  value,
                  normal,
                );
              }).toList(),
            ),
          ),

          pw.SizedBox(height: 15),

          // ORDERS
          pw.Text('Orders Summary', style: sectionTitle),
          pw.SizedBox(height: 8),

          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: ordersData.entries.map((e) {
                return _statRow(
                  e.key.toString(),
                  e.value.toString(),
                  normal,
                );
              }).toList(),
            ),
          ),

          pw.SizedBox(height: 15),

          // SALES
          pw.Text('Sales Distribution', style: sectionTitle),
          pw.SizedBox(height: 8),

          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: salesData.entries.map((e) {
                return _statRow(
                  e.key.toString(),
                  e.value.toString(),
                  normal,
                );
              }).toList(),
            ),
          ),

          pw.SizedBox(height: 15),

          // TOP CUSTOMERS
          pw.Text('Top Customers', style: sectionTitle),
          pw.SizedBox(height: 8),

          pw.Table.fromTextArray(
            headers: ['Customer', 'Total Spent'],
            data: topCustomers.map((c) {
              return [
                c['customer_name'] ?? '',
                'PHP ${c['total_spent']}',
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 15),

          // TOP MENU ITEMS
          pw.Text('Top Menu Items', style: sectionTitle),
          pw.SizedBox(height: 8),

          pw.Table.fromTextArray(
            headers: ['Item', 'Units Sold'],
            data: topMenuItems.map((m) {
              return [
                m['name'] ?? '',
                m['total_sold'].toString(),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<void> printPdf(Uint8List pdfData) async {
    if (kIsWeb) {
      await Printing.layoutPdf(onLayout: (_) async => pdfData);
    } else {
      await Printing.sharePdf(
        bytes: pdfData,
        filename: 'sales_report.pdf',
      );
    }
  }
}

pw.Widget _statRow(String label, String value, pw.TextStyle style) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    margin: const pw.EdgeInsets.only(bottom: 4),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: style.copyWith(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          value,
          style: style,
        ),
      ],
    ),
  );
}

String _formatMoney(dynamic value) {
  final v = double.tryParse(value.toString()) ?? 0;
  return '₱${v.toStringAsFixed(2)}';
}