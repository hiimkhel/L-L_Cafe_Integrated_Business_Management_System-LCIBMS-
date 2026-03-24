import 'package:flutter/material.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  static const _primary = Color(0xFFEFE2C9);
  static const _secondary = Color(0xFF758C6D);
  static const _tertiary = Color(0xFFa98258);
  static const _bg = Color(0xFFFFFFFF);

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
              children: [
                _buildTopBar(),
                _buildFilterRow(),
                Expanded(child: _buildOrderPlaceholder()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final navItems = [
      (Icons.dashboard_rounded, "DASHBOARD"),
      (Icons.shopping_bag, "ORDERS"),
      (Icons.menu_book, "MENU\nMANAGEMENT"),
      (Icons.bar_chart, "REPORTS"),
      (Icons.people, "CUSTOMERS"),
      (Icons.rate_review, "REVIEWS"),
      (Icons.article, "CMS"),
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
                child: Image.asset(
                  "assets/images/lnl.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 37),
          ...navItems.map(
            (e) => _navTile(
              e.$1,
              e.$2,
              selected: e.$2.contains("ORDERS"),
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
                  fontWeight: FontWeight.bold,
                  height: 1.50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      decoration: BoxDecoration(
        color: _primary,
        border: Border(
          bottom: BorderSide(
            color: Color.fromRGBO(239, 226, 201, 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            "ORDERS",
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

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _tertiary,
                  offset: const Offset(0, 4),
                  blurRadius: 9,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  "ALL ORDERS",
                  style: TextStyle(
                    color: _tertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(Icons.keyboard_arrow_down, color: _tertiary, size: 16),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 220,
            height: 36,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: _tertiary,
                    offset: const Offset(0, 4),
                    blurRadius: 9,
                    spreadRadius: 0,
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                style: TextStyle(fontSize: 15, color: _tertiary),
                decoration: InputDecoration(
                  hintText: "SEARCH ORDER...",
                  hintStyle: TextStyle(
                    color: _tertiary,
                    fontSize: 12,
                    letterSpacing: .8,
                    fontWeight: FontWeight.bold,
                  ),
                  suffixIcon: Icon(Icons.search, color: _tertiary, size: 16),
                  filled: true,
                  fillColor: _bg,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: _bg),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: _tertiary, width: .9),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline, size: 16),
            label: const Text('NEW ORDER'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _tertiary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderPlaceholder() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(169, 130, 88, 0.15),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_checkout,
              size: 64,
              color: Colors.black38,
            ),
            const SizedBox(height: 14),
            Text(
              'Order management is under development',
              style: TextStyle(
                fontSize: 18,
                color: _tertiary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Placeholder content to match dashboard/menu management style',
              style: TextStyle(
                fontSize: 14,
                color: Color.fromRGBO(169, 130, 88, 0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: List.generate(4, (index) {
                final labels = ['Pending', 'Preparing', 'Ready', 'Completed'];
                return _statusCard(labels[index], (index + 2) * 5);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(String title, int count) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color.fromRGBO(117, 140, 109, 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: _tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
