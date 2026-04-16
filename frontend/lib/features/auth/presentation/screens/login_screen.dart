import 'package:flutter/material.dart';
import '../../../../main.dart';
import 'package:frontend/core/models/user.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as fb;


class LoginScreen extends StatefulWidget {
  final Function(User) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';

  void _login() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  setState(() => error = '');

  try {
    // Firebase login
    final credential = await fb.FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user?.uid;

    if (uid == null) {
      setState(() {
        error = 'Failed to get user ID from Firebase';
      });
      return;
    }

    // Send UID to backend
    final response = await http.post(
      Uri.parse('http://localhost:3006/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firebase_uid': uid,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final user = User(
        data['email'] ?? email,
        '',
        stringToRole(data['role']),
      );

      widget.onLogin(user);
      Navigator.pop(context);
    } else {
      setState(() {
        error = data['message'] ?? 'Login failed';
      });
    }
  } catch (e) {
    setState(() {
      error = 'Invalid credentials or server error';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 8),
            Text(error, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}