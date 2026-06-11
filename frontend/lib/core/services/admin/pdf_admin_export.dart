import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class PdfExportService {



  static const PdfColor primaryColor = PdfColor.fromInt(0xFF1E293B); // Slate 800
  static const PdfColor secondaryColor = PdfColor.fromInt(0xFF0EA5E9); // Sky 500
  static const PdfColor textMain = PdfColor.fromInt(0xFF334155); // Slate 700
  static const PdfColor textMuted = PdfColor.fromInt(0xFF64748B); // Slate 500
  static const PdfColor bgLight = PdfColor.fromInt(0xFFF8FAFC); // Slate 50
  static const PdfColor borderLight = PdfColor.fromInt(0xFFE2E8F0); // Slate 200

  static Future<Uint8List> generateSalesReportPdf({
    required String range,
    required List<dynamic> topCustomers,
    required List<dynamic> topMenuItems,
    required Map<String, dynamic> revenueData,
    required Map<String, dynamic> ordersData,
    required Map<String, dynamic> salesData,
  }) async {
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final pdf = pw.Document();

    // TYPOGRAPHY SCHEME
    final titleStyle = pw.TextStyle(font: fontBold, fontSize: 22, color: primaryColor);
    final subtitleStyle = pw.TextStyle(font: fontRegular, fontSize: 10, color: textMuted);
    final h2Style = pw.TextStyle(font: fontBold, fontSize: 14, color: primaryColor);
    final bodyStyle = pw.TextStyle(font: fontRegular, fontSize: 10, color: textMain);
    final bodyBold = pw.TextStyle(font: fontBold, fontSize: 10, color: textMain);
    final tableHeaderStyle = pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        
        // REUSABLE HEADER & FOOTER ON EVERY PAGE
        header: (context) => _buildHeader(range, titleStyle, subtitleStyle),
        footer: (context) => _buildFooter(context, subtitleStyle),
        
        build: (context) => [
          pw.SizedBox(height: 10),

          // SECTION 1: FINANCIAL & ORDER SUMMARY (KPI GRID)
          _buildSectionHeading('Performance Overviews', h2Style),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _buildKpiCard('Revenue Breakdown', revenueData, bodyStyle, bodyBold, isCurrency: true),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildKpiCard('Orders Analytics', ordersData, bodyStyle, bodyBold),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // SECTION 2: SALES DISTRIBUTION
          _buildSectionHeading('Sales Distribution', h2Style),
          pw.SizedBox(height: 8),
          _buildKpiCard('Channels & Operations', salesData, bodyStyle, bodyBold),

          pw.SizedBox(height: 25),

          // SECTION 3: TOP CUSTOMERS TABLE
          _buildSectionHeading('Top Performing Customers', h2Style),
          pw.SizedBox(height: 8),
          _buildCustomersTable(topCustomers, tableHeaderStyle, bodyStyle),

          pw.SizedBox(height: 25),

          // SECTION 4: TOP MENU ITEMS TABLE
          _buildSectionHeading('Top Menu Items by Volume', h2Style),
          pw.SizedBox(height: 8),
          _buildMenuItemsTable(topMenuItems, tableHeaderStyle, bodyStyle),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String range, pw.TextStyle titleStyle, pw.TextStyle subtitleStyle) {
    final formattedDate = DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now());
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('L&L CAFE SALES & BUSINESS REPORT', style: titleStyle),
                pw.SizedBox(height: 4),
                pw.Text('Reporting Period: $range', style: subtitleStyle.copyWith(fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Text('Generated: $formattedDate', style: subtitleStyle),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(height: 2, color: secondaryColor),
        pw.SizedBox(height: 15),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.TextStyle style) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 10),
        pw.Container(height: 0.5, color: borderLight),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Confidential - Internal Business Intelligence', style: style),
            pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: style),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSectionHeading(String title, pw.TextStyle style) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title.toUpperCase(), style: style.copyWith(letterSpacing: 0.5, fontSize: 11)),
        pw.SizedBox(height: 2),
        pw.Container(width: 30, height: 2, color: secondaryColor),
      ],
    );
  }

  static pw.Widget _buildKpiCard(
    String title, 
    Map<String, dynamic> data, 
    pw.TextStyle bodyStyle, 
    pw.TextStyle boldStyle, 
    {bool isCurrency = false}
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: bgLight,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: borderLight, width: 1),
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: boldStyle.copyWith(color: primaryColor, fontSize: 11)),
          pw.SizedBox(height: 6),
          pw.Container(height: 1, color: borderLight),
          pw.SizedBox(height: 6),
          ...data.entries
            .where((e) => e.key != 'is_all_time' && e.key != 'monthly_target')
            .map((e) {

              String valueStr;

              if (e.key == 'growth_rate' ||
                  e.key == 'order_growth') {

                final value =
                    double.tryParse(e.value.toString()) ?? 0;

                valueStr =
                    '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}%';

              } else if (isCurrency) {

                valueStr = _formatMoney(e.value);

              } else {

                valueStr = e.value.toString();

              }

              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                child: pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      _formatLabel(e.key),
                      style: bodyStyle,
                    ),
                    pw.Text(
                      valueStr,
                      style: boldStyle,
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomersTable(List<dynamic> items, pw.TextStyle headerStyle, pw.TextStyle bodyStyle) {
    return pw.Table(
      border: pw.TableBorder.all(color: borderLight, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: primaryColor),
          children: [
            _tableCell('Customer Name', headerStyle, isHeader: true),
            _tableCell('Total Spent', headerStyle, isHeader: true, alignRight: true),
          ],
        ),
        // Rows
        ...items.map((c) {
          return pw.TableRow(
            children: [
              _tableCell(c['customer_name'] ?? 'N/A', bodyStyle),
              _tableCell(_formatMoney(c['total_spent']), bodyStyle, alignRight: true),
            ],
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildMenuItemsTable(List<dynamic> items, pw.TextStyle headerStyle, pw.TextStyle bodyStyle) {
    return pw.Table(
      border: pw.TableBorder.all(color: borderLight, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: primaryColor),
          children: [
            _tableCell('Menu Item', headerStyle, isHeader: true),
            _tableCell('Units Sold', headerStyle, isHeader: true, alignRight: true),
          ],
        ),
        // Rows
        ...items.map((m) {
          return pw.TableRow(
            children: [
              _tableCell(m['name'] ?? 'N/A', bodyStyle),
              _tableCell(m['total_sold']?.toString() ?? '0', bodyStyle, alignRight: true),
            ],
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _tableCell(String text, pw.TextStyle style, {bool isHeader = false, bool alignRight = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: isHeader ? 6 : 8),
      child: pw.Text(
        text,
        style: style,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

  // --- UTILITIES ---

  static String _formatLabel(String key) {
    if (key.isEmpty) return '';
    final result = key.replaceAll(RegExp(r'(_|- )'), ' ');
    return result.split(' ').map((str) {
      if(str.isEmpty) return '';
      return str[0].toUpperCase() + str.substring(1);
    }).join(' ');
  }

  static String _formatMoney(dynamic value) {
    final v = double.tryParse(value.toString()) ?? 0.0;
    return '₱${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  static Future<void> printPdf(Uint8List pdfData) async {
    if (kIsWeb) {
      await Printing.layoutPdf(onLayout: (_) async => pdfData);
    } else {
      await Printing.sharePdf(
        bytes: pdfData,
        filename: 'sales_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    }
  }
}