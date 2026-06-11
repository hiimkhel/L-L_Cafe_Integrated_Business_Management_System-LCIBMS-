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
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.receipt_long_rounded, size: 24, color: AppColors.secondary),
              ),
              const SizedBox(width: 16),
              const Expanded(child: Text("Order Summary", style: AppTextStyles.title)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.tertiary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  // Order Type Badge
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(orderType.toUpperCase().contains('DINE') ? Icons.restaurant : Icons.shopping_bag_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(orderType.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ),
                  
                  // Item List
                  Expanded(
                    child: ListView.separated(
                      itemCount: orderItems.length,
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(color: AppColors.tertiary.withOpacity(0.1), thickness: 1),
                      ),
                      itemBuilder: (context, index) {
                        final item = orderItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 32, height: 32, alignment: Alignment.center,
                                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                                child: Text("${item["qty"]}", style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item["name"], style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w800, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    Text("₱${(item["price"] as double).toStringAsFixed(2)} each", style: AppTextStyles.body.copyWith(color: AppColors.tertiary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text("₱${((item["price"] as double) * (item["qty"] as int)).toStringAsFixed(2)}", style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Totals
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("GRAND TOTAL", style: AppTextStyles.title.copyWith(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                        Text("₱${total.toStringAsFixed(2)}", style: AppTextStyles.title.copyWith(fontSize: 24, color: AppColors.secondary, fontWeight: FontWeight.w900)),
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