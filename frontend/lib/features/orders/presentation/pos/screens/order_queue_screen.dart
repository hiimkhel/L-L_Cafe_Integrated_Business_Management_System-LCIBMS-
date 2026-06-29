import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/features/orders/presentation/pos/widgets/header_bar.dart';
import 'package:frontend/features/orders/presentation/pos/widgets/order_table.dart';
import 'package:frontend/core/services/pos/order_service.dart';
import 'package:frontend/core/constants/cart_provider.dart';

class OrderQueueScreen extends StatefulWidget {
  const OrderQueueScreen({super.key});

  @override
  State<OrderQueueScreen> createState() => _OrderQueueScreenState();
}

class _OrderQueueScreenState extends State<OrderQueueScreen> {
  int preparingCount = 0;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _loadPreparingCount();
  }

  Future<void> _loadPreparingCount() async {
    try {
      final count = await _orderService.getPreparingCount();

      if (!mounted) return;

      setState(() {
        preparingCount = count;
      });
    } catch (e) {
      debugPrint("Failed to load preparing count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
                  child: OrderTable(onOrderUpdated: _loadPreparingCount),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}