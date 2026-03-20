import 'package:flutter/material.dart';

// Placeholder screens
import 'features/home/presentation/customer/home_screen.dart';
import 'features/dashboard/presentation/admin/dashboard_screen.dart';
import 'features/dashboard/presentation/cashier/dashboard_screen.dart';
import 'features/home/presentation/rider/home_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() {
  runApp(const LCIBMSApp());
}

// User Roles
enum UserRole { customer, admin, pos, rider }

// Hardcoded User model
class User {
  final String email;
  final String password;
  final UserRole role;

  User(this.email, this.password, this.role);
}

// Hardcoded users
final List<User> fakeUsers = [
  User('customer@test.com', '1234', UserRole.customer),
  User('admin@test.com', '1234', UserRole.admin),
  User('pos@test.com', '1234', UserRole.pos),
  User('rider@test.com', '1234', UserRole.rider),
];

// Global current user (simple for starter)
User? currentUser;

class LCIBMSApp extends StatefulWidget {
  const LCIBMSApp({super.key});

  @override
  State<LCIBMSApp> createState() => _LCIBMSAppState();
}

class _LCIBMSAppState extends State<LCIBMSApp> {
  void _setUser(User user) {
    setState(() {
      currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'L-L Cafe IBMS',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: currentUser == null
          ? LoginScreen(onLogin: _setUser)
          : _getHomeScreen(currentUser!.role),
    );
  }

  Widget _getHomeScreen(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return const CustomerHomeScreen();
      case UserRole.admin:
        return const AdminDashboardScreen();
      case UserRole.pos:
        return const PosDashboardScreen();
      case UserRole.rider:
        return const RiderHomeScreen();
    }
  }
}