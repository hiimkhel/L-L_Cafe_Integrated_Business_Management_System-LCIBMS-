import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/models/menu_item.dart';

class MenuService {
  static const String baseUrl = "http://localhost:3006/api/menu";

  static Future<List<MenuItem>> fetchMenu() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode != 200) {
      throw Exception("Failed to load menu");
    }

    final List data = jsonDecode(response.body);

    return data.map((item) => MenuItem.fromJson(item)).toList();
  }
}