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
}