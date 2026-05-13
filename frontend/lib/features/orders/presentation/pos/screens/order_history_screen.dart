import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/features/orders/presentation/pos/widgets/header_bar2.dart';
import 'package:frontend/features/orders/presentation/pos/widgets/order_table2.dart';
import 'package:frontend/core/services/pos/order_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // Use a GlobalKey or pass a callback to trigger the search
  final GlobalKey<OrderTable2State> _tableKey = GlobalKey<OrderTable2State>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          HeaderBar2(
            title: "ORDER HISTORY",
            onFilterChanged: (query, dateFilter, {customRange}) {
              _tableKey.currentState?.applyFilters(
                query, 
                dateFilter, 
                customRange: customRange
              );
            },
            onExport: () {
              // You can implement CSV export here
              print("Exporting data for: ${_tableKey.currentState?.currentSearch}");
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: OrderTable2(key: _tableKey), // Pass the key here
            ),
          ),
        ],
      ),
    );
  }
}