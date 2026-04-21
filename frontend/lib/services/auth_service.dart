import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../core/models/user.dart';

class AuthService{
  static const String baseUrl = "http://localhost:3006/api/auth";

  static Future<User> login(String email, String password) async {
    final credential = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    
    final uid = credential.user?.uid;

    if(uid == null){
      throw Exception("Failed to get Firebase UID");
    }

    // Backend Logic
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'firebase_uid': uid}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200){
      throw Exception(data['message'] ?? 'Login failed');
    }

    return User(
      data['email'],
      '',
      stringToRole(data['role']),
    );

  }

  static Future<User> register(String fullName, String email, String password) async {
    // Firebase register
    final credential = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

    final uid = credential.user?.uid;

     if (uid == null) {
      throw Exception('Failed to get Firebase UID');
    }

    // Backend register
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firebase_uid': uid,
        'full_name': fullName,
        'email': email,
      }),
    );
    
    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Register failed');
    }

     return User(
      email,
      '',
      stringToRole(data['role']),
    );

  }

}