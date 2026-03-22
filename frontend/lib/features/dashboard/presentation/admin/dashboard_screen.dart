import 'package:flutter/material.dart';
import 'menu_management.dart';
import 'order_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Center(child: Text('Admin Dashboard')),

          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text("Menu Management"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MenuManagementScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text("Order Management"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
