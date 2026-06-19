import 'package:flutter/services.dart';

class NativePrinterService {
  static const MethodChannel _channel =
      MethodChannel('lcibms/printer');

  static Future<void> printTest() async {
    final response =
        await _channel.invokeMethod('printTest');

    print(response);
  }
}