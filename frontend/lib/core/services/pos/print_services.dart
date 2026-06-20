import 'package:frontend/core/models/receipt_model.dart';
import 'thermal_receipt_formatter.dart';
import 'print_bridge_service.dart';

class PrintService {
  static Future<bool> printReceipt(ReceiptData data) async {
    final receiptText = ThermalReceiptFormatter.build(
      storeName: "L&L CAFE",
      items: data.items.map((e) => {
        "name": e.name,
        "qty": e.quantity,
        "price": e.unitPrice,
      }).toList(),
      total: data.grandTotal,
      cashReceived: data.cashReceived,
      change: data.change,
    );

    print("🖨️ PRINT START");

    final result = await PrintBridgeService.printReceipt(receiptText);

    print("🖨️ PRINT RESULT: $result");

    return result;
  }
}