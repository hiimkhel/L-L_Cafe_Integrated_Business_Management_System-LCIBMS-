import 'package:flutter/material.dart';
import 'features/dashboard/presentation/admin/menu_management.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu Management',
      debugShowCheckedModeBanner: false,
      home: const MenuManagementScreen(),
    );
  }
}
