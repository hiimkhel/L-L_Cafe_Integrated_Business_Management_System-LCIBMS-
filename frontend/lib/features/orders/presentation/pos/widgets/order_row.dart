import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/config/theme/app_text_styles.dart';
import 'status_chip.dart';
import 'action_button.dart';

class OrderRow extends StatelessWidget {
  final String id;
  final String customer;
  final List<String> items;
  final String status;
  final String time;
  final VoidCallback onActionPressed;

  const OrderRow({
    super.key,
    required this.id,
    required this.customer,
    required this.items,
    required this.status,
    required this.time,
    required this.onActionPressed
  });

  String getTimeAgo(String updatedAt) {
    final updatedTime = DateTime.parse(updatedAt).toLocal();
    final now = DateTime.now();

    final diff = now.difference(updatedTime);

    if (diff.inMinutes < 1) {
      return "Just now";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hr ago";
    } else {
      return "${diff.inDays} day(s) ago";
    }
  }
  
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
          Expanded(
            flex: 3, 
              child: Align(
                alignment: Alignment.centerLeft,
                child:StatusChip(status: status)
              ),
            ),
          Expanded(flex: 3, child: _time()),
          Expanded(flex: 3, child: _actions()),
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
    final elapsed = getTimeAgo(time);

    return Row(
      children: [
        const Icon(Icons.schedule, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            elapsed,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actions() {
    if (status == "ready") {
      return ActionButton(label: "HAND OVER", isPrimary: true, onPressed: () {
        // You can handle "Completed" status here later
        print("Handing over...");
      },
    );
    }
    return ActionButton(label: "MARK AS READY", onPressed: onActionPressed,);
  }
}