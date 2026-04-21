import 'package:flutter/material.dart';

import 'features/home/presentation/customer/home_screen.dart';
import 'features/dashboard/presentation/admin/dashboard_screen.dart';
import 'features/home/presentation/rider/home_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/rider/dashboard_screen.dart';
import 'features/dashboard/presentation/pos/order_entry.dart';
import 'features/home/presentation/customer/landing_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/models/user.dart';
import 'features/customers/presentation/admin/cart_screen.dart';
import 'features/checkout/customer/presentation/cart_checkout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LCIBMSApp());
}

class LCIBMSApp extends StatefulWidget {
  const LCIBMSApp({super.key});

  @override
  State<LCIBMSApp> createState() => _LCIBMSAppState();
}

class _LCIBMSAppState extends State<LCIBMSApp> {
  User? currentUser;

  void setUser(User user) {
      setState(() {
      currentUser = user;
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
      return LandingScreen(onLogin: setUser, onRegister: setUser);
    }

    // LOGGED IN (ROLE ROUTING)
    switch (currentUser!.role) {
      case UserRole.customer:
        return CustomerHomeScreen();

      case UserRole.rider:
        return DeliveryDashboardScreen();

      case UserRole.cashier:
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
