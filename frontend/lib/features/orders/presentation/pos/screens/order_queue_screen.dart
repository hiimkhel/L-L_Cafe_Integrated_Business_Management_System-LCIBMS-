import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/features/orders/presentation/pos/widgets/header_bar.dart';
import 'package:frontend/features/orders/presentation/pos/widgets/order_table.dart';
import 'package:frontend/core/services/pos/order_service.dart';

class OrderQueueScreen extends StatelessWidget {
  OrderQueueScreen({super.key});

  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<int>(
        future: _orderService.getPreparingCount(),
        builder: (context, snapshot) {
          final preparingCount = snapshot.data ?? 0;

          return Column(
            children: [
              HeaderBar(
                title: "ORDER QUEUE",
                preparingCount: preparingCount,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: OrderTable(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}