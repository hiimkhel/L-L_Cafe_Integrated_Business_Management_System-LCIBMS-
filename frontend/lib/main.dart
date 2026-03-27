import 'package:flutter/material.dart';

// Placeholder screens
import 'features/home/presentation/customer/home_screen.dart';
import 'features/dashboard/presentation/admin/dashboard_screen.dart';
import 'features/dashboard/presentation/cashier/dashboard_screen.dart';
import 'features/home/presentation/rider/home_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/admin/menu_management.dart';
import 'features/cms/presentation/cms_screen.dart';
import 'features/customers/presentation/admin/customers_screen.dart';
import 'features/reports/presentation/admin/reports_screen.dart';
import 'features/reviews/presentation/admin/reviews_screen.dart';

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

// Routes for Admin Screens
final Map<String, Widget Function(BuildContext)> adminRoutes = {
  '/dashboard': (_) => const AdminDashboardScreen(activeIndex: 0),
  '/orders': (_) => const CMSScreen(activeIndex: 1),
  '/menu_management': (_) => const MenuManagementScreen(activeIndex: 2),
  '/reports': (_) => const ReportsScreen(activeIndex: 3),
  '/customers': (_) => const CustomersScreen(activeIndex: 4),
  '/reviews': (_) => const ReviewsScreen(activeIndex: 5),
  '/cms': (_) => const CMSScreen(activeIndex: 6),
  // Add other routes here
};

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
    // If not logged in, show login screen
    if (currentUser == null) {
      return MaterialApp(
        title: 'L-L Cafe IBMS',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        home: LoginScreen(onLogin: _setUser),
      );
    }

    // After login, show role-specific dashboard
    switch (currentUser!.role) {
      case UserRole.customer:
        return MaterialApp(
          title: 'Customer Home',
          debugShowCheckedModeBanner: false,
          home: const CustomerHomeScreen(),
        );
      case UserRole.rider:
        return MaterialApp(
          title: 'Rider Home',
          debugShowCheckedModeBanner: false,
          home: const RiderHomeScreen(),
        );
      case UserRole.pos:
        return MaterialApp(
          title: 'POS Dashboard',
          debugShowCheckedModeBanner: false,
          home: const PosDashboardScreen(),
        );
      case UserRole.admin:
        return MaterialApp(
          title: 'Admin Dashboard',
          debugShowCheckedModeBanner: false,
          initialRoute: '/dashboard',
          routes: adminRoutes, // <-- our named routes for admin
          home: const AdminDashboardScreen(activeIndex: 0),
        );
    }
  }
}
