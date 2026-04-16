import 'package:flutter/material.dart';

import 'features/home/presentation/customer/home_screen.dart';
import 'features/dashboard/presentation/admin/dashboard_screen.dart';
import 'features/home/presentation/rider/home_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/rider/dashboard_screen.dart';
import 'features/dashboard/presentation/pos/order_entry.dart';
import 'features/home/presentation/customer/landing_screen.dart';
import 'core/models/user.dart';
import 'features/customers/presentation/admin/cart_screen.dart';

void main() {
  runApp(const LCIBMSApp());
}

// Hardcoded users
final List<User> fakeUsers = [
  User('customer@test.com', '1234', UserRole.customer),
  User('admin@test.com', '1234', UserRole.admin),
  User('pos@test.com', '1234', UserRole.pos),
  User('rider@test.com', '1234', UserRole.rider),
];

class LCIBMSApp extends StatefulWidget {
  const LCIBMSApp({super.key});

  @override
  State<LCIBMSApp> createState() => _LCIBMSAppState();
}

class _LCIBMSAppState extends State<LCIBMSApp> {
  User? currentUser;

  void login(User user) {
    setState(() {
      currentUser = null;
    });

    Future.delayed(const Duration(milliseconds: 10), () {
      setState(() {
        currentUser = user;
      });
    });
  }

  void logout() {
    setState(() {
      currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _buildScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/cart':
            return MaterialPageRoute(builder: (_) => const CartScreen());
          // add more routes here as needed
          default:
            return null;
        }
      },
    );
  }

  Widget _buildScreen() {
    // NOT LOGGED IN
    if (currentUser == null) {
      return LandingScreen(onLogin: login);
    }

    // LOGGED IN (ROLE ROUTING)
    switch (currentUser!.role) {
      case UserRole.customer:
        return CustomerHomeScreen();

      case UserRole.rider:
        return DeliveryDashboardScreen();

      case UserRole.pos:
        return POSOrderScreen();

      case UserRole.admin:
        return AdminDashboardScreen(
          key: ValueKey(currentUser!.email),
          activeIndex: 0,
          onLogout: logout,
        );
    }
  }
}
