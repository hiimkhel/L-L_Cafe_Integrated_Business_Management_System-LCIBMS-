import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/config/theme/app_text_styles.dart';
import 'status_chip.dart';
import 'action_button.dart';

class OrderRow extends StatefulWidget {
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
    required this.onActionPressed,
  });

  @override
  State<OrderRow> createState() => _OrderRowState();
}

class _OrderRowState extends State<OrderRow> {
  bool _expanded = false;

  String getTimeAgo(String updatedAt) {
    final updatedTime = DateTime.parse(updatedAt).toLocal();
    final now = DateTime.now();
    final diff = now.difference(updatedTime);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hr ago";
    return "${diff.inDays} day(s) ago";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          left: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _orderId()),
          Expanded(flex: 3, child: Text(widget.customer, style: AppTextStyles.body)),
          Expanded(flex: 5, child: _items()),
          Expanded(flex: 3, child: _time()),
          Expanded(flex: 3, child: _actions()),
        ],
      ),
    );
  }

  Widget _orderId() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.15),
              AppColors.secondary.withOpacity(0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              widget.id,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _items() {
    const int maxVisible = 2;

    final items = widget.items;
    final visibleItems =
        _expanded ? items : items.take(maxVisible).toList();

    final remaining = items.length - maxVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...visibleItems.map(
          (item) => Text(
            item,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body,
          ),
        ),

        if (remaining > 0)
          GestureDetector(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _expanded ? "Show less" : "+$remaining more",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _time() {
    final elapsed = getTimeAgo(widget.time);

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
    if (widget.status == "ready") {
      return ActionButton(
        label: "HAND OVER",
        isPrimary: true,
        onPressed: () {
          print("Handing over...");
        },
      );
    }

    return ActionButton(
      label: "MARK AS READY",
      onPressed: widget.onActionPressed,
    );
  }
}