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

buffer.writeln(center("Cabaluna St., Alimodian, Iloilo"));
buffer.writeln(center("TEL: 09983087848"));

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
    buffer.writeln(rightAlign("CASH", "P${cashReceived.toStringAsFixed(2)}"));
    buffer.writeln(rightAlign("CHANGE", "P${change.toStringAsFixed(2)}"));

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

    // wrap name if too long
    final words = name.split(" ");
    List<String> lines = [];

    String currentLine = "";

    for (final word in words) {
      if ((currentLine + word).length > 18) {
        lines.add(currentLine.trim());
        currentLine = word + " ";
      } else {
        currentLine += "$word ";
      }
    }
    if (currentLine.isNotEmpty) {
      lines.add(currentLine.trim());
    }

    List<String> result = [];

    for (int i = 0; i < lines.length; i++) {
      if (i == 0) {
        result.add(
          "${qty.padRight(4)}${lines[i].padRight(18)}${amtStr.padLeft(10)}",
        );
      } else {
        result.add(
          "     ${lines[i]}",
        );
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