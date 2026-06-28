import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/features/orders/presentation/pos/widgets/order_row.dart';
import 'package:frontend/core/services/pos/order_service.dart';

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
                            onActionPressed: () => _updateOrder(order),
                  
                          );
                        },
                      ),
          ),
        ],
      ),
    );
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