import 'package:flutter/material.dart';
import 'package:frontend/core/services/pos/order_service.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:dotted_border/dotted_border.dart';

class OnlineOrdersScreen extends StatefulWidget {
  const OnlineOrdersScreen({super.key});

  @override
  State<OnlineOrdersScreen> createState() => _OnlineOrdersScreenState();
}

class _OnlineOrdersScreenState extends State<OnlineOrdersScreen> {
  // Theme Colors
  static const _bg = Color(0xFFEFE2C9);
  static const _brown = Color(0xFFa98258);
  static const _darkBrown = Color(0xFF4a3520);
  static const _green = Color(0xFF4a6741);
  static const _red = Color(0xFFc0392b);

  String _selectedFilter = 'PENDING';
  String? _selectedOrderId;
  final TextEditingController _searchController = TextEditingController();
  final OrderService _orderService = OrderService();

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  // Logic Helpers
  List<Map<String, dynamic>> get _filteredOrders {
    // Filter by status
    List<Map<String, dynamic>> result =
        _selectedFilter == 'ALL'
            ? _orders
            : _orders.where((o) => o['status'] == _selectedFilter).toList();

    // Apply Search
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result =
          result
              .where(
                (o) =>
                    o['id'].toString().toLowerCase().contains(query) ||
                    o['customer'].toString().toLowerCase().contains(query),
              )
              .toList();
    }

    // FIFO SORTING: Oldest orders first (Assumes your data has a 'timestamp' or 'created_at' field)
    // If your API provides 'db_id' as an auto-incrementing integer, you can use that too.
    result.sort(
      (a, b) => (a['created_at'] ?? 0).compareTo(b['created_at'] ?? 0),
    );

