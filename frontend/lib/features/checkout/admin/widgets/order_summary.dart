import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_text_styles.dart';
import 'package:frontend/config/theme/app_colors.dart';

class OrderSummary extends StatelessWidget {
  final List<Map<String, dynamic>> orderItems;
  final double subtotal;
  final double total;
  final String orderType;

  const OrderSummary({
    super.key,
    required this.orderItems,
    required this.subtotal,
    required this.total,
    required this.orderType
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Reduced from 32 for better tablet support
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.receipt_long, size: 26, color: AppColors.secondary),
              ),
              const SizedBox(width: 16),
              const Expanded(child: Text("ORDER SUMMARY", style: AppTextStyles.title)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)]
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(orderType.toUpperCase().contains('DINE') ? Icons.restaurant : Icons.shopping_bag, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(orderType.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: orderItems.length,
                      itemBuilder: (context, index) {
                        final item = orderItems[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.receiptBg, width: 1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36, alignment: Alignment.center,
                                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                                child: Text("${item["qty"]}x", style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item["name"], style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    Text("₱${(item["price"] as double).toStringAsFixed(2)}", style: AppTextStyles.body.copyWith(color: AppColors.tertiary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text("₱${((item["price"] as double) * (item["qty"] as int)).toStringAsFixed(2)}", style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.receiptBg, width: 2))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("GRAND TOTAL", style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w900)),
                        Text("₱${total.toStringAsFixed(2)}", style: AppTextStyles.title.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}