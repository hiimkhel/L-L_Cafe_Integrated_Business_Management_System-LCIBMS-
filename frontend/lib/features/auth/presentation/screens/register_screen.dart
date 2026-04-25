import 'package:flutter/material.dart';
import 'package:frontend/core/models/user.dart';
import 'package:frontend/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final Function(User) onRegister;

  const RegisterScreen({super.key, required this.onRegister});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  String error = '';
  bool isLoading = false;

  /// Email Register
  void _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    setState(() {
      error = '';
      isLoading = true;
    });

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        error = 'All fields are required';
        isLoading = false;
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        error = 'Passwords do not match';
        isLoading = false;
      });
      return;
    }

    try {
      final user = await _authService.register(name, email, password);

      widget.onRegister(user);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Google Register (same as login)
  void _googleRegister() async {
    setState(() {
      error = '';
      isLoading = true;
    });

    try {
      final user = await _authService.signInWithGoogle();

      widget.onRegister(user);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _facebookRegister() async {
    setState(() {
      error = '';
      isLoading = true;
    });

    try {
      final user = await _authService.signInWithFacebook();

      widget.onRegister(user);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),

            const SizedBox(height: 8),

            ///  Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),

            const SizedBox(height: 8),

            /// Password
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),

            const SizedBox(height: 8),

            ///  Confirm Password
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
            ),

            const SizedBox(height: 16),

            ///  Register Button
            ElevatedButton(
              onPressed: isLoading ? null : _register,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Register'),
            ),

            const SizedBox(height: 16),

            /// Divider
            const Text('OR'),

            const SizedBox(height: 16),

            ///  Google Register
            OutlinedButton.icon(
              onPressed: isLoading ? null : _googleRegister,
              icon: const Icon(Icons.login),
              label: const Text('Continue with Google'),
            ),

            const SizedBox(height: 16),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: isLoading ? null : _facebookRegister,
              icon: const Icon(Icons.facebook, color: Colors.blue),
              label: const Text('Continue with Facebook'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),

            ///  Error
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