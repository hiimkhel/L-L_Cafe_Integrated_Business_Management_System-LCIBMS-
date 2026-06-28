import 'dart:convert';
import 'package:http/http.dart' as http;

class PrintBridgeService {
  static const String bridgeIp = '192.168.1.90';
  static const int port = 8080;

  static Future<bool> printReceipt(String text) async {
    try {
      final response = await http
          .post(
            Uri.parse('http://$bridgeIp:$port/print'),
            headers: {
              "Content-Type": "text/plain",
              "Connection": "close",
            },
            body: utf8.encode(text),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print("PRINT ERROR: $e");
      return false;
    }
  }
}