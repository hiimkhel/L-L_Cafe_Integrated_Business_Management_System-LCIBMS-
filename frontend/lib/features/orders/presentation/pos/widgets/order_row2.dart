import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/config/theme/app_text_styles.dart';

class OrderRow2 extends StatelessWidget {
  final String id;
  final String customer;
  final List<String> items;
  final String time;

  const OrderRow2({
    super.key,
    required this.id,
    required this.customer,
    required this.items,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _orderId(),
              ),
            ),
          Expanded(flex: 3, child: Text(customer, style: AppTextStyles.body)),
          Expanded(flex: 4, child: _items()),
          Expanded(flex: 3, child: _time()),
          
        ],
      ),
    );
  }

  Widget _orderId() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(id, style: AppTextStyles.body),
    );
  }

  Widget _items() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Text(item, style: AppTextStyles.body))
          .toList(),
    );
  }

  Widget _time() {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 16),
        const SizedBox(width: 4),
        Text(time, style: AppTextStyles.body),
      ],
    );
  }
}