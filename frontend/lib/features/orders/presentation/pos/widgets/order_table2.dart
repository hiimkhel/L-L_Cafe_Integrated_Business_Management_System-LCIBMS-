import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/services/pos/order_service.dart';
import 'order_row2.dart';
import 'package:intl/intl.dart';

class OrderTable2 extends StatefulWidget {
  const OrderTable2({super.key});

  @override
  State<OrderTable2> createState() => OrderTable2State();
}

class OrderTable2State extends State<OrderTable2> {
  final OrderService _orderService = OrderService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];
  String currentSearch = '';

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  void handleSearch(String query) {
    _loadOrderHistory(search: query);
  }

  void applyFilters(String query, String dateFilter, {DateTimeRange? customRange}) {
    _loadOrderHistory(
      search: query,
      dateFilter: dateFilter,
      start: customRange?.start,
      end: customRange?.end,
    );
  }

 Future<void> _loadOrderHistory({
  String search = '', 
  String dateFilter = 'all',
  DateTime? start,
  DateTime? end,
}) async {
  setState(() {
    _isLoading = true;
    currentSearch = search;
  });

  String startDateStr = start != null ? DateFormat('yyyy-MM-dd').format(start) : '';
  String endDateStr = end != null ? DateFormat('yyyy-MM-dd').format(end) : '';

  final result = await _orderService.fetchOrderHistory(
    search: search,
    dateFilter: dateFilter, 
    startDate: startDateStr, 
    endDate: endDateStr,
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
      clipBehavior: Clip.antiAlias, // Ensures children don't bleed past radius
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.03),
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
                    ? const Center(child: Text('No order history found.'))
                    : RefreshIndicator(
                        onRefresh: _loadOrderHistory,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: _orders.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey.withOpacity(0.05),
                          ),
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            return OrderRow2(
                              orderId: order['order_id'] ?? '',
                              customerName: order['customer_name'] ?? 'Walk-in',
                              itemCount: order['item_count'] ?? 0,
                              paymentType: order['payment_type'] ?? 'N/A',
                              total: (order['total'] as num?)?.toDouble() ?? 0.0,
                              time: order['time'] ?? '',
                              fullOrderData: order['full_order_data'] ?? {},
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
    return Container(
      // Making header darker than white as requested
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Slight grayish/blue tint for separation
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          _headerItem("TIME", 2),
          _headerItem("CUSTOMER", 3),
          _headerItem("ORDER ID", 3),
          _headerItem("ITEMS", 2),
          _headerItem("PAYMENT", 2),
          _headerItem("TOTAL", 2),
          _headerItem("ACTION", 2),
        ],
      ),
    );
  }

  Widget _headerItem(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.secondary, // Secondary color for headers
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}