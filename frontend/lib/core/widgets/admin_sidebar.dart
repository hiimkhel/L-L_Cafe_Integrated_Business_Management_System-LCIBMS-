import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

// Screens
import 'package:frontend/features/dashboard/presentation/admin/dashboard_screen.dart';
import 'package:frontend/features/dashboard/presentation/admin/order_screen.dart';
import 'package:frontend/features/dashboard/presentation/admin/menu_management.dart';
import 'package:frontend/features/reports/presentation/admin/reports_screen.dart';
import 'package:frontend/features/customers/presentation/admin/customers_screen.dart';
import 'package:frontend/features/reviews/presentation/admin/reviews_screen.dart';
import 'package:frontend/features/cms/presentation/cms_screen.dart';

class Sidebar extends StatefulWidget {
  final int activeIndex;
  final VoidCallback onLogout; // kept ONLY for passing to screens

  const Sidebar({
    super.key,
    this.activeIndex = 0,
    required this.onLogout,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late int _selected;

  final List<Map<String, dynamic>> _items = const [
    {"icon": Icons.dashboard_rounded, "label": "DASHBOARD"},
    {"icon": Icons.receipt_long_rounded, "label": "ORDERS"},
    {"icon": Icons.menu_book_rounded, "label": "MENU"},
    {"icon": Icons.bar_chart_rounded, "label": "REPORTS"},
    {"icon": Icons.people_alt_rounded, "label": "CUSTOMERS"},
    {"icon": Icons.star_rounded, "label": "REVIEWS"},
    {"icon": Icons.tune_rounded, "label": "CMS"},
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.activeIndex;
  }

  void _onTap(int index) {
    if (_selected == index) return;

    setState(() => _selected = index);

    Widget screen;

    switch (index) {
      case 0:
        screen = AdminDashboardScreen(activeIndex: 0, onLogout: widget.onLogout);
        break;
      case 1:
        screen = OrderScreen(activeIndex: 1, onLogout: widget.onLogout);
        break;
      case 2:
        screen = MenuManagementScreen(activeIndex: 2, onLogout: widget.onLogout);
        break;
      case 3:
        screen = ReportsScreen(activeIndex: 3, onLogout: widget.onLogout);
        break;
      case 4:
        screen = CustomersScreen(activeIndex: 4, onLogout: widget.onLogout);
        break;
      case 5:
        screen = ReviewsScreen(activeIndex: 5, onLogout: widget.onLogout);
        break;
      case 6:
        screen = CMSScreen(activeIndex: 6, onLogout: widget.onLogout);
        break;
      default:
        screen = AdminDashboardScreen(activeIndex: 0, onLogout: widget.onLogout);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      child: Column(
        children: [
          // LOGO
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: AssetImage("assets/images/lnl.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // NAV ITEMS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final selected = _selected == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => _onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.secondary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? Colors.white
                                  : AppColors.primary.withOpacity(0.15),
                            ),
                            child: Icon(
                              item["icon"],
                              size: 16,
                              color: selected
                                  ? AppColors.secondary
                                  : AppColors.primary,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              item["label"],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                                color: selected
                                    ? Colors.white
                                    : AppColors.tertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}