class ReceiptBuilder {
  static String buildReceipt({
    required String storeName,
    required List<Map<String, dynamic>> items,
    required double total,
    required double cashReceived,
    required double change,
    String? cashier,

  }) {
    final buffer = StringBuffer();

    buffer.writeln("================================");
    buffer.writeln("        $storeName");
    buffer.writeln("================================");
    buffer.writeln("Date: ${DateTime.now()}");
    buffer.writeln("--------------------------------");

    for (final item in items) {
      buffer.writeln(
        "${item['name']} x${item['qty']}   ₱${item['price']}",
      );
    }

    buffer.writeln("--------------------------------");
    buffer.writeln("CASH: ₱${cashReceived.toStringAsFixed(2)}");
      buffer.writeln("CHANGE: ₱${change.toStringAsFixed(2)}");
    buffer.writeln("TOTAL: ₱$total");
    buffer.writeln("--------------------------------");

    if (cashier != null) {
      buffer.writeln("Cashier: $cashier");
    }

    buffer.writeln("Thank you, come again!");
    buffer.writeln("================================");

    return buffer.toString();
  }
}