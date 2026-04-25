import 'dart:convert';
import 'package:http/http.dart' as http;

class MenuService {
  static const String baseUrl = "http://localhost:3006/api/admin";
  static String? token;
  
  // ---------------- CATEGORIES ----------------
  static Future<List<dynamic>> fetchCategories() async {
    final res = await http.get(Uri.parse('$baseUrl/menu/category'));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      // Error handling
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
      // Error handling
      throw Exception("Failed to load menu items");
    }
  }

  // Handle sending API for adding category
  static Future<void> addCategory(String name) async {
    final res = await http.post(
      Uri.parse('$baseUrl/menu/category'),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": name}),
    );

    // Error handling
    if (res.statusCode != 201) {
      throw Exception(res.body);
    }
  }

  // Handle sending API for adding item
  static Future<void> addItem(Map<String, dynamic> data) async{
    final res = await http.post(
      Uri.parse('$baseUrl/menu-items'),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );  


    // Error handling
    if (res.statusCode != 201){
      throw Exception(res.body);
    }
  }

  static Future<void> deleteMenuItem(int id) async{
    final res = await http.delete(Uri.parse('$baseUrl/menu-items/$id'),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

     // Error handling
    if (res.statusCode != 200 && res.statusCode != 204){
      throw Exception(res.body.isNotEmpty
        ? res.body
        : "Failed to delete item");
    }

  }

  // Fetch specific menu item by id 
  static Future<dynamic> fetchMenuItemById(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/menu-items/$id'),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load item");
    }
  }
}