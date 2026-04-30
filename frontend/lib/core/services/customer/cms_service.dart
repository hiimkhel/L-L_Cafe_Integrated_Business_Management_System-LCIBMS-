import 'dart:convert';
import 'package:http/http.dart' as http;

class CmsService {
  static const baseUrl = "http://localhost:1337/api";

  static Future<List<dynamic>> getPromotions() async {
    final res = await http.get(Uri.parse('$baseUrl/promotions?populate=*'));

    final data = jsonDecode(res.body);
    return data['data'];
    
  }

  String extractDescription(dynamic desc) {
    try {
      return desc[0]['children'][0]['text'];
    } catch (e) {
      return "";
    }
  }
}

