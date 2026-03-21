import 'package:flutter/material.dart';
import 'package:frontend/config/theme/colors.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  //-------------------------Build----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                _buildFilterRow(),
                Expanded(child: _buildThreePanels()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //-------------------------SideBar-------------------------------------------------------------
  Widget _buildSidebar() {
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
      color: AppColors.primary,
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
                child: Image.asset("assets/images/lnl.jpg", fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 37),
          ...navItems.map(
            (e) => _navTile(
              e.$1,
              e.$2,
              selected: e.$2.contains("MENU\nMANAGEMENT"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navTile(IconData icon, String label, {bool selected = false}) {
    return Container(
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
                color: selected ? AppColors.bg : AppColors.tertiary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.tertiary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.bold,
                  height: 1.50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //-------------------------BuildTopBar-------------------------------------------------------------
  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withOpacity(.5)),
        ),
      ),
      child: Row(
        children: [
          Text(
            "MENU MANAGEMENT",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.tertiary,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          _topIcon(Icons.dark_mode_outlined),
          const SizedBox(width: 8),
          _topIcon(Icons.notifications_rounded),
          const SizedBox(width: 8),
          _topIcon(Icons.settings_rounded),
          const SizedBox(width: 10),
          Container(width: 2.5, height: 30, color: AppColors.tertiary),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.tertiary,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "L&L CAFE",
                style: TextStyle(fontSize: 10, color: AppColors.secondary),
              ),
              Text(
                "ADMIN",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tertiary,
                ),
              ),
              Container(height: 2, width: 35, color: Colors.black),
            ],
          ),
          const SizedBox(width: 12),
          _topIcon(Icons.logout_rounded),
        ],
      ),
    );
  }

  Widget _topIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary),
      ),
      child: Icon(icon, color: AppColors.tertiary, size: 25),
    );
  }

  //-------------------------FilterRow-------------------------------------------------------------
  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tertiary.withOpacity(1.0),
                  offset: Offset(0, 4),
                  blurRadius: 9,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  "ALL ITEMS",
                  style: TextStyle(
                    color: AppColors.tertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.tertiary,
                  size: 16,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 210,
            height: 36,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tertiary.withOpacity(1.0),
                    offset: Offset(0, 4),
                    blurRadius: 9,
                    spreadRadius: 0,
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                style: TextStyle(fontSize: 15, color: AppColors.tertiary),
                decoration: InputDecoration(
                  hintText: "SEARCH ITEM...",
                  hintStyle: TextStyle(
                    color: AppColors.tertiary,
                    fontSize: 12,
                    letterSpacing: .8,
                    fontWeight: FontWeight.bold,
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: AppColors.tertiary,
                    size: 16,
                  ),
                  filled: true,
                  fillColor: AppColors.bg,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.bg),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: AppColors.tertiary,
                      width: .9,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //-------------------------ThreePanels-------------------------------------------------------------
  Widget _buildThreePanels() {
    return Row();
  }
}
