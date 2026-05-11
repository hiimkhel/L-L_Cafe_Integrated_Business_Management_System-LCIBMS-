import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/widgets/bamboo_breeze_background.dart';
import 'package:frontend/core/constants/cart_provider.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/services/customer/order_service.dart';
const double _kMobile = 768;
const Color _primary   = Color(0xFF758C6D);
const Color _secondary = Color(0xFFA98258);
const Color _bgBeige   = Color(0xFFEFE2C9);
const Color _bgDark    = Color(0xFF2D2A26);

// ─────────────────────────── Status helpers ──────────────────────────────────

Color _statusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:    return Colors.grey;
    case OrderStatus.inProgress: return const Color(0xFFE6A817);
    case OrderStatus.archived:   return const Color(0xFF4CAF50);
  }
}

String _statusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:    return 'PENDING';
    case OrderStatus.inProgress: return 'PREPARING';
    case OrderStatus.archived:   return 'COMPLETED';
  }
}

// ─────────────────────────── Enums & Models ──────────────────────────────────

enum OrderStatus { pending, inProgress, archived }

class Order {
  final String id;
  final OrderStatus status;
  final String? subStatus;
  final double total;
  final String? timestamp;
  final String? method;
  final List<String> items;

  Order({
    required this.id,
    required this.status,
    this.subStatus,
    required this.total,
    this.timestamp,
    this.method,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    OrderStatus mapStatus(String status) {
      switch (status) {
        case 'pending':
          return OrderStatus.pending;
        case 'confirmed':
        case 'preparing':
        case 'ready':
        case 'out_for_delivery':
          return OrderStatus.inProgress;
        default:
          return OrderStatus.archived;
      }
    }

    return Order(
      id: json['order_number']?.toString() ?? '',
      status: mapStatus(json['status'] ?? ''),
      subStatus: json['status']?.toString().toUpperCase(),
      total: json['total'] == null 
          ? 0.0 
          : double.parse(json['total'].toString()),
      timestamp: json['created_at'],
      method: json['order_type']?.toString().toUpperCase(),
      items: (json['items'] as List?)
              ?.map((e) => e['item_name'].toString())
              .toList() ??
          [],
    );
  }
}

// ─────────────────────────── Screen ──────────────────────────────────────────

class CustomerOrderScreen extends StatefulWidget {

