import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/models/menu_item.dart';
import 'package:frontend/core/models/menu_category.dart';
import 'package:frontend/core/constants/api_configs.dart';
import 'package:frontend/core/models/menu_item_variant.dart';
import 'package:frontend/core/models/flavor_models.dart';

class MenuService {
  static String baseUrl = ApiConfig.baseUrl;

  static Future<List<MenuCategory>> fetchCategories() async {
    final res = await http.get(
      Uri.parse("$baseUrl/admin/menu/category"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load categories");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => MenuCategory.fromJson(e)).toList();
  }

  static Future<List<MenuItem>> fetchMenu() async {
    final res = await http.get(
      Uri.parse("$baseUrl/menu"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load menu");
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => MenuItem.fromJson(e)).toList();
  }

  static Future<int> fetchNextOrderNumber() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders/current-order-num'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['nextId'] as int;
      }
      return 1; // Fallback to 1
    } catch (e) {
      print("Error fetching order number: $e");
      return 1; 
    }
  }

  static Future<List<MenuItemVariant>> fetchVariants(
      int menuItemId,
  ) async {

    final res = await http.get(
      Uri.parse(
        "$baseUrl/menu/$menuItemId/variants",
      ),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load variants");
    }

    print("$baseUrl/menu/$menuItemId/variants");
    final List data = jsonDecode(res.body);

    return data
        .map((e) => MenuItemVariant.fromJson(e))
        .toList();
  }

  static Future<List<Flavor>> fetchFlavors(int menuItemId) async {
    final res = await http.get(
      Uri.parse(
        "$baseUrl/menu/$menuItemId/flavors",
      ),
    );

    print("$baseUrl/menu/$menuItemId/flavors");

    if (res.statusCode != 200) {
      throw Exception("Failed to load flavors!");
    }

    final List data = jsonDecode(res.body);

    return data
        .map((e) => Flavor.fromJson(e))
        .toList();
  }
}