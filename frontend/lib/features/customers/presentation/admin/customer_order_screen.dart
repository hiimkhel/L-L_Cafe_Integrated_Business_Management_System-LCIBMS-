import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/constants/cart_provider.dart';

const double _kMobile = 768;
const double _kDesktopMaxWidth = 1280;
const Color _primary = Color(0xFF758C6D);
const Color _secondary = Color(0xFFA98258);
const Color _bgBeige = Color(0xFFEFE2C9);
const Color _bgDark = Color(0xFF2D2A26);

// ─────────────────────────── Bamboo Background ──────────────────────────────

class _BambooBackground extends StatefulWidget {
  const _BambooBackground();
  @override
  State<_BambooBackground> createState() => _BambooBackgroundState();
}

class _BambooBackgroundState extends State<_BambooBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < _kMobile;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        painter: _BambooPainter(
            animationValue: _controller.value, isMobile: isMobile),
        size: Size.infinite,
      ),
    );
  }
}

class _BambooPainter extends CustomPainter {
  final double animationValue;
  final bool isMobile;
  _BambooPainter({required this.animationValue, required this.isMobile});

  static const _bamboos = [
    [0.040, 13.0, 0.12, 1.53], [0.095, 7.0, 0.10, -1.84],
    [0.133, 14.0, 0.13, 1.45], [0.190, 9.0, 0.10, -0.72],
    [0.236, 9.5, 0.10, -0.71], [0.283, 13.0, 0.12, -1.53],
    [0.321, 13.0, 0.11, 1.24], [0.374, 1.9, 0.08, 0.29],
    [0.423, 2.2, 0.08, 0.35],  [0.469, 2.6, 0.08, -0.34],
    [0.503, 20.0, 0.13, 2.00], [0.560, 4.1, 0.09, 1.06],
    [0.598, 17.6, 0.12, 1.82], [0.656, 8.9, 0.10, -0.98],
    [0.693, 15.5, 0.11, 1.72], [0.739, 17.9, 0.12, 1.99],
    [0.783, 18.8, 0.12, 1.81], [0.839, 8.9, 0.10, 0.66],
    [0.890, 5.2, 0.08, -1.98], [0.936, 16.6, 0.11, -1.89],
  ];

