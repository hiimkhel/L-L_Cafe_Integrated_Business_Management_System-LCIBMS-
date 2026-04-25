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

// Your Profile Screen Import:
import 'features/home/presentation/customer/profile_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LCIBMSApp());
}

class LCIBMSApp extends StatefulWidget {
  const LCIBMSApp({super.key});

  @override
  State<LCIBMSApp> createState() => _LCIBMSAppState();
}

class _LCIBMSAppState extends State<LCIBMSApp> {
  User? currentUser;

  void login(User user) {
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
        // THIS IS THE FIX: The Navbar looks for these specific names.
        switch (settings.name) {
          case '/':
            // Handles the logout routing back to the landing page
            return MaterialPageRoute(builder: (_) => _buildScreen());
            
          case '/home':
            return MaterialPageRoute(builder: (_) => CustomerHomeScreen());
            
          case '/cart':
          case '/orders':
            // Route both /cart and /orders to your CartScreen
            return MaterialPageRoute(builder: (_) => const CartScreen());
            
          case '/profile':
            // ✅ FIX APPLIED: Uncommented the real ProfileScreen and removed the placeholder
            return MaterialPageRoute(builder: (_) => const ProfileScreen());

          case '/menu':
            // Temporary placeholder for your menu screen
            return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Menu Screen goes here'))));
            
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