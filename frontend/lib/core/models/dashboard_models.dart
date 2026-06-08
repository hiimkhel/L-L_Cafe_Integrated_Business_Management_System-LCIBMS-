import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';


class SummaryCardData {
  final String label, value, delta;
  final bool deltaPositive;
  final IconData icon;
  final Color accent;
  const SummaryCardData({
    required this.label, required this.value, required this.delta,
    required this.deltaPositive, required this.icon, required this.accent,
  });
}

class DashboardOrderRow {
  final String orderId, customerName, payment, status, orderTime, amount;
  const DashboardOrderRow({
    required this.orderId, required this.customerName, required this.payment,
    required this.status, required this.orderTime, required this.amount,
  });
}

class TopMenuItem {
  final int rank, sold;
  final String name, price;
  const TopMenuItem({
    required this.rank, required this.name,
    required this.price, required this.sold,
  });
}

class RevenueBarData {
  final String month, rawLabel;
  final double value;
  final bool isHighlighted;
  const RevenueBarData({
    required this.month, required this.value,
    required this.rawLabel, this.isHighlighted = false,
  });
}
