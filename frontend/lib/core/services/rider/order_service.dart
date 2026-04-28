import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService{
  final String baseUrl = "http://localhost:3006/api";

  // Call API endpoint for fetching all orders for delivery
  Future<List<dynamic>> getRiderOrders(String status) async {
    try {
      // Allow ready and out for delivery
      final response = await http.get(
        Uri.parse('$baseUrl/rider/orders?status=$status'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Error: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Service Error: $e");
      return [];
    }
  }

  // Call API endpoint for fetching order details of a delivery order
  Future<Map<String, dynamic>> fetchOrderDetails(int orderId) async{
    try {
      final response = await http.get(Uri.parse('$baseUrl/rider/orders/$orderId'));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['data'];
      } else {
        throw Exception('Failed to load order');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/rider/orders/$orderId/status'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode({
          "newStatus": newStatus, // e.g., 'out_for_delivery'
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorBody = json.decode(response.body);
        print("Update Failed: ${errorBody['message']}");
        return false;
      }
    } catch (e) {
      print("Network Error: $e");
      return false;
    }
  }
}