  const CustomerOrderScreen({super.key});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {

  Future<void> _cancelOrder(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
          'Are you sure you want to cancel order #${order.id}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final token = await AuthService().getIdToken();

      if (token == null || token.isEmpty) {
        throw Exception('Missing auth token');
      }

      // Call your backend endpoint
      await _service.cancelOrder(token, order.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #${order.id} cancelled successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload orders
      await _loadOrders();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final OrderService _service = OrderService();

  List<Order> _orders = [];
  bool _loading = true;
  String? _error;
  int _selectedIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // Handle calling of services to call backend
  Future<void> _loadOrders() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final auth = AuthService();
      final uid = await auth.getUid();

      if (uid == null) {
        throw Exception("User not logged in");
      }

      print("🔥 Firebase UID: $uid");

     final token = await AuthService().getIdToken();

    if (token == null || token.isEmpty) {
      throw Exception("Missing auth token");
    }

    final data = await _service.getCustomerOrders(token);
    print("🔥 Firebase Token: $token");
      setState(() {
        _orders = data.map((e) => Order.fromJson(e)).toList();
      });

    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }


  List<Order> get _source => _orders;

  List<Order> get _filtered {
    final all = _source.where((o) {
      if (_selectedIndex == 0) return o.status == OrderStatus.pending;
      if (_selectedIndex == 1) return o.status == OrderStatus.inProgress;
      return o.status == OrderStatus.archived;
    }).toList();

    if (_searchQuery.isEmpty || _selectedIndex != 2) return all;
    final q = _searchQuery.toLowerCase();
    return all.where((o) =>
        o.id.toLowerCase().contains(q) ||
        (o.timestamp?.toLowerCase().contains(q) ?? false) ||
        o.items.any((i) => i.toLowerCase().contains(q))).toList();
  }

  int get _archiveCount =>
      _source.where((o) => o.status == OrderStatus.archived).length;

  void _onTabChanged(int i) => setState(() {
    _selectedIndex = i;
    _searchQuery = '';
    _searchCtrl.clear();
  });

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }
  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cart     = CartProvider.of(context);
    final isMobile = MediaQuery.of(context).size.width < _kMobile;

    return Scaffold(
      backgroundColor: _bgBeige,
      body: Stack(
        children: [
          // ✅ Gentle breeze bamboo — calm, slow, easy on the eyes
          const Positioned.fill(child: BreezeBambooBackground()),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomerNavbar(
                activeRoute: '/orders',
                cartCount: cart.totalCount,
                notifCount: 1,
                onCart:    () => Navigator.pushNamed(context, '/cart'),
                onNotif:   () {},
                onProfile: () => Navigator.pushNamed(context, '/profile'),
                onLogout:  () => Navigator.pushNamedAndRemoveUntil(
                    context, '/', (r) => false),
              ),

              Expanded(
                child: LayoutBuilder(
                  builder: (_, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          isMobile
                              ? _buildMobileContent()
                              : _buildDesktopContent(),
                          const CustomerFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────── Desktop ─────────────────────────────────────────────
  Widget _buildDesktopContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 24),
        _orderHeader(isMobile: false),
        const SizedBox(height: 12),
        Divider(thickness: 1.2, color: _primary.withOpacity(0.4)),
        const SizedBox(height: 12),
        _tabs(isMobile: false),
        const SizedBox(height: 16),
        if (_selectedIndex == 2) ...[
          _SearchBar(controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v)),
          const SizedBox(height: 16),
          _ExportHistoryBanner(),
          const SizedBox(height: 16),
        ],
        _buildOrderList(isMobile: false),
        const SizedBox(height: 32),
      ]),
    );
  }

  // ─────────────────── Mobile ──────────────────────────────────────────────
  Widget _buildMobileContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        _orderHeader(isMobile: true),
        const SizedBox(height: 10),
        Divider(thickness: 1.2, color: _primary.withOpacity(0.5)),
        const SizedBox(height: 10),
        _tabs(isMobile: true),
        const SizedBox(height: 14),
        if (_selectedIndex == 2) ...[
          _SearchBar(controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v)),
          const SizedBox(height: 12),
          _ExportHistoryBanner(),
          const SizedBox(height: 12),
        ],
        _buildOrderList(isMobile: true),
        const SizedBox(height: 24),
      ]),
    );
  }

  // ─────────────────── Header ───────────────────────────────────────────────
  Widget _orderHeader({required bool isMobile}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold, letterSpacing: 1.2, fontFamily: 'Urbanist'),
        children: const [
          TextSpan(text: 'MY ORDERS', style: TextStyle(color: _secondary)),
        ],
      ),
    );
  }

  // ─────────────────── Tabs ─────────────────────────────────────────────────
  Widget _tabs({required bool isMobile}) {
    final labels = ['PENDING', 'IN PROGRESS', 'ARCHIVE ($_archiveCount)'];

    final row = Row(
      mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
      children: List.generate(labels.length, (i) {
        final isActive = i == _selectedIndex;
        return Padding(
          padding: EdgeInsets.only(right: i < labels.length - 1 ? 12 : 0),
          child: GestureDetector(
            onTap: () => _onTabChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 40,
                  vertical: isMobile ? 10 : 13),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF9E7145) : _bgBeige,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Text(labels[i],
                  style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: isActive ? Colors.white : _primary.withOpacity(0.8))),
            ),
          ),
        );
      }),
    );

    return isMobile
        ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: row)
        : row;
  }

  // ─────────────────── Order list ───────────────────────────────────────────
 // Update _buildOrderList inside _CustomerOrderScreenState
  Widget _buildOrderList({required bool isMobile}) {
    final orders = _filtered;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (orders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No orders found.'),
        ),
      );
    }

    return Column(
      children: orders.map((o) {
        if (isMobile) {
          return _MobileOrderCard(
            order: o,
            // onCancel: () => _cancelOrder(o),
          );
        }

        return _DesktopOrderCard(
          order: o,
          onCancel: () => _cancelOrder(o),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────── Export history banner ───────────────────────────

class _ExportHistoryBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: _bgDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: _bgDark.withOpacity(0.25),
            blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: _primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.receipt_long_outlined,
              color: Colors.white70, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EXPORT HISTORY',
                style: TextStyle(color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            const SizedBox(height: 2),
            Text('Download a detailed record of all your past orders.',
                style: TextStyle(color: Colors.white.withOpacity(0.55),
                    fontSize: 11, height: 1.4)),
          ],
        )),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            // TODO: connect to export / PDF service
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(10)),
            child: const Text('EXPORT',
                style: TextStyle(color: Colors.white, fontSize: 11,
                    fontWeight: FontWeight.w800, letterSpacing: 1.2)),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────── Desktop order card ──────────────────────────────

class _DesktopOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onCancel;

  const _DesktopOrderCard({
    required this.order,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final badgeLabel = order.subStatus ?? _statusLabel(order.status);

    final badgeColor = order.subStatus == 'OUT FOR DELIVERY'
        ? const Color(0xFF2196F3)
        : _statusColor(order.status);

    final canCancel =
    order.status == OrderStatus.pending;

    const maxVisible = 5;
    final visible = order.items.take(maxVisible).toList();
    final overflow = order.items.length - maxVisible;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───────────────── Header ─────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REFERENCE CODE',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: _primary.withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${order.id}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _bgDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'INVESTMENT TOTAL',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1,
                      color: _primary.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    '₱${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ───────────────── Metadata ─────────────────
          Row(
            children: [
              if (order.timestamp != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: _secondary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TIMESTAMP',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1,
                        color: _primary.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      order.timestamp!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _bgDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
              ],

              if (order.method != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: _secondary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SITE PROTOCOL',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1,
                        color: _primary.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      order.method!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _bgDark,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          // ───────────────── Items ─────────────────
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'CART ITEMS',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1,
                color: _primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ...visible.map((item) => _ItemChip(label: item)),
                if (overflow > 0)
                  _ItemChip(
                    label: '+$overflow MORE',
                    faded: true,
                  ),
              ],
            ),
          ],

          // ───────────────── Cancel Button ─────────────────
        if (canCancel && onCancel != null) ...[
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Tooltip(
              message: 'Cancel this order',
              child: ElevatedButton.icon(
                onPressed: onCancel,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.white, // Explicit icon color
                ),
                label: const Text(
                  'CANCEL ORDER',
                  style: TextStyle(
                    color: Colors.white, // Explicit text color
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9534F),
                  foregroundColor: Colors.white, // Applies to icon and text by default
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ).copyWith(
                  overlayColor: WidgetStateProperty.all(
                    Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
            ),
          ),
        ],
        ],
      ),
    );
  }
}

