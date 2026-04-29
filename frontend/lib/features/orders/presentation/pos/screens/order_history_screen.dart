import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/features/orders/presentation/pos/widgets/header_bar2.dart';
import 'package:frontend/features/orders/presentation/pos/widgets/order_table2.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const HeaderBar2(title: "ORDER HISTORY"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: OrderTable2(),
            ),
          ),
        ],
      ),
    );
  }
}