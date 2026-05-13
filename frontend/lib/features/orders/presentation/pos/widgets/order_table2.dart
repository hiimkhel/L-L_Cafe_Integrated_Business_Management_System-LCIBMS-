// order_table2.dart

import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/services/pos/order_service.dart';
import 'order_row2.dart';

class OrderTable2 extends StatefulWidget {
  const OrderTable2({super.key});

  @override
  State<OrderTable2> createState() => _OrderTable2State();
}

class _OrderTable2State extends State<OrderTable2> {
  final OrderService _orderService = OrderService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    setState(() => _isLoading = true);

    final result = await _orderService.fetchOrderHistory(
      dateFilter: 'all',
      page: 1,
      limit: 50,
    );

    setState(() {
      _orders = List<Map<String, dynamic>>.from(result['orders']);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        children: [
          _header(),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? const Center(
                        child: Text(
                          'No order history found.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrderHistory,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];

                            return OrderRow2(
                              orderId: order['order_id'] ?? '',
                              customerName:
                                  order['customer_name'] ?? 'Walk-in Customer',
                              itemCount: order['item_count'] ?? 0,
                              paymentType:
                                  order['payment_type'] ?? 'N/A',
                              total:
                                  (order['total'] as num?)?.toDouble() ?? 0.0,
                              time: order['time'] ?? '',
                              fullOrderData:
                                  order['full_order_data'] ?? {},
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text("TIME")),
          Expanded(flex: 3, child: Text("CUSTOMER")),
          Expanded(flex: 3, child: Text("ORDER ID")),
          Expanded(flex: 2, child: Text("ITEMS")),
          Expanded(flex: 2, child: Text("PAYMENT")),
          Expanded(flex: 2, child: Text("TOTAL")),
          Expanded(flex: 2, child: Text("ACTION")),
        ],
      ),
    );
  }
}