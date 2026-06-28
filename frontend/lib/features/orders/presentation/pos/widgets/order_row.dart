import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'action_button.dart';
import 'package:frontend/core/models/flavor_models.dart';

class OrderRow extends StatefulWidget {
  final String id;
  final String customer;
  final List<Map<String, dynamic>> items;
  final String status;
  final String time;
  final String actionText;
  final VoidCallback onActionPressed;

  const OrderRow({
    super.key,
    required this.id,
    required this.customer,
    required this.items,
    required this.status,
    required this.time,
    required this.onActionPressed, required  this.actionText,
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
          Expanded(flex: 3, child: _customer()),
          Expanded(flex: 4, child: _items()),
          Expanded(flex: 3, child: _time()),
          Expanded(flex: 2, child: _actions()),
        ],
      ),
    );
  }

  Widget _customer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.customer,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
      ],
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
    final visibleItems = _expanded
        ? items
        : items.take(maxVisible).toList();

    final remaining = items.length - maxVisible;

    return Padding(
      
      padding: const EdgeInsets.only(right: 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...visibleItems.map((item) {

            final itemName = item["name"];

            final quantity = item["qty"].toString();

            final variant = item["variant_name"];

            final flavors = (item["flavors"] as List?)
                ?.map((e) => Flavor.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [];

            final flavorNames = flavors
              .map((f) => f.flavorName)
              .toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Item name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          itemName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),

                        if (variant != null || flavors.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              [
                                if (variant != null) variant,
                                if (flavors.isNotEmpty) flavorNames.join(", "),
                              ].join(" • "),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Quantity badge
                  if (quantity != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      constraints: const BoxConstraints(
                        minWidth: 32,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.20),
                        ),
                      ),
                      child: Text(
                        "x$quantity",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          // Expand / Collapse
          if (remaining > 0)
            GestureDetector(
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 4, left: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _expanded ? "Show less" : "+$remaining more",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
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
              color: AppColors.textDark,
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

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: widget.onActionPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            elevation: 4,
            shadowColor: AppColors.secondary.withOpacity(0.35),
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: 15,
                color: Colors.white,
              ),
              const SizedBox(width: 5),
              Text(
                widget.actionText,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}