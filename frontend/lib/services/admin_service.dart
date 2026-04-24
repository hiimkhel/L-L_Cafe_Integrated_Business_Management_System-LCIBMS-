import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  static const String baseUrl = "http://localhost:3006/api/admin";

  static Future<List<dynamic>> fetchAllCustomers({
    String search = "",
  }) async {
    final url = Uri.parse(
      "$baseUrl/customers?search=$search",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
    
      return data['data'];
    } else {
      throw Exception("Failed to load customers");
    }
  }
  
  
}
