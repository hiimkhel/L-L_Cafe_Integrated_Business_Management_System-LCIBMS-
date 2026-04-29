import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/models/menu_item.dart';

class MenuService {
  // Replace with your actual base URL or environment variable
  static const String _baseUrl = 'http://localhost:3006/api/menu';

  static Future<List<MenuItem>> fetchMenu({String? category, String? search}) async {
    try {
      // 1. Construct query parameters
      // If category is 'ALL', we don't send it, letting the backend default to everything
      final Map<String, String> queryParameters = {};
      
      if (category != null && category != 'ALL') {
        queryParameters['category'] = category;
      }
      
      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }

      // 2. Build the URI for the / endpoint
      final uri = Uri.parse('$_baseUrl/').replace(queryParameters: queryParameters);

      // 3. Perform the GET request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MenuItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load menu: ${response.statusCode}');
      }
    } catch (e) {
      print('MenuService Error: $e');
      rethrow; 
    }
  }
}