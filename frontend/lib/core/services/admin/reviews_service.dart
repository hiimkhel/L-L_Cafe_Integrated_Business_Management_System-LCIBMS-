import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/models/review_model.dart';

class ReviewService {
  static const baseUrl = 'http://localhost:3006/api/admin';

  static Future<List<ReviewModel>> fetchAll() async {
    final res = await http.get(Uri.parse('$baseUrl/reviews'));

    if (res.statusCode != 200) {
      throw Exception('Failed to load reviews');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => ReviewModel.fromJson(e)).toList();
  }

  static Future<void> publish(String id) async {
    await http.patch(Uri.parse('$baseUrl/reviews/$id/publish'));
  }

  static Future<void> archive(String id) async {
    await http.patch(Uri.parse('$baseUrl/reviews/$id/archive'));
  }

  static Future<void> delete(String id) async {
    await http.delete(Uri.parse('$baseUrl/reviews/$id'));
  }

  static Future<void> republish(String id) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/reviews/$id/republish'),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to republish review');
    }
  }
}