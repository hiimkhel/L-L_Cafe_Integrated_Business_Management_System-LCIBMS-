import 'dart:convert';
import 'package:frontend/core/models/order_request.dart';
import 'package:http/http.dart' as http;

class OrderService {
  final String baseUrl = "http://localhost:3006/api";

  Future<bool> createOrder(OrderRequest order) async {
    final response = await http.post(
      Uri.parse("$baseUrl/orders/"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(order.toJson()),
    );

    if (response.statusCode == 200) {
      print(order);
      print(response);
      
      return true;
    } else {
      print(response.body);
      return false;
    }
  }

   Future<List<dynamic>> getCustomerOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/customer/orders"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${token.trim()}",
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        return data["orders"] ?? [];
      } else {
        print("Server Error: ${data['message']}");
        throw Exception(data["message"] ?? "Failed to fetch orders");
      }
    } catch (e) {
      print("OrderService Error: $e");
      rethrow;
    }
  }

 Future<void> cancelOrder(String token, String orderNumber) async {
  final url = '$baseUrl/customer/orders/$orderNumber/cancel';

  try {
    print("🚀 [CANCEL ORDER] Request starting...");
    print("🔗 URL: $url");
    print("🔑 Token: ${token.isNotEmpty ? "Present" : "MISSING"}");
    print("📦 Order Number: $orderNumber");

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${token.trim()}',
        'Content-Type': 'application/json',
      },
    );

    print("📡 [CANCEL ORDER] Response received");
    print("📊 Status Code: ${response.statusCode}");
    print("📄 Body: ${response.body}");

    // Try decoding safely
    try {
      final decoded = jsonDecode(response.body);
      print("🧠 Decoded Response: $decoded");
    } catch (e) {
      print("⚠️ JSON Decode Error: $e");
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Cancel failed | Status: ${response.statusCode} | Body: ${response.body}',
      );
    }

    print("✅ Order cancelled successfully");
  } catch (e) {
    print("❌ [CANCEL ORDER ERROR]: $e");
    rethrow;
  }
}
}