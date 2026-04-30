import 'package:flutter/material.dart';
import 'package:frontend/core/services/pos/order_service.dart';

class OnlineOrdersScreen extends StatefulWidget {
  const OnlineOrdersScreen({super.key});

  @override
  State<OnlineOrdersScreen> createState() => _OnlineOrdersScreenState();
}

class _OnlineOrdersScreenState extends State<OnlineOrdersScreen> {
  static const _bg = Color(0xFFEFE2C9);
  static const _brown = Color(0xFFa98258);
  static const _darkBrown = Color(0xFF4a3520);
  static const _green = Color(0xFF4a6741);
  static const _red = Color(0xFFc0392b);

  String _selectedFilter = 'ALL';
  String? _selectedOrderId;
  final TextEditingController _searchController = TextEditingController();
  final OrderService _orderService = OrderService();

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get _filteredOrders {
    List<Map<String, dynamic>> result = _selectedFilter == 'ALL'
        ? _orders
        : _orders.where((o) => o['status'] == _selectedFilter).toList();

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((o) =>
              o['id'].toString().toLowerCase().contains(query) ||
              o['customer'].toString().toLowerCase().contains(query) ||
              o['phone'].toString().toLowerCase().contains(query))
          .toList();
    }
    return result;
  }

  Map<String, dynamic>? get _selectedOrder => _selectedOrderId == null
      ? null
      : _orders.firstWhere(
          (o) => o['id'] == _selectedOrderId,
          orElse: () => {},
        );

  int _countByStatus(String status) =>
      _orders.where((o) => o['status'] == status).length;

  double _subtotal(Map<String, dynamic> order) {
    return (order['items'] as List)
        .fold(0.0, (sum, item) => sum + (item['qty'] * item['price']));
  }

  double _total(Map<String, dynamic> order) {
    final sub = _subtotal(order);
    return sub + (sub * order['tax']);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return _brown;
      case 'ACCEPTED':
        return _green;
      case 'REJECTED':
        return _red;
      default:
        return _brown;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.access_time_rounded;
      case 'ACCEPTED':
        return Icons.check_circle_outline_rounded;
      case 'REJECTED':
        return Icons.cancel_outlined;
      default:
        return Icons.access_time_rounded;
    }
  }

  Future<void> _acceptOrder(String id) async {
    final order = _orders.firstWhere((o) => o['id'] == id);

    final success = await _orderService.acceptOrder(order['db_id']);

    if (success) {
      await fetchOnlineOrders(); 
    } else {
      debugPrint("Failed to accept order");
    }
  }

 Future<void> _rejectOrder(String id) async {
    final order = _orders.firstWhere((o) => o['id'] == id);

    final success = await _orderService.rejectOrder(order['db_id']);

    if (success) {
      await fetchOnlineOrders(); // refresh from backend
    } else {
      debugPrint("Failed to reject order");
    }
  }

  // Call services for data
  Future<void> fetchOnlineOrders() async {
    try {
      final orders = await _orderService.fetchOnlineOrders();

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOnlineOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 1100,
        height: 780,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildLeftPanel()),
                  _buildRightPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: _brown.withValues(alpha: .2))),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _brown.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.shopping_bag_outlined, color: _green, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ONLINE ORDERS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _green,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'DIGITAL ORDER MANAGEMENT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _brown.withValues(alpha: .7),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _brown.withValues(alpha: .2)),
              ),
              child: Icon(Icons.close, size: 18, color: _darkBrown),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFilterBar(),
          const SizedBox(height: 16),
          _buildSummaryCards(),
          const SizedBox(height: 16),
          Expanded(child: _buildOrderGrid()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['ALL', 'PENDING', 'ACCEPTED', 'REJECTED'];
    final counts = {
      'ALL': _orders.length,
      'PENDING': _countByStatus('PENDING'),
      'ACCEPTED': _countByStatus('ACCEPTED'),
      'REJECTED': _countByStatus('REJECTED'),
    };

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _brown.withValues(alpha: .2)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(fontSize: 12, color: _darkBrown),
              decoration: InputDecoration(
                hintText: 'Search by order #, name, or phone...',
                hintStyle: TextStyle(
                  fontSize: 11,
                  color: _brown.withValues(alpha: .5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 16,
                  color: _brown.withValues(alpha: .5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _brown.withValues(alpha: .2)),
          ),
          child: Icon(Icons.tune_rounded, size: 16, color: _brown),
        ),
        const SizedBox(width: 10),
        ...filters.map((f) {
          final isActive = _selectedFilter == f;
          final color = f == 'ALL'
              ? _darkBrown
              : f == 'PENDING'
                  ? _brown
                  : f == 'ACCEPTED'
                      ? _green
                      : _red;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? color : color.withValues(alpha: .4),
                ),
              ),
              child: Row(
                children: [
                  if (f != 'ALL')
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        _statusIcon(f),
                        size: 12,
                        color: isActive ? Colors.white : color,
                      ),
                    ),
                  Text(
                    '$f (${counts[f]})',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : color,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final cards = [
      {
        'label': 'Pending',
        'count': _countByStatus('PENDING'),
        'color': _brown,
        'icon': Icons.access_time_rounded
      },
      {
        'label': 'Accepted',
        'count': _countByStatus('ACCEPTED'),
        'color': _green,
        'icon': Icons.check_circle_outline_rounded
      },
      {
        'label': 'Rejected',
        'count': _countByStatus('REJECTED'),
        'color': _red,
        'icon': Icons.cancel_outlined
      },
    ];

    return Row(
      children: cards.asMap().entries.map((entry) {
        final i = entry.key;
        final c = entry.value;
        final color = c['color'] as Color;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < cards.length - 1 ? 12 : 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _brown.withValues(alpha: .1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(c['icon'] as IconData, color: color, size: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  '${c['count']}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _darkBrown,
                  ),
                ),
                Text(
                  (c['label'] as String).toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _brown.withValues(alpha: .7),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderGrid() {
    final orders = _filteredOrders;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return Center(
        child: Text(
          'No orders found.',
          style: TextStyle(
              color: _brown.withValues(alpha: .5), fontSize: 13),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final color = _statusColor(status);
    final isSelected = _selectedOrderId == order['id'];
    final items = order['items'] as List;
    final displayItems = items.take(2).toList();
    final extra = items.length - 2;

    return GestureDetector(
      onTap: () => setState(() => _selectedOrderId = order['id']),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : _brown.withValues(alpha: .15),
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  order['id'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _darkBrown,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(_statusIcon(status), size: 11, color: color),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              order['time'],
              style: TextStyle(
                  fontSize: 11, color: _brown.withValues(alpha: .6)),
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.person_outline, order['customer'], bold: true),
            const SizedBox(height: 3),
            _infoRow(Icons.phone_outlined, order['phone']),
            const SizedBox(height: 3),
            _infoRow(Icons.delivery_dining_outlined, order['address']),
            const SizedBox(height: 10),
            ...displayItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item['qty']}x ${item['name']}',
                          style:
                              TextStyle(fontSize: 11, color: _darkBrown),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₱${(item['qty'] * item['price'] as double).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 11, color: _brown),
                      ),
                    ],
                  ),
                )),
            if (extra > 0)
              Text(
                '+$extra more items',
                style: TextStyle(
                    fontSize: 10, color: _brown.withValues(alpha: .6)),
              ),
            const Spacer(),
            Row(
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _brown.withValues(alpha: .6),
                  ),
                ),
                const Spacer(),
                Text(
                  '₱${_total(order).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _darkBrown,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {bool bold = false}) {
    return Row(
      children: [
        Icon(icon, size: 12, color: _brown.withValues(alpha: .6)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? _darkBrown : _brown.withValues(alpha: .7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    final order = _selectedOrder;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(16),
        ),
        border:
            Border(left: BorderSide(color: _brown.withValues(alpha: .15))),
      ),
      child: order == null || order.isEmpty
          ? _buildEmptyDetail()
          : _buildOrderDetail(order),
    );
  }

  Widget _buildEmptyDetail() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 56, color: _brown.withValues(alpha: .2)),
          const SizedBox(height: 12),
          Text(
            'SELECT AN ORDER TO VIEW DETAILS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _brown.withValues(alpha: .4),
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetail(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final color = _statusColor(status);
    final items = order['items'] as List;
    final sub = _subtotal(order);
    final tax = sub * order['tax'];
    final total = sub + tax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _brown.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.shopping_bag_outlined,
                    color: _green, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['id'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: _darkBrown,
                    ),
                  ),
                  Text(
                    'ORDER DETAILS',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: _brown.withValues(alpha: .5),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_statusIcon(status), size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('CUSTOMER INFORMATION'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _bg.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _detailRow(Icons.person_outline, order['customer'],
                          bold: true),
                      const SizedBox(height: 6),
                      _detailRow(Icons.phone_outlined, order['phone']),
                      const SizedBox(height: 6),
                      _detailRow(
                          Icons.delivery_dining_outlined, order['address']),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _sectionLabel('ORDER ITEMS'),
                const SizedBox(height: 8),
                ...items.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _bg.withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _darkBrown,
                                  ),
                                ),
                              ),
                              Text(
                                '₱${(item['qty'] * item['price'] as double).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _darkBrown,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Quantity: ${item['qty']}',
                            style: TextStyle(
                                fontSize: 10,
                                color: _brown.withValues(alpha: .6)),
                          ),
                          Text(
                            '₱${(item['price'] as double).toStringAsFixed(2)} each',
                            style: TextStyle(
                                fontSize: 10,
                                color: _brown.withValues(alpha: .6)),
                          ),
                        ],
                      ),
                    )),
                if (order['specialInstructions'] != null) ...[
                  const SizedBox(height: 6),
                  _sectionLabel('SPECIAL INSTRUCTIONS'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _bg.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      order['specialInstructions'],
                      style: TextStyle(fontSize: 12, color: _darkBrown),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _totalRow('SUBTOTAL', '₱${sub.toStringAsFixed(2)}'),
                const SizedBox(height: 4),
                _totalRow('TAX (12%)', '₱${tax.toStringAsFixed(2)}'),
                const Divider(height: 20),
                Row(
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: _darkBrown,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₱${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _darkBrown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _bg.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _brown.withValues(alpha: .15)),
                  ),
                  child: Text(
                    order['payment'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _brown.withValues(alpha: .7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: _brown.withValues(alpha: .15))),
          ),
          child: status == 'PENDING'
              ? Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _acceptOrder(order['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'ACCEPT ORDER',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _rejectOrder(order['id']),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _red,
                          side: BorderSide(color: _red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'REJECT ORDER',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_statusIcon(status), size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      'ORDER $status',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: _brown.withValues(alpha: .5),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _detailRow(IconData icon, String text, {bool bold = false}) {
    return Row(
      children: [
        Icon(icon, size: 13, color: _brown.withValues(alpha: .6)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? _darkBrown : _brown.withValues(alpha: .7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _totalRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 11, color: _brown.withValues(alpha: .6)),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
              fontSize: 11, color: _brown.withValues(alpha: .8)),
        ),
      ],
    );
  }
}