import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/features/orders/presentation/pos/widgets/header_bar.dart';
import 'package:frontend/features/orders/presentation/pos/widgets/order_table.dart';

class OrderQueueScreen extends StatelessWidget {
  const OrderQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const HeaderBar(title: "ORDER QUEUE"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: OrderTable(),
            ),
          ),
        ],
      ),
    );
  }
}