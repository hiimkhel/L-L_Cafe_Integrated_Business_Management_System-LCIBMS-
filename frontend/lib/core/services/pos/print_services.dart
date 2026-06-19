import 'package:flutter/foundation.dart';
import 'receipt_builder.dart';
import 'package:frontend/core/models/receipt_model.dart';
import 'thermal_receipt_formatter.dart';

class PrintService {
  static Future<void> printReceipt(ReceiptData data) async {
    // STEP 1: Convert UI model → printable string
    final receiptText = ThermalReceiptFormatter.build(
      storeName: "L&L CAFE",
      items: data.items.map((e) => {
        "name": e.displayName,
        "qty": e.quantity,
        "price": e.unitPrice,
      }).toList(),
      total: data.grandTotal,
      cashReceived: data.cashReceived,
      change: data.change
    );

    // STEP 2: SIMULATE PRINT OUTPUT (NO HARDWARE YET)
    debugPrint("🖨️ PRINTING RECEIPT START");
    debugPrint(receiptText);
    debugPrint("🖨️ PRINTING RECEIPT END");

    // STEP 3: Placeholder for future Bluetooth integration
    await Future.delayed(const Duration(milliseconds: 500));
  }
}