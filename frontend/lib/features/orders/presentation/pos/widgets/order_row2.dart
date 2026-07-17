import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/services/pos/order_service.dart';

class OrderRow2 extends StatelessWidget {
  final int orderDbId;

  final String orderId;
  final String customerName;
  final int itemCount;
  final String paymentType;
  final double total;
  final String time;

  const OrderRow2({
    super.key,
    required this.orderDbId,
    required this.orderId,
    required this.customerName,
    required this.itemCount,
    required this.paymentType,
    required this.total,
    required this.time,
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
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 8),
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
                  fontSize: 9,
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
                      fontSize: 9,
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
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 9),
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
                      fontSize: 9,
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
                  fontSize: 9,
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
                        "View",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
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

  Future<void> _showReceiptDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: OrderService().getOrderById(orderDbId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const SizedBox(
                  width: 420,
                  height: 250,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return AlertDialog(
                title: const Text("Unable to load receipt"),
                content: const Text(
                  "An error occurred while loading the order details.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  )
                ],
              );
            }

            final order = snapshot.data!;
            print("========== RECEIPT ==========");
            print(order);
            print(order["items"]);

            final List items =
                List<Map<String, dynamic>>.from(order["items"] ?? []);

            return _buildReceiptDialog(
              context,
              order,
              items,
            );
          },
        );
      },
    );
  }

  Widget _buildReceiptDialog(
    BuildContext context,
    Map<String, dynamic> order,
    List items,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            _buildReceiptHeader(),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    _buildReceiptInfo(order),

                    const SizedBox(height: 20),

                    _buildItemsSection(items),

                    const Divider(),

                    _buildTotals(order),

                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.print),
                      label: const Text("Print"),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Receipt Details",
                  style: TextStyle(
                    fontFamily: "Urbanist",
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  "Complete order information",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptInfo(Map<String, dynamic> order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [

          _receiptInfoRow(
            Icons.confirmation_number_outlined,
            "Order #",
            order["order_number"] ?? "-",
          ),

          const SizedBox(height: 12),

          _receiptInfoRow(
            Icons.person_outline,
            "Customer",
            order["customer_name"] ?? "Walk-in",
          ),

          const SizedBox(height: 12),

          _receiptInfoRow(
            Icons.payments_outlined,
            "Payment",
            (order["payment_method"] ?? "-")
                .toString()
                .toUpperCase(),
          ),

          const SizedBox(height: 12),

          _receiptInfoRow(
            Icons.schedule,
            "Date",
            _formatDateTime(order["created_at"] ?? ""),
          ),
        ],
      ),
    );
  }

  Widget _receiptInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [

        Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),

        const SizedBox(width: 12),

        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(List items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            "No items found.",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [

            Icon(
              Icons.restaurant_menu_rounded,
              color: AppColors.primary,
            ),

            const SizedBox(width: 8),

            const Text(
              "Ordered Items",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                fontFamily: "Urbanist",
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildReceiptItemCard(item),
            )),
      ],
    );
  }

  Widget _buildReceiptItemCard(Map<String, dynamic> item) {

    final List flavors =
        List<Map<String, dynamic>>.from(item["flavors"] ?? []);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Expanded(
                child: Text(
                  item["name"] ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: "Urbanist",
                  ),
                ),
              ),

              Text(
                "x${item["qty"]}",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          if ((item["variant_name"] ?? "").toString().isNotEmpty) ...[

            const SizedBox(height: 10),

            _buildVariantChip(item["variant_name"]),

          ],

          if (flavors.isNotEmpty) ...[

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: flavors.map<Widget>((flavor) {

                return Chip(
                  label: Text(
                    flavor["flavor_name"] ?? "",
                  ),
                  backgroundColor:
                      AppColors.secondary.withOpacity(0.15),
                  side: BorderSide.none,
                  labelStyle: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                );

              }).toList(),
            ),
          ],

          const SizedBox(height: 14),

          const Divider(),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [

              Text(
                "₱${_toDouble(item["price"]).toStringAsFixed(2)} × ${item["qty"]}",
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),

              Text(
                "₱${_toDouble(item["subtotal"]).toStringAsFixed(2)}",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariantChip(String variant) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            Icons.sell_outlined,
            size: 16,
            color: AppColors.primary,
          ),

          const SizedBox(width: 6),

          Text(
            variant,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals(Map<String, dynamic> order) {
  final double total = double.tryParse((order['total'] ?? order['total_amount'] ?? '0').toString()) ?? 0.0;
  final double subtotal = double.tryParse((order['subtotal'] ?? '0').toString()) ?? total; 
  final double delivery = double.tryParse((order['delivery_fee'] ?? '0').toString()) ?? 0.0;

  return Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),
    child: Column(
      children: [

        if (delivery > 0) ...[
          const SizedBox(height: 10),

          _buildTotalRow(
            "Delivery Fee",
            delivery,
          ),
        ],

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Divider(height: 1),
        ),

        Row(
          children: [

            const Expanded(
              child: Text(
                "TOTAL",
                style: TextStyle(
                  fontFamily: "Urbanist",
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),

            Text(
              "₱${total.toStringAsFixed(2)}",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildTotalRow(
  String label,
  double amount,
) {
  return Row(
    children: [

      Expanded(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      Text(
        "₱${amount.toStringAsFixed(2)}",
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

  double _toDouble(dynamic value) => double.tryParse(value.toString()) ?? 0.0;
}