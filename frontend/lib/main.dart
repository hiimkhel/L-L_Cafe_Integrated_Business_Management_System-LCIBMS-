import 'package:flutter/material.dart';
import 'package:frontend/features/customers/presentation/admin/customer_order_screen.dart';

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

// ✅ TURNED BACK ON: We uncommented your Cart Screen import!
import 'features/customers/presentation/admin/cart_screen.dart';

import 'features/checkout/customer/presentation/cart_checkout_screen.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Your Profile Screen Import:
import 'features/home/presentation/customer/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await dotenv.load(fileName: ".env");

  // Firebase Facebook OAuth Initilization
  await FacebookAuth.instance.webAndDesktopInitialize(
    appId: dotenv.env['FACEBOOK_APP_ID']!,
    cookie: true,
    xfbml: true,
    version: "v13.0",
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
          case '/':
            return MaterialPageRoute(builder: (_) => _buildScreen());

          case '/home':
            return MaterialPageRoute(
              builder: (_) => CustomerHomeScreen(onLogout: logout),
            );

          case '/cart':
            return MaterialPageRoute(builder: (_) => const CartScreen());

          case '/orders':
            return MaterialPageRoute(
              builder: (_) => const CustomerOrderScreen(),
            );

          case '/profile':
            return MaterialPageRoute(
              builder: (_) => ProfileScreen(onLogout: logout),
            );

          case '/menu':
            return MaterialPageRoute(
              builder:
                  (_) => const Scaffold(
                    body: Center(child: Text('Menu Screen goes here')),
                  ),
            );

          default:
            return null;
        }
      },
    );
  }

  Widget _buildScreen() {
    // NOT LOGGED IN -> Show Landing Screen
    if (currentUser == null) {
      return LandingScreen(onLogin: setUser, onRegister: setUser);
    }

    // LOGGED IN (ROLE ROUTING)
    switch (currentUser!.role) {
      case UserRole.customer:
        return CustomerHomeScreen(onLogout: logout);

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
