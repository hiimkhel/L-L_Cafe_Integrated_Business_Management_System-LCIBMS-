import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:frontend/core/models/review_model.dart';



class ReviewService{

  static const String baseUrl = 'http://localhost:3006/api';
  static Future<List<ReviewModel>> fetchPublicReviews() async {
    final res = await http.get(
      Uri.parse('$baseUrl/reviews/public'),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load public reviews');
    }

    final List data = jsonDecode(res.body);

    return data
        .map((e) => ReviewModel.fromJson(e))
        .toList();
  }
}

