// order_row2.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // TIME
          Expanded(
            flex: 2,
            child: Text(
              _formatDateTime(time),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // CUSTOMER NAME
          Expanded(
            flex: 3,
            child: Text(
              customerName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ORDER ID
          Expanded(
            flex: 3,
            child: Text(
              orderId,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // ITEM COUNT
          Expanded(
            flex: 2,
            child: Text(
              "$itemCount item${itemCount == 1 ? '' : 's'}",
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // PAYMENT TYPE
          Expanded(
            flex: 2,
            child: Text(
              paymentType,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // TOTAL
          Expanded(
            flex: 2,
            child: Text(
              "₱${total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ACTION BUTTON
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _showReceiptDialog(context),
                child: const Text("View Receipt"),
              ),
            ),
          ),
        ],
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
          title: Text("Receipt - ${order['order_number'] ?? orderId}"),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _receiptRow(
                    "Customer",
                    order['customer_name'] ?? 'Walk-in Customer',
                  ),
                  _receiptRow(
                    "Order Type",
                    order['order_type'] ?? 'N/A',
                  ),
                  _receiptRow(
                    "Payment",
                    order['payment_method'] ?? 'N/A',
                  ),
                  _receiptRow(
                    "Status",
                    order['status'] ?? 'N/A',
                  ),
                  _receiptRow(
                    "Subtotal",
                    "₱${_toDouble(order['subtotal']).toStringAsFixed(2)}",
                  ),
                  _receiptRow(
                    "Delivery Fee",
                    "₱${_toDouble(order['delivery_fee']).toStringAsFixed(2)}",
                  ),
                  const Divider(),
                  _receiptRow(
                    "Total",
                    "₱${_toDouble(order['total']).toStringAsFixed(2)}",
                    isBold: true,
                  ),
                  if (order['notes'] != null &&
                      order['notes'].toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "Notes:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(order['notes']),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _receiptRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight:
                    isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight:
                  isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  double _toDouble(dynamic value) {
    return double.tryParse(value.toString()) ?? 0.0;
  }
}