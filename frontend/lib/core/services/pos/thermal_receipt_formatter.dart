class ThermalReceiptFormatter {
  static const int lineWidth = 32;

  static String formatLine(String left, String right) {
    final space = lineWidth - left.length - right.length;

    if (space <= 0) {
      return left + ' ' + right; // fallback safe spacing
    }

    return left + (' ' * space) + right;
  }

  static String build({
    required String storeName,
    required List<Map<String, dynamic>> items,
    required double total,
    required double cashReceived,
    required double change,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(center(storeName.toUpperCase()));
    buffer.writeln(center("=============================="));
    buffer.writeln("");

    for (final item in items) {
      final name = item['name'].toString();
      final qty = item['qty'].toString();
      final price = "₱${item['price']}";

      final wrappedName = wrapText(name, 32);

      // NAME LINE
      buffer.writeln(wrappedName.first);

      // PRICE LINE (clean POS style)
      buffer.writeln(formatLine(
        "x$qty",
        price,
      ));

      // EXTRA WRAPPED LINES (indent only)
      for (int i = 1; i < wrappedName.length; i++) {
        buffer.writeln("  ${wrappedName[i]}");
      }

      buffer.writeln(""); // spacing between items
    }

    buffer.writeln("");
    buffer.writeln("------------------------------");

    buffer.writeln(formatLine("TOTAL", "₱${total.toStringAsFixed(2)}"));
    buffer.writeln(formatLine("CASH", "₱${cashReceived.toStringAsFixed(2)}"));
    buffer.writeln(formatLine("CHANGE", "₱${change.toStringAsFixed(2)}"));

    buffer.writeln("------------------------------");
    buffer.writeln(center("THANK YOU!"));
    buffer.writeln("");

    return buffer.toString();
  }

  // Utilities

  static String center(String text) {
    final spaces = (lineWidth - text.length) ~/ 2;
    return (' ' * (spaces > 0 ? spaces : 0)) + text;
  }

  static List<String> wrapText(String text, int maxWidth) {
    final words = text.split(' ');
    List<String> lines = [];
    String current = '';

    for (final word in words) {
      if ((current + word).length > maxWidth) {
        lines.add(current.trim());
        current = word + ' ';
      } else {
        current += word + ' ';
      }
    }

    if (current.isNotEmpty) {
      lines.add(current.trim());
    }

    return lines;
  }
}

