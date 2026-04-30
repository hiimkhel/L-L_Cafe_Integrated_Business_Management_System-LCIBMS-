import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CmsService {
  static const baseUrl = "http://localhost:1337/api";

  static Future<List<dynamic>> getPromotions() async {
    final res = await http.get(Uri.parse('$baseUrl/promotions?populate=*'));

    final data = jsonDecode(res.body);
    return data['data'];
    
  }

  static String extractDescription(dynamic desc) {
    if (desc == null) return "";
    
    // Case 1: It's already a String
    if (desc is String) return desc;

    // Case 2: It's Strapi Blocks (List of Maps)
    try {
      if (desc is List && desc.isNotEmpty) {
        // Safely navigate the nested structure: desc[0] -> children[0] -> text
        final firstBlock = desc[0];
        if (firstBlock['children'] != null && firstBlock['children'] is List) {
          return firstBlock['children'][0]['text'] ?? "";
        }
      }
    } catch (e) {
      debugPrint("Extraction error: $e");
    }

    return "";
  }

 static Future<Map<String, dynamic>?> getPromotionByType(String type) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/promotions?filters[type][%24eq]=$type&populate=*"),
      );

      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      final List items = data['data'] ?? [];

      if (items.isEmpty) return null;

      // In Strapi 5, the object is flat. Just return the first item.
      return items[0] as Map<String, dynamic>;
    } catch (e) {
      debugPrint("getPromotionByType error: $e");
      return null;
    }
  }

  static Future<bool> publishPromotion(
    dynamic idOrDocId,
    Map<String, dynamic> data,
  ) async {
    try {
      // 1. Fixed URL (removed the extra /api)
      final url = Uri.parse("$baseUrl/promotions/$idOrDocId");

      debugPrint("Attempting PUT to: $url");
      
      final res = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "data": {
            ...data,
            // Note: Strapi 5 uses 'publishedAt' for publishing logic, 
            // but if you have a custom boolean field 'isPublished', keep this.
          }
        }),

       
      );

       if (res.statusCode == 200) {
          return true;
      } else {
        debugPrint("Update Failed Status: ${res.statusCode}");
        debugPrint("Update Failed Body: ${res.body}");
        return false;
      }
    } catch (e) {
      debugPrint("publishPromotion error: $e");
      return false;
    }
  }

  
}