  void _drawLeaf(Canvas c, Offset o, double a, double l, double w, Paint p) {
    c.save(); c.translate(o.dx, o.dy); c.rotate(a);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(l * 0.4, -w, l, 0)
      ..quadraticBezierTo(l * 0.6, w, 0, 0)
      ..close();
    c.drawPath(path, p);
    c.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _primary;
    int index = 0;
    for (final b in _bamboos) {
      index++;
      if (isMobile && index % 3 != 0) continue;
      final baseX = size.width * (b[0] as double);
      final w = b[1] as double;
      final deg = b[3] as double;
      final h = size.height;
      final double baseOp = b[2] as double;
      final op = isMobile ? baseOp * 0.4 : baseOp;
      final x = (baseX + animationValue * size.width * (op * 8)) % size.width;
      final sway = math.sin((animationValue * math.pi * 4) + (x * 0.01)) * 0.015;
      final rad = (deg * math.pi / 180) + sway;
      paint.color = _primary.withOpacity(op);
      canvas.save();
      canvas.translate(x + w / 2, h / 2);
      canvas.rotate(rad);
      canvas.drawRect(Rect.fromLTWH(-w / 2, -h / 2 - 20, w, h + 40), paint);
      int segments = (h / (w * 10 + 60)).ceil().clamp(3, 10);
      double segH = (h + 40) / segments;
      for (int i = 1; i < segments; i++) {
        double jY = (-h / 2 - 20) + (i * segH);
        canvas.drawRect(Rect.fromLTWH(-w / 2 - 1.5, jY - 1, w + 3, 2.5), paint);
        if ((index + i) % 4 != 0) {
          bool isLeft = (index + i) % 2 == 0;
          double ll = w * 2.5 + 20.0, lw = ll * 0.25;
          _drawLeaf(canvas, Offset(isLeft ? -w / 2 : w / 2, jY),
              isLeft ? math.pi * 0.8 : math.pi * 0.2, ll, lw, paint);
          if (i % 2 == 0)
            _drawLeaf(canvas, Offset(isLeft ? -w / 2 : w / 2, jY),
                isLeft ? math.pi * 1.1 : -math.pi * 0.1, ll * 0.8, lw * 0.8, paint);
        }
      }
      canvas.translate(0, h * 0.2);
      canvas.rotate(math.pi / 4);
      canvas.drawRect(Rect.fromLTWH(-w * 0.6, -w * 0.6, w * 1.2, w * 1.2), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BambooPainter old) =>
      old.animationValue != animationValue || old.isMobile != isMobile;
}

// ─────────────────────────── Status helpers ─────────────────────────────────

Color _statusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:    return const Color(0xFF9E7145);
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

// ─────────────────────────── Enums & Models ─────────────────────────────────

enum OrderStatus { pending, inProgress, archived }

class Order {
  final String id;
  final OrderStatus status;
  final String? subStatus;
  final double total;
  final String? timestamp;
  final String? method;
  final List<String> items;

  const Order({
    required this.id,
    required this.status,
    this.subStatus,
    required this.total,
    this.timestamp,
    this.method,
    this.items = const [],
  });
}

// ─────────────────────────── Demo data ──────────────────────────────────────

final List<Order> _demoOrders = [
  Order(
    id: 'LL-9482', status: OrderStatus.pending,
    total: 1105.00, timestamp: 'FEB 07, 2026 • 10:30 AM', method: 'DELIVERY',
    items: ['1X HARAMBE MANGO', '2X NUTELLA FRAPPE', '2X KITKAT WAFFLE',
            '1X OREO WAFFLE', '1X RED VELVET FRAPPE', '1X O MORE',
            '1X CRISPY CHICKEN BURGER'],
  ),
  Order(
    id: 'LL-1023', status: OrderStatus.pending,
    total: 180.00, timestamp: 'FEB 07, 2026 • 11:15 AM', method: 'DELIVERY',
    items: ['1X O MORE'],
  ),
  Order(
    id: 'LL-9482', status: OrderStatus.inProgress, subStatus: 'PREPARING',
    total: 1105.00, timestamp: 'FEB 07, 2026 • 10:30 AM', method: 'DELIVERY',
    items: ['1X HARAMBE MANGO', '2X NUTELLA FRAPPE', '2X KITKAT WAFFLE',
            '1X OREO WAFFLE', '1X RED VELVET FRAPPE', '1X O MORE',
            '1X CRISPY CHICKEN BURGER'],
  ),
  Order(
    id: 'LL-1023', status: OrderStatus.inProgress, subStatus: 'OUT FOR DELIVERY',
    total: 180.00, timestamp: 'FEB 07, 2026 • 11:15 AM', method: 'DELIVERY',
    items: ['1X ICED AMERICANO'],
  ),
  Order(
    id: 'LL-8271', status: OrderStatus.archived,
    total: 520.00, timestamp: 'FEB 05, 2026', method: 'PICKUP',
    items: ['2X CARAMEL MACCHIATO', '3X CHOCOLATE MUFFIN'],
  ),
  Order(
    id: 'LL-7162', status: OrderStatus.archived,
    total: 150.00, timestamp: 'FEB 01, 2026', method: 'PICKUP',
    items: ['1X BREWED COFFEE'],
  ),
];

// ─────────────────────────── Screen ─────────────────────────────────────────

class CustomerOrderScreen extends StatefulWidget {
  final List<Order> orders;
  const CustomerOrderScreen({super.key, this.orders = const []});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<Order> get _source => widget.orders.isEmpty ? _demoOrders : widget.orders;

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
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);
    final isMobile = MediaQuery.of(context).size.width < _kMobile;

    return Scaffold(
      backgroundColor: _bgBeige,
      body: Stack(
        children: [
          const Positioned.fill(child: _BambooBackground()),
          // ── Use LayoutBuilder so the content + footer fill the screen ──
          Column(
            children: [
              // Navbar at top
              CustomerNavbar(
                activeRoute: '/orders',
                cartCount: cart.totalCount,
                notifCount: 1,
                onCart: () => Navigator.pushNamed(context, '/cart'),
                onNotif: () {},
                onProfile: () => Navigator.pushNamed(context, '/profile'),
                onLogout: () =>
                    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
              ),

              // Body fills remaining space; footer always at bottom
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Main content ────────────────────────────────
                      isMobile
                          ? _MobileBody(
                              selectedIndex: _selectedIndex,
                              onTabChanged: _onTabChanged,
                              archiveCount: _archiveCount,
                              filtered: _filtered,
                              searchCtrl: _searchCtrl,
                              searchQuery: _searchQuery,
                              onSearchChanged: (v) =>
                                  setState(() => _searchQuery = v),
                            )
                          : _DesktopBody(
                              selectedIndex: _selectedIndex,
                              onTabChanged: _onTabChanged,
                              archiveCount: _archiveCount,
                              filtered: _filtered,
                              searchCtrl: _searchCtrl,
                              searchQuery: _searchQuery,
                              onSearchChanged: (v) =>
                                  setState(() => _searchQuery = v),
                            ),
                      // ── Footer always below content ──────────────────
                      const CustomerFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Desktop body ───────────────────────────────────

class _DesktopBody extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final int archiveCount;
  final List<Order> filtered;
  final TextEditingController searchCtrl;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _DesktopBody({
    required this.selectedIndex,
    required this.onTabChanged,
    required this.archiveCount,
    required this.filtered,
    required this.searchCtrl,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ───────────────────────────────────────────────────
          const SizedBox(height: 20),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              children: [
                TextSpan(
                    text: 'ORDER STATUS: ',
                    style: TextStyle(color: _bgDark)),
                TextSpan(
                    text: 'ORDERS',
                    style: TextStyle(color: _secondary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(thickness: 1.2, color: _primary.withOpacity(0.4)),
          const SizedBox(height: 12),

          // ── Tab row ───────────────────────────────────────────────────
          _TabRow(
            selectedIndex: selectedIndex,
            archiveCount: archiveCount,
            onTabChanged: onTabChanged,
            isMobile: false,
          ),
          const SizedBox(height: 16),

          // ── Archive search bar (no export button) ────────────────────
          if (selectedIndex == 2) ...[
            _SearchBar(controller: searchCtrl, onChanged: onSearchChanged),
            const SizedBox(height: 16),
          ],

          // ── Order cards ──────────────────────────────────────────────
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 56, color: _primary.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('No orders found.',
                        style: TextStyle(
                            fontSize: 16, color: _primary.withOpacity(0.5))),
                  ],
                ),
              ),
            )
          else
            ...filtered.map((o) => _DesktopOrderCard(order: o)),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────── Mobile body ────────────────────────────────────

class _MobileBody extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final int archiveCount;
  final List<Order> filtered;
  final TextEditingController searchCtrl;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _MobileBody({
    required this.selectedIndex,
    required this.onTabChanged,
    required this.archiveCount,
    required this.filtered,
    required this.searchCtrl,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text('ORDERS',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _bgDark,
                  letterSpacing: 1.5)),
          const SizedBox(height: 16),

          // ── Tab row ───────────────────────────────────────────────────
          _TabRow(
            selectedIndex: selectedIndex,
            archiveCount: archiveCount,
            onTabChanged: onTabChanged,
            isMobile: true,
          ),
          const SizedBox(height: 14),

          // ── Archive search bar ────────────────────────────────────────
          if (selectedIndex == 2) ...[
            _SearchBar(controller: searchCtrl, onChanged: onSearchChanged),
            const SizedBox(height: 14),
          ],

          // ── Order cards ──────────────────────────────────────────────
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 48, color: _primary.withOpacity(0.3)),
                    const SizedBox(height: 10),
                    Text('No orders yet.',
                        style: TextStyle(
                            fontSize: 15, color: _primary.withOpacity(0.5))),
                  ],
                ),
              ),
            )
          else
            ...filtered.map((o) => _MobileOrderCard(order: o)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────── Shared tab row ──────────────────────────────────

class _TabRow extends StatelessWidget {
  final int selectedIndex;
  final int archiveCount;
  final ValueChanged<int> onTabChanged;
  final bool isMobile;

  const _TabRow({
    required this.selectedIndex,
    required this.archiveCount,
    required this.onTabChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final labels = ['PENDING', 'IN PROGRESS', 'ARCHIVE ($archiveCount)'];

    Widget row = Row(
      mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
      children: List.generate(labels.length, (i) {
        final isActive = i == selectedIndex;
        return Padding(
          padding: EdgeInsets.only(right: i < labels.length - 1 ? 12 : 0),
          child: GestureDetector(
            onTap: () => onTabChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 40,
                vertical: isMobile ? 10 : 13,
              ),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF9E7145) : _bgBeige,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: isActive ? Colors.white : _primary.withOpacity(0.8),
                ),
              ),
            ),
          ),
        );
      }),
    );

    return isMobile
        ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: row)
        : row;
  }
}