    return result;
  }

  Map<String, dynamic>? get _selectedOrder =>
      _selectedOrderId == null
          ? null
          : _orders.firstWhere(
            (o) => o['id'] == _selectedOrderId,
            orElse: () => {},
          );

  // API Methods
  Future<void> fetchOnlineOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderService.fetchOnlineOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ----------------------------------------------------------------confirm accept/reject order decision
  Future<void> _processOrder(String id, bool accept) async {
    final confirmed = await _showConfirmationDialog(id, accept);
    if (confirmed != true) return;

    final order = _orders.firstWhere((o) => o['id'] == id);
    final success =
        accept
            ? await _orderService.acceptOrder(order['db_id'])
            : await _orderService.rejectOrder(order['db_id']);

    if (success) {
      await fetchOnlineOrders();
      if (_selectedOrderId == id) setState(() => _selectedOrderId = null);
    }
  }

  Future<bool?> _showConfirmationDialog(String orderId, bool accept) {
    final order = _orders.firstWhere((o) => o['id'] == orderId);
    final isAccept = accept;

    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: (isAccept ? _green : _red).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isAccept
                          ? Icons.check_circle_outline
                          : Icons.highlight_off_rounded,
                      color: isAccept ? _green : _red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    isAccept ? 'APPROVE ORDER?' : 'REJECT ORDER?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _darkBrown,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    isAccept
                        ? 'This will confirm and queue the order for preparation.'
                        : 'This will cancel the order. The customer will be notified.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Order Summary Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _bg.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _brown.withOpacity(0.15)),
                    ),
                    child: Column(
                      children: [
                        _confirmRow(Icons.tag, 'Order', order['id']),
                        const SizedBox(height: 6),
                        _confirmRow(
                          Icons.person_outline,
                          'Customer',
                          order['customer'],
                        ),
                        const SizedBox(height: 6),
                        _confirmRow(
                          Icons.payments_outlined,
                          'Total',
                          '₱${order['total']?.toStringAsFixed(2) ?? '0.00'}',
                        ),
                        const SizedBox(height: 6),
                        _confirmRow(
                          Icons.credit_card,
                          'Payment',
                          order['payment'] ?? 'CASH',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _darkBrown,
                            side: BorderSide(color: _brown.withOpacity(0.4)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAccept ? _green : _red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            isAccept ? 'APPROVE' : 'REJECT',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _confirmRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _brown),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 12,
            color: _brown,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _darkBrown,
          ),
        ),
      ],
    );
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
        width: 1400,
        height: 850,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 5),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 3, child: _buildDecisionLayer()),
                  _buildVerificationLayer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER SECTION ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: _brown.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          const Icon(Icons.fact_check_rounded, color: _green, size: 28),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'POS ONLINE ORDER DASHBOARD',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _darkBrown,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'MANUAL PAYMENT VERIFICATION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _brown,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: fetchOnlineOrders,
            icon: const Icon(Icons.refresh, color: _brown),
            tooltip: 'Refresh Queue',
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: _bg,
              child: Icon(Icons.close, size: 18, color: _darkBrown),
            ),
          ),
        ],
      ),
    );
  }

  // --- LEFT SIDE: DECISION LAYER (The Queue) ---
  Widget _buildDecisionLayer() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFilterRow(),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _brown.withOpacity(0.15)),
              ),
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: _brown),
                      )
                      : _buildOrderTable(),
            ),
          ),
        ],
      ),
    );
  }

  // Update the Filter Row to include count badges
  Widget _buildFilterRow() {
    final filters = ['ALL', 'PENDING', 'ACCEPTED', 'REJECTED'];

    // Get counts for each status
    final Map<String, int> counts = {
      'PENDING': _orders.where((o) => o['status'] == 'PENDING').length,
      'ACCEPTED': _orders.where((o) => o['status'] == 'ACCEPTED').length,
      'REJECTED': _orders.where((o) => o['status'] == 'REJECTED').length,
    };

    return Row(
      children: [
        // Search Bar
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search order or customer...',
              prefixIcon: const Icon(Icons.search, size: 18, color: _brown),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _brown.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _brown, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Chips with Badge Overlays
        Row(
          children:
              filters.map((f) {
                final isSelected = _selectedFilter == f;
                final count = counts[f] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Stack(
                    clipBehavior: Clip.none, // Allows badge to sit above
                    children: [
                      ChoiceChip(
                        label: Text(f, style: const TextStyle(fontSize: 11)),
                        selected: isSelected,
                        onSelected:
                            (val) => setState(() => _selectedFilter = f),
                        selectedColor: _darkBrown,
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : _darkBrown,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? _darkBrown
                                    : _brown.withValues(alpha: 0.3),
                          ),
                        ),
                      ),

                      // The Badge (only show if count > 0)
                      if (count > 0)
                        Positioned(
                          top: -5,
                          right: -5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  f == 'REJECTED'
                                      ? _red
                                      : (f == 'PENDING' ? _brown : _green),
                              shape: BoxShape.circle,
                              border: Border.all(color: _bg, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrderTable() {
    final orders = _filteredOrders;
    if (orders.isEmpty) return const Center(child: Text("No orders found."));

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SingleChildScrollView(
        child: DataTable(
          showCheckboxColumn: false,
          headingRowHeight: 50,
          dataRowMaxHeight: 60,
          headingRowColor: WidgetStateProperty.all(_bg.withOpacity(0.3)),
          columns: const [
            DataColumn(label: Text('ORDER ID')),
            DataColumn(label: Text('CUSTOMER')),
            DataColumn(label: Text('TOTAL')),
            DataColumn(label: Text('PAYMENT')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('QUICK ACTION')),
          ],
          rows:
              orders.map((order) {
                final isSelected = _selectedOrderId == order['id'];
                final isPending = order['status'] == 'PENDING';
                return DataRow(
                  selected: isSelected,
                  onSelectChanged:
                      (_) => setState(() => _selectedOrderId = order['id']),
                  cells: [
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _darkBrown.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _darkBrown.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 14,
                              color: _darkBrown,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              order['id'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: _darkBrown,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(Text(order['customer'])),
                    DataCell(
                      Text('₱${order['total']?.toStringAsFixed(2) ?? '0.00'}'),
                    ),
                    DataCell(_paymentBadge(order['payment'] ?? 'CASH')),
                    DataCell(_statusChip(order['status'])),
                    DataCell(
                      isPending
                          ? Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  color: _green,
                                  size: 22,
                                ),
                                onPressed:
                                    () => _processOrder(order['id'], true),
                                tooltip: 'Quick Approve',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.highlight_off_rounded,
                                  color: _red,
                                  size: 22,
                                ),
                                onPressed:
                                    () => _processOrder(order['id'], false),
                                tooltip: 'Quick Reject',
                              ),
                            ],
                          )
                          : const Icon(
                            Icons.visibility_outlined,
                            color: Colors.grey,
                            size: 18,
                          ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  // --- RIGHT SIDE: VERIFICATION LAYER ---
  Widget _buildVerificationLayer() {
    final order = _selectedOrder;
    return Container(
      width: 420,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: _brown.withOpacity(0.15))),
      ),
      child:
          order == null || order.isEmpty
              ? _buildEmptyState()
              : _buildVerificationDetail(order),
    );
  }

  Widget _buildVerificationDetail(Map<String, dynamic> order) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _workspaceHeader(order),
                const SizedBox(height: 24),

                // CRITICAL: PAYMENT SECTION
                _sectionLabel("PAYMENT VERIFICATION"),
                const SizedBox(height: 12),
                _buildReceiptWorkspace(order),

                const SizedBox(height: 24),
                _sectionLabel("ORDER ITEMS"),
                const SizedBox(height: 10),
                ...(order['items'] as List).map((item) => _itemRow(item)),

                const Divider(height: 40),
                _summaryRow(
                  "Subtotal",
                  "₱${(order['total'] - 45).toStringAsFixed(2)}",
                ),
                _summaryRow("Delivery Fee", "₱45.00"),
                const SizedBox(height: 8),
                _summaryRow(
                  "GRAND TOTAL",
                  "₱${order['total']?.toStringAsFixed(2)}",
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
        if (order['status'] == 'PENDING') _buildActionFooter(order['id']),
      ],
    );
  }

  Widget _buildReceiptWorkspace(Map<String, dynamic> order) {
    final isElectronic = order['payment'].toString().toUpperCase() != 'CASH';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bg.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _brown.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isElectronic ? Icons.qr_code_scanner : Icons.money,
                color: _brown,
              ),
              const SizedBox(width: 8),
              Text(
                order['payment'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _darkBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isElectronic) ...[
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _brown.withOpacity(0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    order['payment_proof_url'] != null &&
                            order['payment_proof_url'].toString().isNotEmpty
                        ? Image.network(
                          'http://localhost:3006/uploads/${order['payment_proof_url']}',
                          fit: BoxFit.cover,
                          loadingBuilder:
                              (_, child, progress) =>
                                  progress == null
                                      ? child
                                      : const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                          errorBuilder:
                              (_, __, ___) => const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Failed to load receipt',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        )
                        : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_search,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No receipt uploaded',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  final proofUrl = order['payment_proof_url'];
                  if (proofUrl == null || proofUrl.toString().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No receipt uploaded for this order.'),
                      ),
                    );
                    return;
                  }
                  final fullUrl = 'http://localhost:3006/uploads/$proofUrl';
                  showDialog(
                    context: context,
                    builder:
                        (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'PAYMENT RECEIPT',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: const Icon(Icons.close, size: 18),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.6,
                                    child: Image.network(
                                      fullUrl,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (_, child, progress) =>
                                              progress == null
                                                  ? child
                                                  : const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                      errorBuilder:
                                          (_, __, ___) => const Center(
                                            child: Text(
                                              'Failed to load image.',
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  );
                },
                icon: const Icon(Icons.zoom_in),
                label: const Text("View Full-Screen Receipt"),
              ),
            ),
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "CASH PAYMENT\nVerify amount on arrival",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _brown, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- UI ATOMS ---

  Widget _workspaceHeader(Map<String, dynamic> order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order['id'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: _darkBrown,
              ),
            ),
            Text(
              order['customer'],
              style: const TextStyle(
                color: _brown,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        _statusChip(order['status']),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: _brown,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _itemRow(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "${item['qty']}x",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item['name'], style: const TextStyle(fontSize: 13)),
          ),
          Text(
            "₱${(item['price'] * item['qty']).toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.normal,
            fontSize: isTotal ? 16 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? _green : _darkBrown,
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    Color color =
        status == 'PENDING' ? _brown : (status == 'ACCEPTED' ? _green : _red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _paymentBadge(String type) {
    bool isGcash = type.toUpperCase().contains('GCASH');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:
            isGcash
                ? Colors.blue.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isGcash ? Colors.blue : Colors.orange[800],
        ),
      ),
    );
  }

  Widget _buildActionFooter(String id) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _processOrder(id, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: _red,
                side: const BorderSide(color: _red),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: const Text(
                "REJECT ORDER",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _processOrder(id, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
              ),
              child: const Text(
                "APPROVE ORDER",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mouse_outlined, size: 60, color: _bg),
          SizedBox(height: 16),
          Text(
            "SELECT AN ORDER\nTO START VERIFICATION",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _brown,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
