import 'package:flutter/material.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'package:frontend/core/models/user.dart';

class LandingScreen extends StatelessWidget {
  final Function(User) onLogin;

  const LandingScreen({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              'Welcome to L-L Cafe ☕',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(onLogin: onLogin),
                  ),
                );
              },
              child: const Text('Login'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // TODO: Register Screen
              },
              child: const Text('Register'),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                // Optional: allow browsing as guest
              },
              child: const Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}