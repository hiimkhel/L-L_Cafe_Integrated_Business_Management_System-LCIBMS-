import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../models/user.dart';

class AuthService {
  static const String baseUrl = "http://localhost:3006/api/auth";

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? currentUser;
  Future<User> _authenticateWithBackend(String endpoint, {String? fullName} ) async {
    final fb.User? firebaseUser = _auth.currentUser;

    final body = {
      "fullName": fullName,
    };

    if (firebaseUser == null) {
      throw Exception("No authenticated Firebase user");
    }

    final idToken = await firebaseUser.getIdToken();


    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Authentication failed');
    }

    final user = User(
      data['id'].toString(),
      data['email'],
      stringToRole(data['role']),
      data['token'] ?? '',
    );

    currentUser = user;
    return user;
  }

  ///  Email Login
  Future<User> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);

    return _authenticateWithBackend("authSync");
  }

  ///  Email Register
  Future<User> register(String fullName, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(fullName);

    return _authenticateWithBackend("authSync", fullName: fullName);
  }

  ///  Google Sign-In
  Future<User> signInWithGoogle() async {
    try {
      final googleProvider = fb.GoogleAuthProvider();

      final userCredential = await fb.FirebaseAuth.instance.signInWithPopup(
        googleProvider,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception("Google sign-in failed");
      }

      return await _authenticateWithBackend("authSync");
    } catch (e) {
      throw Exception("Google Sign-In Error: $e");
    }
  }

  Future<User> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) {
        throw Exception("Facebook login failed");
      }

      final accessToken = result.accessToken!;

      final credential = fb.FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      final userCredential = await fb.FirebaseAuth.instance
          .signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) {
        throw Exception("Firebase Facebook auth failed");
      }

      return await _authenticateWithBackend("authSync");
    } catch (e) {
      throw Exception("Facebook Sign-In Error: $e");
    }
  }

  // Get user Id 
  Future<String?> getUid() async {
    final user = _auth.currentUser;
    print(user?.uid);
    return user?.uid;

  }

  Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  int? getMySqlUserId() {
    return currentUser?.mysqlId;
  }
  ///  Logout
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
