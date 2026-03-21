import 'package:flutter/material.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  //-------------------------Palette----------------------------------------------------------------
  static const _primary = Color(0xFFEFE2C9);
  static const _secondary = Color(0xFF758C6D);
  static const _tertiary = Color(0xFFa98258);
  static const _bg = Color(0xFFFFFFFF);

  //-------------------------Build----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildTopBar()],
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
      color: _primary,
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _tertiary,
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
        color: selected ? _secondary : Colors.transparent,
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
                color: selected ? _bg : _tertiary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : _tertiary,
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
        color: _primary,
        border: Border(bottom: BorderSide(color: _primary.withOpacity(.5))),
      ),
      child: Row(
        children: [
          Text(
            "MENU MANAGEMENT",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _tertiary,
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
          Container(width: 2.5, height: 30, color: _tertiary),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: _tertiary,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "L&L CAFE",
                style: TextStyle(fontSize: 10, color: _secondary),
              ),
              Text(
                "ADMIN",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _tertiary,
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
        color: _primary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _primary),
      ),
      child: Icon(icon, color: _tertiary, size: 25),
    );
  }
}
