import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/config/theme/app_colors.dart';

class OrderRow2 extends StatelessWidget {
  final String orderId;
  final String customerName;
  final int itemCount;
  final String paymentType;
  final double total;
  final String time;
  final Map<String, dynamic> fullOrderData;

  const OrderRow2({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.itemCount,
    required this.paymentType,
    required this.total,
    required this.time,
    required this.fullOrderData,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showReceiptDialog(context), // Clicking the row now also opens the receipt
      hoverColor: AppColors.primary.withOpacity(0.02), // Subtle hint of color on hover
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.08), width: 1),
          ),
        ),
        child: Row(
          children: [
            // 1. TIME
            Expanded(
              flex: 2,
              child: Text(
                _formatDateTime(time),
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
              ),
            ),

            // 2. CUSTOMER NAME
            Expanded(
              flex: 3,
              child: Text(
                customerName,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 3. ORDER ID
            Expanded(
              flex: 3,
              child: UnconstrainedBox(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    orderId,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // 4. ITEM COUNT
            Expanded(
              flex: 2,
              child: Text(
                "$itemCount item${itemCount == 1 ? '' : 's'}",
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
              ),
            ),

            // 5. PAYMENT TYPE
            Expanded(
              flex: 2,
              child: UnconstrainedBox(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    paymentType.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // 6. TOTAL
            Expanded(
              flex: 2,
              child: Text(
                "₱${total.toStringAsFixed(2)}",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 7. ACTION (Receipt Icon + Text)
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "View Receipt",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String value) {
    if (value.isEmpty) return "-";
    try {
      final dateTime = DateTime.parse(value).toLocal();
      return DateFormat('MMM d, h:mm a').format(dateTime);
    } catch (_) {
      return value;
    }
  }

  void _showReceiptDialog(BuildContext context) {
    final order = fullOrderData;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.receipt_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                "Receipt Details",
                style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _receiptRow("Order #", order['order_number'] ?? orderId),
                      _receiptRow("Customer", order['customer_name'] ?? 'Walk-in'),
                      _receiptRow("Type", (order['order_type'] ?? 'N/A').toString().toUpperCase()),
                      _receiptRow("Method", (order['payment_method'] ?? 'N/A').toString().toUpperCase()),
                      const Divider(height: 24),
                      _receiptRow("Subtotal", "₱${_toDouble(order['subtotal']).toStringAsFixed(2)}"),
                      _receiptRow("Delivery", "₱${_toDouble(order['delivery_fee']).toStringAsFixed(2)}"),
                      const SizedBox(height: 8),
                      _receiptRow(
                        "Total Amount",
                        "₱${_toDouble(order['total']).toStringAsFixed(2)}",
                        isBold: true,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: TextStyle(color: AppColors.secondary)),
            ),
            ElevatedButton(
              onPressed: () {}, // Future Print Logic
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Print Receipt"),
            ),
          ],
        );
      },
    );
  }

  Widget _receiptRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 16 : 14,
              color: color ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  double _toDouble(dynamic value) => double.tryParse(value.toString()) ?? 0.0;
}