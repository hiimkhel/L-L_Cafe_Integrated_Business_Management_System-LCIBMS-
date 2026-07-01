import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'core/models/user.dart';
import 'core/providers/auth_provider.dart';
import 'core/constants/cart_provider.dart';
import 'core/constants/routes.dart';
import 'core/constants/notification_provider.dart';

import 'package:frontend/features/customers/presentation/admin/customer_order_screen.dart';
import 'features/home/presentation/customer/landing_screen.dart';
import 'features/home/presentation/customer/home_screen.dart';
import 'features/customers/presentation/admin/menu_screen.dart';
import 'features/home/presentation/customer/contact_screen.dart';
import 'features/home/presentation/customer/about_screen.dart';
import 'features/home/presentation/customer/profile_screen.dart';
import 'features/customers/presentation/admin/cart_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/dashboard/presentation/admin/dashboard_screen.dart';
import 'features/dashboard/presentation/rider/dashboard_screen.dart';
import 'features/dashboard/presentation/pos/order_entry.dart';
import 'package:frontend/core/services/permission_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FacebookAuth.instance.webAndDesktopInitialize(
    appId: '1462606645593730',
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

  // ✅ Single NotificationController instance — lives for the lifetime of the
  //    app so the unread count persists across route changes and screen swaps.
  final NotificationController _notificationController =
      NotificationController();

  void _goLogin(BuildContext ctx) {
    Navigator.push(ctx, PageRouteBuilder(
      pageBuilder: (_, __, ___) => LoginScreen(
        onLogin: (user) {
          ctx.read<AuthProvider>().setUser(user);
          Navigator.of(ctx).popUntil((route) => route.isFirst);
        },
      ),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 220),
    ));
  }

  void _goRegister(BuildContext ctx) {
    Navigator.push(ctx, PageRouteBuilder(
      pageBuilder: (_, __, ___) => RegisterScreen(
        onRegister: (user) {
          ctx.read<AuthProvider>().setUser(user);
          Navigator.of(ctx).popUntil((route) => route.isFirst);
        },
      ),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 220),
    ));
  }

  final PermissionService _permissionService = PermissionService();

  @override
  void initState() {
    super.initState();
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    await _permissionService.requestBluetoothPermissions();

    debugPrint("✅ Bluetooth permissions requested");

    final hasPerm = await _permissionService.hasPermissions();
    debugPrint("🔐 Permission status: $hasPerm");
  }

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return CartProvider(
            notifier: _cartNotifier,
            // ✅ NotificationProvider wraps MaterialApp so every screen —
            //    CustomerNavbar, NotificationPanel, CustomerHomeScreen, etc. —
            //    can call NotificationProvider.of(context) without an assertion.
            child: NotificationProvider(
              controller: _notificationController,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                home: _buildRootScreen(auth),
                onGenerateRoute: (settings) => _handleRoutes(settings, auth),
              ),
            ),
          );
        },
      ),
    );
  }

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
        return LandingScreen(
          onLogin: (u) => auth.setUser(u),
          onRegister: (u) => auth.setUser(u),
        );
    }
  }

  Route? _handleRoutes(RouteSettings settings, AuthProvider auth) {
    final user = auth.user;
    final isLoggedIn = user != null;

    void doLogout() {
      auth.logout();
      _cartNotifier.clear();
    }

switch (settings.name) {
  case '/':
    return _fade(_buildRootScreen(auth));

  case AppRoutes.home:
    return _fade(CustomerHomeScreen(onLogout: doLogout));

      case AppRoutes.orders:
        if (!isLoggedIn) return _fade(_buildRootScreen(auth));
        return _fade(const CustomerOrderScreen());

      case AppRoutes.profile:
        if (!isLoggedIn) return _fade(_buildRootScreen(auth));
        return _fade(ProfileScreen(
          userId: user.id,
          email: user.email,
          onLogout: doLogout,
        ));

  case AppRoutes.about:
    return _fade(
      Builder(
        builder: (ctx) => Consumer<AuthProvider>(
          builder: (ctx, auth, _) {
            final isLoggedIn = auth.user != null;

            return AboutScreen(
              isGuest: !isLoggedIn,
              onLogin: isLoggedIn ? null : () => _goLogin(ctx),
              onJoinNow: isLoggedIn ? null : () => _goRegister(ctx),
              onLogout: isLoggedIn ? doLogout : null,
            );
          },
        ),
      ),
    );

      case AppRoutes.contact:
        return _fade(Builder(builder: (ctx) => ContactScreen(
          // ✅ KEY: isGuest is derived from actual auth state, not hardcoded.
          //    This means navigating to /contact always shows the correct navbar.
          isGuest:   !isLoggedIn,
          onLogin:   isLoggedIn ? null : () => _goLogin(ctx),
          onJoinNow: isLoggedIn ? null : () => _goRegister(ctx),
          onLogout:  isLoggedIn ? doLogout : null,
        )));

      // ✅ KEY FIX: /menu now reads auth state and passes isGuest correctly.
      //    Previously MenuScreen() had no arguments so isGuest defaulted to
      //    false — meaning ANY navigation to /menu showed logged-in mode,
      //    even for unauthenticated users coming from Contact or About pages.
      case AppRoutes.menu:
        return _fade(Builder(builder: (ctx) => isLoggedIn
            ? const MenuScreen(isGuest: false)
            : MenuScreen(
                isGuest: true,
                onLoginRequired: () => _goLogin(ctx),
              )));

  case AppRoutes.cart:
    return _fade(CartScreen());

  default:
    return null;
  }
  }

  PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      );
}