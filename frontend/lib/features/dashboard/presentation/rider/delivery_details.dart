import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/services/rider/order_service.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  final int orderId;
  final Map<String, dynamic> order;

  const DeliveryDetailsScreen({super.key, required this.order,required this.orderId});

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  final OrderService _orderService = OrderService();
  late Future<Map<String, dynamic>> _orderFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _orderFuture = _orderService.fetchOrderDetails(widget.orderId);
    });
  }

  void _handleStatusUpdate(String currentStatus) async {
    String nextStatus = '';
    if (currentStatus == 'PREPARING') nextStatus = 'ready';
    else if (currentStatus == 'READY') nextStatus = 'out_for_delivery';
    else if (currentStatus == 'OUT_FOR_DELIVERY') nextStatus = 'completed';


    if (nextStatus.isEmpty) return;

    bool success = await _orderService.updateOrderStatus(widget.orderId, nextStatus);
    
    if (success) {
      _refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status updated to ${nextStatus.replaceAll('_', ' ').toUpperCase()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No order found"));
          }

          final order = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(13),
            child: Column(
              children: [
                _deliveryHeader(order),
                Divider(thickness: 1, color: AppColors.primary),
                const SizedBox(height: 10),
                _customer(),
                const SizedBox(height: 7),
                _customerDetails(order),
                const SizedBox(height: 15),
                _order(),
                const SizedBox(height: 7),
                _orderDetails(order),
                const SizedBox(height: 15),
                _progress(),
                const SizedBox(height: 15),
                _markReady(order['status']),
                const SizedBox(height: 15),
                _contactCustomer(),
                const SizedBox(height: 15),
                _reportIssue(),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _deliveryHeader(Map<String, dynamic> order) {
    Color statusColor;
    String status = order['status'];

    if (status == "PREPARING") statusColor = AppColors.preparingColor;
    else if (status == "OUT_FOR_DELIVERY") statusColor = AppColors.deliveringColor;
    else if (status == "COMPLETED") statusColor = Colors.green;
    else if (status == "DELIVERED") statusColor = AppColors.deliveredColor;
    else statusColor = Colors.grey;

    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 20, 15, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [BoxShadow(color: AppColors.receiptDark.withOpacity(.5), offset: const Offset(0, 4), blurRadius: 3)],
              ),
              child: Icon(Icons.arrow_back, color: AppColors.primary, size: 19),
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DETAILS', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 21)),
              Text('ORDER ${order["id"]}', style: TextStyle(color: AppColors.primary, fontSize: 10, letterSpacing: 1.7)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, size: 12, color: AppColors.white.withOpacity(0.4)),
                const SizedBox(width: 5),
                Text(status, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerDetails(Map<String, dynamic> order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoTile(Icons.person_2_outlined, 'NAME', order['name'], AppColors.secondary),
          const SizedBox(height: 15),
          _infoTile(Icons.call_outlined, 'PHONE', '+${order['phone'] ?? 'N/A'}', AppColors.primary),
          const SizedBox(height: 15),
          _infoTile(Icons.place_outlined, 'ADDRESS', order['delivery_address'] ?? 'No Address', AppColors.receiptDark),
          const SizedBox(height: 18),
          _notesBox(order['notes'] ?? 'No special instructions'),
        ],
      ),
    );
  }

  Widget _orderDetails(Map<String, dynamic> order) {
    final List items = (order['items'] ?? order['order'] ?? []) as List;
    double deliveryFee =
    double.tryParse(order['deliveryFee']?.toString() ?? "0") ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.access_time_outlined, color: AppColors.secondary, size: 22),
              const SizedBox(width: 10),
              Text(order['time'] ?? 'Just now',
                  style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(),

          ...items.asMap().entries.map((entry) {
            final item = entry.value;

            double price = double.tryParse(item['price']?.toString() ?? "0") ?? 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text("${entry.key + 1}",
                        style: TextStyle(fontSize: 12, color: AppColors.primary)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? 'Item',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${item['qty'] ?? 1}x",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text('₱${price.toStringAsFixed(2)}'),
                ],
              ),
            );
          }),

          const Divider(),

          Builder(builder: (context) {
            double subtotal =
                double.tryParse(order['subtotal']?.toString() ?? "0") ?? 0.0;

            double deliveryFee =
                double.tryParse(order['delivery_fee']?.toString() ?? "0") ?? 0.0;

            double total =
                double.tryParse(order['total']?.toString() ?? "0") ?? 0.0;

            return Column(
              children: [
                _priceRow('SUBTOTAL', '₱${subtotal.toStringAsFixed(2)}'),
                const SizedBox(height: 5),
                _priceRow('DELIVERY FEE', '₱${deliveryFee.toStringAsFixed(2)}'),
                const Divider(),
                _priceRow(
                  'TOTAL',
                  '₱${total.toStringAsFixed(2)}',
                  isBold: true,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _markReady(String status) {
    String buttonText = "MARK AS READY";
    if (status == "READY") buttonText = "START DELIVERY";
    if (status == "OUT_FOR_DELIVERY") buttonText = "COMPLETE DELIVERY";

    if (status == "COMPLETED") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.green.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "COMPLETED",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
          ],
        ),
      );
    }


    return GestureDetector(
      onTap: () => _handleStatusUpdate(status),
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: AppColors.receiptDark, offset: const Offset(4, 4))],
        ),
        child: Text(buttonText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
      ),
    );
  }

  // --- Reusable UI Helpers to keep it clean ---
  
  BoxDecoration _cardDecoration() => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(color: AppColors.receiptDark.withOpacity(.2), offset: const Offset(0, 2), blurRadius: 4)],
  );

  Widget _infoTile(IconData icon, String label, String value, Color color) => Row(
    children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 24)),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.receiptDark, fontSize: 15)),
      ]),
    ],
  );

  Widget _notesBox(String note) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.secondary.withOpacity(0.2))),
    child: Column(children: [
      Row(children: [Icon(Icons.info_outline, color: AppColors.secondary, size: 18), const SizedBox(width: 8), const Text('NOTES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]),
      const SizedBox(height: 4),
      Text(note, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _priceRow(String label, String value, {bool isBold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
      Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
    ],
  );

  // Remaining Static Widgets (The ones that don't need data)
  Widget _customer() => _sectionHeader(Icons.person_2_outlined, 'CUSTOMER', AppColors.secondary);
  Widget _order() => _sectionHeader(Icons.inventory_2_outlined, 'ORDER', AppColors.primary);
  Widget _progress() => _sectionHeader(Icons.local_shipping_outlined, 'PROGRESS', AppColors.secondary);
  
  Widget _sectionHeader(IconData icon, String title, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 24)),
      const SizedBox(width: 14),
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    ]),
  );

  Widget _contactCustomer() => _actionButton('CONTACT CUSTOMER', AppColors.primary);
  Widget _reportIssue() => _actionButton('REPORT ISSUE', AppColors.primary);

  Widget _actionButton(String text, Color color) => Container(
    alignment: Alignment.center,
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: AppColors.receiptDark, offset: const Offset(4, 4))]),
    child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  );
}