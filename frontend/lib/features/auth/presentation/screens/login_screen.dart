import 'package:flutter/material.dart';
import 'package:frontend/core/models/user.dart';
import 'package:frontend/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(User) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  String error = '';
  bool isLoading = false;

  /// 📧 Email Login
  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      error = '';
      isLoading = true;
    });

    try {
      final user = await _authService.login(email, password);

      widget.onLogin(user);
      Navigator.pop(context);
    } catch (err) {
      setState(() {
        error = err.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 🔵 Google Login
  void _googleLogin() async {
    setState(() {
      error = '';
      isLoading = true;
    });

    try {
      final user = await _authService.signInWithGoogle();

      widget.onLogin(user);
      Navigator.pop(context);
    } catch (err) {
      setState(() {
        error = err.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => isLoading = false);
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
              onPressed: isLoading ? null : _login,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),

            const SizedBox(height: 16),
          
            /// Divider
            const Text('OR'),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: isLoading ? null : _googleLogin,
              icon: const Icon(Icons.login),
              label: const Text('Continue with Google'),
            ),

            const SizedBox(height: 16),

            if (error.isNotEmpty)
              Text(
                error,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}