import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

// ─────────────────────────────────────────────
// NAV ITEM MODEL
// ─────────────────────────────────────────────

class _NavItemData {
  final IconData icon;
  final String label;
  final String route;
  const _NavItemData({
    required this.icon,
    required this.label,
    required this.route,
  });
}

const List<_NavItemData> _navItems = [
  _NavItemData(icon: Icons.dashboard_rounded,    label: 'DASHBOARD',        route: '/dashboard'),
  _NavItemData(icon: Icons.receipt_long_rounded, label: 'ORDERS',           route: '/orders'),
  _NavItemData(icon: Icons.menu_book_rounded,    label: 'MENU MANAGEMENT',  route: '/menu_management'),
  _NavItemData(icon: Icons.bar_chart_rounded,    label: 'REPORTS',          route: '/reports'),
  _NavItemData(icon: Icons.people_alt_rounded,   label: 'CUSTOMERS',        route: '/customers'),
  _NavItemData(icon: Icons.star_rounded,         label: 'REVIEWS',          route: '/reviews'),
  _NavItemData(icon: Icons.tune_rounded,         label: 'CMS',              route: '/cms'),
];

// ─────────────────────────────────────────────
// SIDEBAR WIDGET
// ─────────────────────────────────────────────

class Sidebar extends StatefulWidget {
  final int activeIndex;
  const Sidebar({super.key, this.activeIndex = 0});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.activeIndex;
  }

  void _onTap(int index) {
    if (_selected == index) return;
    setState(() => _selected = index);
    Navigator.pushReplacementNamed(context, _navItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Logo ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/lnl.jpg',
                width: 68,
                height: 68,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: Colors.white, size: 32),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Nav items ────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _NavTile(
                  data: _navItems[i],
                  selected: _selected == i,
                  onTap: () => _onTap(i),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NAV TILE
// ─────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Icon badge ──────────────────────
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white
                    : AppColors.primary.withOpacity(0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(
                data.icon,
                size: 15,
                color: selected ? AppColors.secondary : AppColors.primary,
              ),
            ),

            const SizedBox(width: 10),

            // ── Label ───────────────────────────
            Expanded(
              child: Text(
                data.label,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  height: 1.3,
                  color: selected ? Colors.white : AppColors.tertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}