import 'package:flutter/material.dart';
import 'revenue_tab.dart';
import 'orders_tab.dart';
import 'avg_order_tab.dart';

enum BusinessTab { revenue, orders, avgOrder }

class BusinessPerformanceCard extends StatefulWidget {
  const BusinessPerformanceCard({super.key});

  @override
  State<BusinessPerformanceCard> createState() => _BusinessPerformanceCardState();
}

class _BusinessPerformanceCardState extends State<BusinessPerformanceCard> {
  BusinessTab _activeTab = BusinessTab.revenue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E2D24), Color(0xFF4A6741)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "BUSINESS PERFORMANCE",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          _buildTabBar(),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: KeyedSubtree(
              key: ValueKey(_activeTab),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tabButton("REVENUE", BusinessTab.revenue),
          _tabButton("ORDERS", BusinessTab.orders),
          _tabButton("AVG ORDER", BusinessTab.avgOrder),
        ],
      ),
    );
  }

  Widget _tabButton(String label, BusinessTab tab) {
    final isActive = _activeTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2E5E3A) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: isActive ? Border.all(color: Colors.white24, width: 0.5) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case BusinessTab.revenue:
        return const RevenueTab();
      case BusinessTab.orders:
        return const OrdersTab();
      case BusinessTab.avgOrder:
        return const AvgOrderTab();
    }
  }
}