import 'dart:core';

class ThermalReceiptFormatter {
  static const int lineWidth = 32;

  static String build({
    required String storeName,
    required List<Map<String, dynamic>> items,
    required double total,
    required double cashReceived,
    required double change,
  }) {
    final buffer = StringBuffer();

/// HEADER
buffer.writeln("================================");
buffer.writeln(center(storeName));
buffer.writeln(center("Making good food"));
buffer.writeln(center("for people's happiness"));
buffer.writeln("");
buffer.writeln(center("Cabaluna St., Alimodian, Iloilo"));
buffer.writeln(center("Tel: 09983087848"));

buffer.writeln("================================");
buffer.writeln(_dateLine());
buffer.writeln("--------------------------------");
    // COLUMN HEADER
buffer.writeln(_headerRow());
buffer.writeln("--------------------------------");

    // ITEMS
    for (final item in items) {
      for (final line in _formatItem(item)) {
        buffer.writeln(line);
      }
    }



    buffer.writeln("--------------------------------");

    // SUMMARY (IMPORTANT: TOTAL FIRST)
    buffer.writeln(_boldRow("TOTAL", "P${total.toStringAsFixed(2)}"));
    buffer.writeln(_boldRow("CASH", "P${cashReceived.toStringAsFixed(2)}"));
    buffer.writeln(_boldRow("CHANGE", "P${change.toStringAsFixed(2)}"));

    buffer.writeln("--------------------------------");

    // FOOTER
    buffer.writeln(center("THANK YOU FOR ORDERING"));
    buffer.writeln(center("AT L&L CAFE"));
    buffer.writeln("\n\n");

    return buffer.toString();
  }

  // ─────────────────────────────
  // HEADER ROW (QTY | NAME | AMT)
  // ─────────────────────────────
  static String _headerRow() {
    return "QTY  NAME                  AMT";
  }

  // ─────────────────────────────
  // ITEM FORMAT (NO TRUNCATION)
  // ─────────────────────────────
  static List<String> _formatItem(Map<String, dynamic> item) {
    final qty = item['qty'].toString();
    final name = item['name'].toString();
    final price = (item['price'] as num).toDouble();
    final amt = price * (item['qty'] as num);

    final amtStr = "P${amt.toStringAsFixed(2)}";

    // Wrap item name (18 chars reserved for name)
    final words = name.split(" ");

    List<String> lines = [];
    String current = "";

    for (final word in words) {
      if ((current + word).length > 18) {
        lines.add(current.trim());
        current = "$word ";
      } else {
        current += "$word ";
      }
    }

    if (current.isNotEmpty) {
      lines.add(current.trim());
    }

    final result = <String>[];

    // First line contains qty + amount
    result.add(
      "${qty.padRight(4)}${lines.first.padRight(18)}${amtStr.padLeft(10)}",
    );

    // Remaining wrapped lines
    for (int i = 1; i < lines.length; i++) {
      result.add("     ${lines[i]}");
    }

    // Variant
    final variantCategory = item["variant_category"];
    final variantName = item["variant_name"];

    if (variantCategory != null &&
        variantName != null &&
        variantName.toString().isNotEmpty) {
      result.add("     $variantCategory: $variantName");
    }

    // Flavors
    final flavors = item["flavors"];

    if (flavors is List && flavors.isNotEmpty) {
      result.add("     Flavors:");

      for (final flavor in flavors) {
        result.add("      > $flavor");
      }
    }

    return result;
  }

  // ─────────────────────────────
  // SUMMARY ROWS
  // ─────────────────────────────
  static String _boldRow(String label, String value) {
    // ESC/POS bold (basic simulation using caps)
    return "$label".padRight(10) + value.padLeft(lineWidth - 10);
  }

  static String rightAlign(String label, String value) {
    final text = "$label".padRight(10) + value;
    if (text.length >= lineWidth) return text;
    return text + (" " * (lineWidth - text.length));
  }

  // ─────────────────────────────
  // CENTER
  // ─────────────────────────────
  static String center(String text) {
    if (text.length >= lineWidth) return text;
    final spaces = (lineWidth - text.length) ~/ 2;
    return (" " * spaces) + text;
  }

  // ─────────────────────────────
  // DATE
  // ─────────────────────────────
  static String _dateLine() {
    final now = DateTime.now();
    return "Date: ${now.month}/${now.day}/${now.year} "
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}";
  }
}