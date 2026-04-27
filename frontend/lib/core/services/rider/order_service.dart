import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService{
  final String baseUrl = "http://localhost:3006/api";

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
}