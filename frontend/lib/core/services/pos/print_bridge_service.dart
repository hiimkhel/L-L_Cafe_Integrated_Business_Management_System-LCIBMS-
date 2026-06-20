import 'dart:convert';
import 'package:http/http.dart' as http;

class PrintBridgeService {
  static const String bridgeIp = '192.168.0.169';
  static const int port = 8080;

  static Future<bool> printReceipt(String receiptText) async {
    try {
      final uri = Uri.parse('http://$bridgeIp:$port/print');

      final response = await http
          .post(
            uri,
            headers: {
              "Content-Type": "text/plain",
              "Connection": "close",
              "Cache-Control": "no-cache",
            },
            body: utf8.encode(receiptText),
          )
          .timeout(const Duration(seconds: 5));

      print("STATUS: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("PRINT ERROR: $e");
      return false;
    }
  }
}