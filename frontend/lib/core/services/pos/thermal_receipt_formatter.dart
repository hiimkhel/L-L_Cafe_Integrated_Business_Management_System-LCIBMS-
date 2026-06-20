class ThermalReceiptFormatter {
  static String build({
    required String storeName,
    required List<Map<String, dynamic>> items,
    required double total,
    required double cashReceived,
    required double change,
  }) {
    final buffer = StringBuffer();
    

    buffer.writeln("================================");
    buffer.writeln("        $storeName");
    buffer.writeln("================================");
    buffer.writeln("Date: ${DateTime.now()}");
    buffer.writeln("--------------------------------");

    for (final item in items) {
      final lineTotal = (item['qty'] * item['price']);

      buffer.writeln(
        "${item['name']} x${item['qty']}   P${lineTotal.toStringAsFixed(2)}",
      );
    }

   buffer.writeln("--------------------------------");

    buffer.writeln(
      rightAlign("TOTAL :", "P ${total.toStringAsFixed(2)}"),
    );

    buffer.writeln(
      rightAlign("CASH  :", "P ${cashReceived.toStringAsFixed(2)}"),
    );

    buffer.writeln(
      rightAlign("CHANGE:", "P ${change.toStringAsFixed(2)}"),
    );

    buffer.writeln("--------------------------------");

    buffer.writeln("");
    buffer.writeln(center("THANK YOU FOR ORDERING"));
    buffer.writeln(center("AT L&L CAFE"));
    buffer.writeln("");

    return buffer.toString();
  }
  static const int lineWidth = 32;

  static String rightAlign(String label, String value) {
    final space = lineWidth - label.length - value.length;
    return label + (' ' * (space > 0 ? space : 1)) + value;
  }

  static String center(String text) {
    final spaces = (lineWidth - text.length) ~/ 2;
    return (' ' * (spaces > 0 ? spaces : 0)) + text;
  }
}