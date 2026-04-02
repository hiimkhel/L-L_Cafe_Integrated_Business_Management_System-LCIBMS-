import 'package:flutter/material.dart';
import "../../config/theme/app_colors.dart";

class Sidebar extends StatefulWidget {
  final int activeIndex;

  const Sidebar({super.key, this.activeIndex = 0});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late int selectedIndex;

  // Map of nav labels and their respective routes
  final List<Map<String, dynamic>> navItems = [
    {"icon": Icons.dashboard_rounded, "label": "DASHBOARD", "route": "/dashboard"},
    {"icon": Icons.dashboard_rounded, "label": "ORDERS", "route": "/orders"},
    {"icon": Icons.dashboard_rounded, "label": "MENU\nMANAGEMENT", "route": "/menu_management"},
    {"icon": Icons.dashboard_rounded, "label": "REPORTS", "route": "/reports"},
    {"icon": Icons.dashboard_rounded, "label": "CUSTOMERS", "route": "/customers"},
    {"icon": Icons.dashboard_rounded, "label": "REVIEWS", "route": "/reviews"},
    {"icon": Icons.dashboard_rounded, "label": "CMS", "route": "/cms"},
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.activeIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      color: AppColors.background,
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/images/lnl.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 37),

          // Nav Items
          ...List.generate(navItems.length, (index) {
            final item = navItems[index];
            return _NavTile(
              icon: item["icon"],
              label: item["label"],
              selected: selectedIndex == index,
              onTap: () {
                setState(() => selectedIndex = index);

                // Navigate using the route from the map
                final route = item["route"];
                if (route != null && route is String) {
                  Navigator.pushReplacementNamed(context, route);
                }
              },
            );
          }),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : AppColors.tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.tertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
