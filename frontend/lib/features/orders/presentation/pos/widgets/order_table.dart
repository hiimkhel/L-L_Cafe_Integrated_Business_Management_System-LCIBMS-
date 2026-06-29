import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/features/orders/presentation/pos/widgets/order_row.dart';
import 'package:frontend/core/services/pos/order_service.dart';
import 'package:frontend/features/dashboard/presentation/pos/order_entry.dart';
import 'package:frontend/core/constants/cart_provider.dart';

class OrderTable extends StatefulWidget {
  final VoidCallback? onOrderUpdated;

  const OrderTable({super.key, required this.onOrderUpdated});

  @override
  State<OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<OrderTable> {
  final OrderService _orderService = OrderService();
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _editOrder(Map<String, dynamic> order) async {
    print("============== THIS IS THE ORDER ===================");
    print(order);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => POSOrderScreen(
          editingOrder: order,
        ),
      ),
    );
  }

  Future<void> _cancelOrder(Map<String, dynamic> order) async {
    final success = await _orderService.updateOrderStatus(
      order["id"],
      "cancelled",
    );

    if (!mounted) return;

    if (success) {
      _fetchOrders(); // refresh queue

      widget.onOrderUpdated?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order has been cancelled"),
        ),
      );
    }
  }

  
  Future<void> _updateOrder(dynamic order) async {
    final String orderSource = order['source'] ?? '';

    String nextStatus;

    if (orderSource == 'pos') {
      nextStatus = 'completed';
    } else {
      nextStatus = 'ready';
    }

    final success = await _orderService.updateOrderStatus(
      order['id'],
      nextStatus,
    );

    if (!mounted) return;

    if (success) {
      await _fetchOrders();
      widget.onOrderUpdated?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextStatus == 'completed'
                ? 'Order completed!'
                : 'Order marked as ready!',
          ),
        ),
      );
    }
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final data = await _orderService.getOrdersByStatus('preparing');
    setState(() {
      _orders = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _header(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? const Center(child: Text("No orders in preparation"))
                    : ListView.builder(
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          print("Order #${order['order_number']}");
                          print("Source: ${order['source']}");
                          print("Status: ${order['status']}");
                         
                          return OrderRow(
                            id: "#${order['order_number']}",
                            customer: order['customer_name'] ?? "Guest",
                            items: List<Map<String, dynamic>>.from(order['items']),
                            status: order['status'],
                            time: order['updated_at'], 
                            actionText: order['source'] == 'pos'
                              ? 'COMPLETE'
                              : 'READY',
                            onModifyPressed: () => _showModifyDialog(order),
                            onActionPressed: () => _updateOrder(order),
                  
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showModifyDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Modify Order"),

          content: Text(
            "What would you like to do?"
          ),

          actions: [

            TextButton(
              onPressed: () {

                Navigator.pop(context);

                _editOrder(order);

              },
              child: const Text("Edit"),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmCancel(order);
              },
              child: const Text(
                "Cancel Order",
                style: TextStyle(color: Colors.red),
              ),
            ),

          ],
        );
      },
    );
  }

  Future<void> _confirmCancel(Map<String, dynamic> order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel Order?"),
        content: Text(
          "Are you sure you want to cancel Order #${order['order_number']}?\n\nThe order will be removed from the preparation queue and marked as cancelled."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Keep Order"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _cancelOrder(order);
    }
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: _HeaderText("ORDER ID"),
          ),
          Expanded(
            flex: 3,
            child: _HeaderText("CUSTOMER"),
          ),
          Expanded(
            flex:4,
            child: _HeaderText("ITEMS"),
          ),
          Expanded(
            flex: 3,
            child: _HeaderText("TIME"),
          ),
          Expanded(
            flex: 2,
            child: _HeaderText("ACTION"),
          ),
        ],
      ),
    );
  }
}


class _HeaderText extends StatelessWidget {
  final String text;

  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.secondary,
        letterSpacing: 1.2,
      ),
    );
  }
}