import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_text_styles.dart';
import 'package:frontend/config/theme/app_colors.dart';

class OrderSummary extends StatelessWidget {
  final List<Map<String, dynamic>> orderItems;
  final double subtotal;
  final double total;
  final String orderType;
  final bool isStacked; 

  const OrderSummary({
    super.key,
    required this.orderItems,
    required this.subtotal,
    required this.total,
    required this.orderType,
    this.isStacked = false,
  });

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shrinkWrap: isStacked,
      physics: isStacked ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      itemCount: orderItems.length,
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Divider(color: AppColors.tertiary.withOpacity(0.1), thickness: 1),
      ),
      itemBuilder: (context, index) {
        final item = orderItems[index];
        final price = (item["price"] as num).toDouble();
        final qty = (item["qty"] as num).toInt();
        final itemTotal = price * qty;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("${qty}x", style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Item Name
                    Text(
                      item["name"].toString().toUpperCase(),
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),

                    // Variant
                    if (item["variant_name"] != null) ...[
                      const SizedBox(height: 3),

                      Text(
                        "${item["variant_category"]} • ${item["variant_name"]}",
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    // Flavor Badges
                    if (item["flavors"] != null &&
                        (item["flavors"] as List).isNotEmpty) ...[
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: (item["flavors"] as List)
                            .map((flavor) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.secondary.withOpacity(.35),
                                  ),
                                ),
                                child: Text(
                                  flavor.flavorName,
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 5),

                    Text(
                      "@ ₱${price.toStringAsFixed(2)}",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.tertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text("₱${itemTotal.toStringAsFixed(2)}", style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: isStacked ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // Clean Header
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, size: 24, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Text("Order Summary", style: AppTextStyles.title.copyWith(fontSize: 18, color: AppColors.primary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    orderType.toUpperCase(), 
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondary, letterSpacing: 0.5)
                  ),
                ),
              ],
            ),
          ),
          
          Divider(height: 1, color: AppColors.tertiary.withOpacity(0.05)),
          
          // Render ListView correctly based on bounds
          if (isStacked) _buildList(context) else Expanded(child: _buildList(context)),
          
          Divider(height: 1, color: AppColors.tertiary.withOpacity(0.05)),

          // Clean Totals Section (No harsh background colors)
          Container(
            padding: const EdgeInsets.all(28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("GRAND TOTAL", style: AppTextStyles.title.copyWith(fontSize: 14, color: AppColors.tertiary, letterSpacing: 1.0)),
                Text("₱${total.toStringAsFixed(2)}", style: AppTextStyles.title.copyWith(fontSize: 28, color: AppColors.secondary, fontWeight: FontWeight.w900)),
              ],
            ),
          )
        ],
      ),
    );
  }
}