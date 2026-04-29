import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  static const String baseUrl = "http://localhost:3006/api/customer";

  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    // 🔥 force fresh Firebase ID token
    final token = await user.getIdToken(true);

    final response = await http.put(
      Uri.parse('$baseUrl/profile'), // cleaner endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "full_name": fullName,
        "phone": phone,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? "Failed to update profile");
    }

    return data; // return updated user
  }
}