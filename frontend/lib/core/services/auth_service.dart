import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../core/models/user.dart';

class AuthService {
  static const String baseUrl = "http://localhost:3006/api/auth";

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<User> _authenticateWithBackend(String endpoint) async {
    final fb.User? firebaseUser = _auth.currentUser;

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
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Authentication failed');
    }

    return User(
      data['email'],
      '',
      stringToRole(data['role']),
    );
  }

  ///  Email Login
  Future<User> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return _authenticateWithBackend("");
  }

  ///  Email Register
  Future<User> register(String fullName, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(fullName);

    return _authenticateWithBackend("");
  }

  ///  Google Sign-In
 Future<User> signInWithGoogle() async {
    try {
      final googleProvider = fb.GoogleAuthProvider();

      final userCredential =
          await fb.FirebaseAuth.instance.signInWithPopup(googleProvider);

      final user = userCredential.user;

      if (user == null) {
        throw Exception("Google sign-in failed");
      }

      return await _authenticateWithBackend("");
      
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

      final userCredential =
          await fb.FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) {
        throw Exception("Firebase Facebook auth failed");
      }

      return await _authenticateWithBackend("");

    } catch (e) {
      throw Exception("Facebook Sign-In Error: $e");
    }
  }

  ///  Logout
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}