// ─────────────────────────── Mobile order card ───────────────────────────────

class _MobileOrderCard extends StatelessWidget {
  final Order order;
  const _MobileOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final badgeLabel = order.subStatus ?? _statusLabel(order.status);
    final badgeColor = order.subStatus == 'OUT FOR DELIVERY'
        ? const Color(0xFF2196F3)
        : _statusColor(order.status);

    const maxVisible = 3;
    final visible  = order.items.take(maxVisible).toList();
    final overflow = order.items.length - maxVisible;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Reference + badge
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('REFERENCE CODE', style: TextStyle(fontSize: 9, letterSpacing: 1,
                color: _primary.withOpacity(0.6))),
            const SizedBox(height: 2),
            Text('#${order.id}', style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: _bgDark)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: badgeColor,
                borderRadius: BorderRadius.circular(16)),
            child: Text(badgeLabel, style: const TextStyle(
                color: Colors.white, fontSize: 10,
                fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ]),
        const SizedBox(height: 12),

        // Timestamp
        if (order.timestamp != null)
          _InfoRow(icon: Icons.access_time_rounded,
              label: 'TIMESTAMP', value: order.timestamp!),

        // Method
        if (order.method != null) ...[
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.location_on_outlined,
              label: 'METHOD', value: order.method!),
        ],

        // Items
        if (order.items.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('ITEMS', style: TextStyle(fontSize: 9, letterSpacing: 1,
              color: _primary.withOpacity(0.5))),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: [
            ...visible.map((item) => _ItemChip(label: item)),
            if (overflow > 0) _ItemChip(label: '+$overflow MORE', faded: true),
          ]),
        ],

        const SizedBox(height: 12),

        // Total + VIEW button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TOTAL', style: TextStyle(fontSize: 9, letterSpacing: 1,
                  color: _primary.withOpacity(0.5))),
              Text('₱${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 22,
                      fontWeight: FontWeight.bold, color: _secondary)),
            ]),
            // VIEW button
            GestureDetector(
              onTap: () {
                // TODO: navigate to order detail screen
              },
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.remove_red_eye_outlined,
                    size: 14, color: _primary.withOpacity(0.6)),
                const SizedBox(width: 5),
                Text('VIEW',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        letterSpacing: 1.2, color: _primary.withOpacity(0.7))),
                Icon(Icons.chevron_right, size: 16,
                    color: _primary.withOpacity(0.5)),
              ]),
            ),
          ],
        ),
      ]),
    );
  }
}

// ─────────────────────────── Shared small widgets ────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: _secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 14, color: _secondary.withOpacity(0.8)),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 9, letterSpacing: 1,
            color: _primary.withOpacity(0.5))),
        Text(value, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600, color: _bgDark)),
      ]),
    ]);
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13, color: _bgDark),
      decoration: InputDecoration(
        hintText: 'Search by order ID, date or item…',
        hintStyle: TextStyle(color: _primary.withOpacity(0.45), fontSize: 13),
        prefixIcon: Icon(Icons.search_rounded,
            color: _primary.withOpacity(0.55), size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close_rounded,
                    size: 18, color: _primary.withOpacity(0.5)),
                onPressed: () { controller.clear(); onChanged(''); })
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: _primary.withOpacity(0.2), width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: _primary, width: 1.5)),
      ),
    );
  }
}

class _ItemChip extends StatelessWidget {
  final String label;
  final bool faded;
  const _ItemChip({required this.label, this.faded = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: faded ? _primary.withOpacity(0.07) : _primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: faded ? _primary.withOpacity(0.45) : _primary)),
    );
  }
}