// ─────────────────────────── Desktop order card ──────────────────────────────

class _DesktopOrderCard extends StatelessWidget {
  final Order order;
  const _DesktopOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final badgeLabel = order.subStatus ?? _statusLabel(order.status);
    final badgeColor = order.subStatus == 'OUT FOR DELIVERY'
        ? const Color(0xFF2196F3)
        : _statusColor(order.status);

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
              color: Colors.black.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1 — ref code | badge | total
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('REFERENCE CODE',
                        style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            color: _primary.withOpacity(0.65))),
                    const SizedBox(height: 4),
                    Text('#${order.id}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _bgDark,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(badgeLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
              ),
              const SizedBox(width: 24),
              Text('₱${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _secondary)),
            ],
          ),

          const SizedBox(height: 14),

          // Row 2 — timestamp | method
          Row(
            children: [
              if (order.timestamp != null) ...[
                Icon(Icons.access_time_rounded,
                    size: 16, color: _primary.withOpacity(0.55)),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TIMESTAMP',
                        style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1,
                            color: _primary.withOpacity(0.5))),
                    Text(order.timestamp!,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _bgDark)),
                  ],
                ),
                const SizedBox(width: 32),
              ],
              if (order.method != null) ...[
                Icon(Icons.location_on_outlined,
                    size: 16, color: _primary.withOpacity(0.55)),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('METHOD',
                        style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1,
                            color: _primary.withOpacity(0.5))),
                    Text(order.method!,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _bgDark)),
                  ],
                ),
              ],
            ],
          ),

          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('LAST ITEMS',
                style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1,
                    color: _primary.withOpacity(0.5))),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ...visible.map((item) => _ItemChip(label: item)),
                if (overflow > 0)
                  _ItemChip(label: '+$overflow MORE', faded: true),
              ],
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
    final visible = order.items.take(maxVisible).toList();
    final overflow = order.items.length - maxVisible;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ref code + badge
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('REFERENCE CODE',
                        style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1,
                            color: _primary.withOpacity(0.6))),
                    const SizedBox(height: 2),
                    Text('#${order.id}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _bgDark)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(16)),
                child: Text(badgeLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Timestamp
          if (order.timestamp != null)
            _InfoRow(
                icon: Icons.access_time_rounded,
                label: 'TIMESTAMP',
                value: order.timestamp!),

          // Method
          if (order.method != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'METHOD',
                value: order.method!),
          ],

          // Items
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('ITEMS',
                style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1,
                    color: _primary.withOpacity(0.5))),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...visible.map((item) => _ItemChip(label: item)),
                if (overflow > 0)
                  _ItemChip(label: '+$overflow MORE', faded: true),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Total — no VIEW button
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL',
                  style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1,
                      color: _primary.withOpacity(0.5))),
              Text('₱${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _secondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Shared small widgets ───────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _primary.withOpacity(0.6)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1,
                    color: _primary.withOpacity(0.5))),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _bgDark)),
          ],
        ),
      ],
    );
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
                onPressed: () {
                  controller.clear();
                  onChanged('');
                })
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide:
                BorderSide(color: _primary.withOpacity(0.2), width: 1)),
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
        color: faded
            ? _primary.withOpacity(0.07)
            : _primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: faded
                ? _primary.withOpacity(0.45)
                : _primary),
      ),
    );
  }
}