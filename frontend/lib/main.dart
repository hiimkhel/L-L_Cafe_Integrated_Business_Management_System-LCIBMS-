import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'core/models/user.dart';

// Screens
import 'features/home/presentation/customer/landing_screen.dart';
import 'features/home/presentation/customer/home_screen.dart';
import 'features/customers/presentation/admin/menu_screen.dart';
import 'features/home/presentation/customer/contact_screen.dart';
import 'features/home/presentation/customer/about_screen.dart';
import 'features/home/presentation/customer/profile_screen.dart';
import 'features/customers/presentation/admin/cart_screen.dart';
import 'features/dashboard/presentation/admin/dashboard_screen.dart';
import 'features/dashboard/presentation/rider/dashboard_screen.dart';
import 'features/dashboard/presentation/pos/order_entry.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';

// Shared cart state
import 'core/constants/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
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

  // Single CartNotifier that lives for the app's entire lifetime
  final CartNotifier _cartNotifier = CartNotifier();

  void setUser(User user) => setState(() => currentUser = user);

  void logout() {
    _cartNotifier.clear();
    setState(() => currentUser = null);
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  /// Push the styled LoginScreen on top of whatever guest screen is showing.
  /// On success: setUser fires → popUntil(first) → app rebuilds to role screen.
  void _goLogin(BuildContext ctx) {
    Navigator.push(
      ctx,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginScreen(
          onLogin: (user) {
            setUser(user);
            Navigator.of(ctx).popUntil((route) => route.isFirst);
          },
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  /// Push the styled RegisterScreen on top of whatever guest screen is showing.
  void _goRegister(BuildContext ctx) {
    Navigator.push(
      ctx,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => RegisterScreen(
          onRegister: (user) {
            setUser(user);
            Navigator.of(ctx).popUntil((route) => route.isFirst);
          },
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return CartProvider(
      notifier: _cartNotifier,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _buildScreen(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return _fade(_buildScreen());

            case '/home':
              return _fade(CustomerHomeScreen(onLogout: logout));

            case '/menu':
              return _fade(const MenuScreen());

            case '/cart':
              return _fade(const CartScreen());

            // TODO: replace with dedicated OrdersScreen when ready
            case '/orders':
              return _fade(const CartScreen());

            case '/about':
              return _fade(Builder(
                builder: (ctx) => AboutScreen(
                  onLogin: () => _goLogin(ctx),
                  onJoinNow: () => _goRegister(ctx),
                ),
              ));

            case '/contact':
              return _fade(Builder(
                builder: (ctx) => ContactScreen(
                  onLogin: () => _goLogin(ctx),
                  onJoinNow: () => _goRegister(ctx),
                ),
              ));

            case '/profile':
              if (currentUser == null) {
                return _fade(LandingScreen(onLogin: setUser, onRegister: setUser));
              }

              return _fade(ProfileScreen(
                userId: currentUser!.id,
                email: currentUser!.email,
                onLogout: logout,
              ));

            default:
              return null;
          }
        },
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      );

  Widget _buildScreen() {
    if (currentUser == null) {
      return LandingScreen(onLogin: setUser, onRegister: setUser);
    }
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