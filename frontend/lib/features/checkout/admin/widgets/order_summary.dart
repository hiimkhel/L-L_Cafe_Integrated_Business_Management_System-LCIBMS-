import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';

class OrderSummary extends StatelessWidget {
  final List<Map<String, dynamic>> orderItems;
  final double subtotal;
  final double tax;
  final double total;

  const OrderSummary({
    super.key,
    required this.orderItems,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER OUTSIDE CARD
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  size: 20,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "ORDER SUMMARY",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // CARD
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Scrollable Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: orderItems.length,
                      itemBuilder: (context, index) {
                        final item = orderItems[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text("${index + 1}"),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(item["name"])),
                              Text(
                                "₱${item["price"].toStringAsFixed(2)}",
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(),

                  _priceRow("Subtotal", subtotal),
                  _priceRow("Tax (12%)", tax),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "GRAND TOTAL",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "₱${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
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
        Text(label),
        Text("₱${value.toStringAsFixed(2)}"),
      ],
    );
  }
}