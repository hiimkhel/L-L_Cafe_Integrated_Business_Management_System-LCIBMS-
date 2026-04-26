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

  String error = '';

  void _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    setState(() => error = '');

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => error = 'All fields are required');
      return;
    }

    if (password != confirm) {
      setState(() => error = 'Passwords do not match');
      return;
    }

    try {

      final user = await AuthService.register(name, email, password);

      widget.onRegister(user);

      // Go back to landing (or auto-login flow)
      Navigator.pop(context);

    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
      });
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
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 8),

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
            const SizedBox(height: 8),

            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _register,
              child: const Text('Register'),
            ),

            const SizedBox(height: 8),
            Text(error, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}