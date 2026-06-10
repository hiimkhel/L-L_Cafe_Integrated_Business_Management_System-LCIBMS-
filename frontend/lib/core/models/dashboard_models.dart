import 'package:flutter/material.dart';


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
  final String orderId;
  final String customerName;
  final String payment;
  final String status;
  final String orderTime;
  final String amount;

  const DashboardOrderRow({
    required this.orderId,
    required this.customerName,
    required this.payment,
    required this.status,
    required this.orderTime,
    required this.amount,
  });

  factory DashboardOrderRow.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardOrderRow(
      orderId: json['order_number'] ?? '',
      customerName: json['customer_name'] ?? '',
      payment: 'Paid',
      status: json['status'] ?? '',
      orderTime: json['created_at'] ?? '',
      amount: '₱${json['total'] ?? 0}',
    );
  }
}

class TopMenuItem {
  final int rank;
  final int sold;
  final String name;
  final String price;

  const TopMenuItem({
    required this.rank,
    required this.name,
    required this.price,
    required this.sold,
  });

  factory TopMenuItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return TopMenuItem(
      rank: int.tryParse(
              json['rank'].toString(),
            ) ??
          0,
      name: json['name'] ?? '',
      price: '₱${json['price'] ?? 0}',
      sold: int.tryParse(
              json['sold'].toString(),
            ) ??
          0,
    );
  }
}

class RevenueBarData {
  final String month;
  final String rawLabel;
  final double value;
  final bool isHighlighted;

  const RevenueBarData({
    required this.month,
    required this.value,
    required this.rawLabel,
    this.isHighlighted = false,
  });

  factory RevenueBarData.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawRevenue = json['revenue'];

    final revenueValue = rawRevenue is num
        ? rawRevenue.toDouble()
        : double.tryParse(
              rawRevenue?.toString() ?? '0',
          ) ??
          0.0;

    return RevenueBarData(
      month: json['month'] ?? '',
      value: revenueValue,
      rawLabel:
          '₱${revenueValue.toStringAsFixed(0)}',
    );
  }
}

class RevenueSummary {
  final double totalRevenue;
  final double onlineRevenue;
  final double walkinRevenue;
  final double monthlyTarget;
  final double growthRate;
  final double progress;

  const RevenueSummary({
    required this.totalRevenue,
    required this.onlineRevenue,
    required this.walkinRevenue,
    required this.monthlyTarget,
    required this.growthRate,
    required this.progress,
  });

  factory RevenueSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return RevenueSummary(
      totalRevenue:
          (json['totalRevenue'] ?? 0).toDouble(),
      onlineRevenue:
          (json['onlineRevenue'] ?? 0).toDouble(),
      walkinRevenue:
          (json['walkinRevenue'] ?? 0).toDouble(),
      monthlyTarget:
          (json['monthlyTarget'] ?? 0).toDouble(),
      growthRate:
          (json['growthRate'] ?? 0).toDouble(),
      progress:
          (json['progress'] ?? 0).toDouble(),
    );
  }
}

class DashboardSummary {
  final double target;
  final double current;
  final double progress;

  final int customers;
  final int sales;
  final double revenue;

  const DashboardSummary({
    required this.target,
    required this.current,
    required this.progress,
    required this.customers,
    required this.sales,
    required this.revenue,
  });

  factory DashboardSummary.fromJson(
    Map<String, dynamic> json,
  ) {

    final dailyTarget = json['daily_target'];

    return DashboardSummary(
      target: (dailyTarget['target'] ?? 0).toDouble(),
      current: (dailyTarget['current'] ?? 0).toDouble(),
      progress: (dailyTarget['progress'] ?? 0).toDouble(),
      customers: json['customers'] ?? 0,
      sales: json['sales'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}