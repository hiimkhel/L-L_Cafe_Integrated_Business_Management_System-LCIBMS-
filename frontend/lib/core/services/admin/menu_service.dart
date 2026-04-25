import 'dart:convert';
import 'package:http/http.dart' as http;

class MenuService {
  static const String baseUrl = "http://localhost:3006/api/admin";

  // ---------------- CATEGORIES ----------------
  static Future<List<dynamic>> fetchCategories() async {
    final res = await http.get(Uri.parse('$baseUrl/menu/category'));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load categories");
    }
  }

  // ---------------- MENU ITEMS ----------------
  static Future<List<dynamic>> fetchMenuItems(int categoryId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/menu-items?category_id=$categoryId'),
    );  

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load menu items");
    }
  }
}