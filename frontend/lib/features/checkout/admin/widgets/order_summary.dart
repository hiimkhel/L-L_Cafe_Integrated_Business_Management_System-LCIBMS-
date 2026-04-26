import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_text_styles.dart';
import 'package:frontend/config/theme/app_colors.dart';

class OrderSummary extends StatelessWidget {
  final List<Map<String, dynamic>> orderItems;
  final double subtotal;
  final double tax;
  final double total;
  final String orderType;

  const OrderSummary({
    super.key,
    required this.orderItems,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.orderType
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER OUTSIDE CARD
          
          Row(
            children: [
              const SizedBox(width: 20),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  size: 30,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 20),
              const Text(
                "ORDER SUMMARY",
                style: AppTextStyles.title,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // CARD
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 42.00, horizontal: 36.00),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          orderType == 'DINE IN'
                              ? Icons.restaurant
                              : Icons.shopping_bag,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          orderType,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Scrollable Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: orderItems.length,
                      itemBuilder: (context, index) {
                        final item = orderItems[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.receiptBg,
                                width: 1.5
                              )
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text("${index + 1}", style: AppTextStyles.subtitle.copyWith(color: AppColors.primary)),
                              ),
                              const SizedBox(width: 20),
                              Expanded(child: Text(item["name"], style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600))),
                              Text(
                                "₱${item["price"].toStringAsFixed(2)}", style: AppTextStyles.subtitle.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600)
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: AppColors.receiptBg, thickness: 1.5),
                  const SizedBox(height: 16),

                  _priceRow("Subtotal", subtotal),
                  const SizedBox(height: 8),
                  _priceRow("Tax (12%)", tax),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.receiptBg, width: 1.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "GRAND TOTAL",
                          style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          "₱${total.toStringAsFixed(2)}",
                          style: AppTextStyles.title.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w900)
                        ),
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

  // Helper
  Widget _priceRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.subtitle.copyWith(color: AppColors.tertiary)),
        Text("₱${value.toStringAsFixed(2)}", style: AppTextStyles.subtitle.copyWith(color: AppColors.tertiary)),
      ],
    );
  }
}