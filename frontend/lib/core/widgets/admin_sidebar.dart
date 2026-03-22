import 'package:flutter/material.dart';
import "../../config/theme/app_colors.dart";

class Sidebar extends StatefulWidget{
  final int activeIndex;
  final Function(int)? onItemTap;

    const Sidebar({
      super.key,
      this.activeIndex = 0,
      this.onItemTap,
    });

    @override
    State<Sidebar> createState() => _SidebarState();

}

class _SidebarState extends State<Sidebar>{
  late int selectedIndex;
  @override
  void initState(){
    super.initState();
    selectedIndex = widget.activeIndex;
  }
  @override
  Widget build(BuildContext context){
    final navItems = [
      (Icons.dashboard_rounded, "DASHBOARD"),
      (Icons.dashboard_rounded, "ORDERS"),
      (Icons.dashboard_rounded, "MENU\nMANAGEMENT"),
      (Icons.dashboard_rounded, "REPORTS"),
      (Icons.dashboard_rounded, "CUSTOMERS"),
      (Icons.dashboard_rounded, "REVIEWS"),
      (Icons.dashboard_rounded, "CMS"),
    ];

    return Container(
      width: 148,
      color: AppColors.background, // from app_colors.dart
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // Build nav tiles dynamically
          ...List.generate(navItems.length, (index) {
            final e = navItems[index];
            return _NavTile(
              icon: e.$1,
              label: e.$2,
              selected: selectedIndex == index,
              onTap: () {
                setState(() => selectedIndex = index);
                if (widget.onItemTap != null) widget.onItemTap!(index);
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
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.background : AppColors.tertiary,
                ),
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