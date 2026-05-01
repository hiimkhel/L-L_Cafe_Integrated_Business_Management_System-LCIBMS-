import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Firebase & Core
import 'firebase_options.dart';
import 'core/models/user.dart';
import 'core/providers/auth_provider.dart'; 
import 'core/constants/cart_provider.dart';
import 'core/constants/routes.dart';

// ── Shared State & Routes ───────────────────────────────────────────────────
import 'core/constants/cart_provider.dart';
import 'package:frontend/core/constants/routes.dart';

// ── Screens ─────────────────────────────────────────────────────────────────
import 'package:frontend/features/customers/presentation/admin/customer_order_screen.dart';
import 'features/home/presentation/customer/landing_screen.dart';
import 'features/home/presentation/customer/home_screen.dart';
import 'features/home/presentation/rider/home_screen.dart';
import 'features/dashboard/presentation/admin/dashboard_screen.dart';
import 'features/dashboard/presentation/rider/dashboard_screen.dart';
import 'features/dashboard/presentation/pos/order_entry.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/customers/presentation/admin/menu_screen.dart';
import 'features/customers/presentation/admin/cart_screen.dart';
import 'features/home/presentation/customer/contact_screen.dart';
import 'features/home/presentation/customer/about_screen.dart';
import 'features/home/presentation/customer/profile_screen.dart';

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
  final CartNotifier _cartNotifier = CartNotifier();

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _goLogin(BuildContext ctx) {
    Navigator.push(
      ctx,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginScreen(
          onLogin: (user) {
            ctx.read<AuthProvider>().setUser(user);
            Navigator.of(ctx).popUntil((route) => route.isFirst);
          },
        ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  void _goRegister(BuildContext ctx) {
    Navigator.push(
      ctx,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => RegisterScreen(
          onRegister: (user) {
            ctx.read<AuthProvider>().setUser(user);
            Navigator.of(ctx).popUntil((route) => route.isFirst);
          },
        ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. First, we provide the Auth state
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // 2. Then we wrap the CartProvider inside it
          return CartProvider(
            notifier: _cartNotifier,
            // 3. Finally, the MaterialApp lives inside both
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: _buildRootScreen(auth),
              onGenerateRoute: (settings) => _handleRoutes(settings, auth),
            ),
          );
        },
      ),
    );
  }

  // ── Route & Screen Logic ──────────────────────────────────────────────────

  Widget _buildRootScreen(AuthProvider auth) {
    final user = auth.user;
    if (user == null) {
      return LandingScreen(
        onLogin: (u) => auth.setUser(u),
        onRegister: (u) => auth.setUser(u),
      );
    }

    switch (user.role) {
      case UserRole.customer:
        return CustomerHomeScreen(onLogout: () {
          auth.logout();
          _cartNotifier.clear();
        });
      case UserRole.rider:
        return DeliveryDashboardScreen();
      case UserRole.cashier:
        return POSOrderScreen();
      case UserRole.admin:
        return AdminDashboardScreen(
          key: ValueKey(user.email),
          activeIndex: 0,
          onLogout: () {
            auth.logout();
            _cartNotifier.clear();
          },
        );
      default:
        return const Center(child: Text("Role not recognized"));
    }
  }

  Route? _handleRoutes(RouteSettings settings, AuthProvider auth) {
    final user = auth.user;

    switch (settings.name) {
      case '/':
        return _fade(_buildRootScreen(auth));

      case AppRoutes.home:
        return _fade(CustomerHomeScreen(onLogout: auth.logout));

      case AppRoutes.profile:
        if (user == null) return _fade(_buildRootScreen(auth));
        return _fade(ProfileScreen(
          userId: user.id,
          email: user.email,
          onLogout: () {
            auth.logout();
            _cartNotifier.clear();
          },
        ));

      case AppRoutes.about:
      case AppRoutes.contact:
        return _fade(Builder(
          builder: (ctx) {
            final page = settings.name == AppRoutes.about 
                ? AboutScreen(onLogin: () => _goLogin(ctx), onJoinNow: () => _goRegister(ctx))
                : ContactScreen(onLogin: () => _goLogin(ctx), onJoinNow: () => _goRegister(ctx));
            return page;
          },
        ));

      case AppRoutes.menu:
        return _fade(const MenuScreen());
      case AppRoutes.cart:
        return _fade(const CartScreen());

      default:
        return null;
    }
  }

  PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      );
}