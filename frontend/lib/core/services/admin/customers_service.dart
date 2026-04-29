import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomersService{
  static const baseUrl = "http://localhost:3006/api/admin";

  static Future<List<dynamic>> getCustomers({String search = ""}) async {
    final res = await http.get(
      Uri.parse("$baseUrl/customers?search=$search"),
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(body['message'] ?? "Error fetching customers");
    }

    return body['data'] ?? [];
  }
}