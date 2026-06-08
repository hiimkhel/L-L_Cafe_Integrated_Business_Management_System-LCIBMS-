import 'package:flutter/material.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../core/widgets/admin_header.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../features/dashboard/presentation/admin/order_screen.dart';
import "package:frontend/core/models/dashboard_models.dart";
import './widgets/summary_row.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE
// ─────────────────────────────────────────────────────────────────────────────

const Color _green1 = Color(0xFF3D5A45);
const Color _green2 = Color(0xFF758C6D);
const Color _gold   = Color(0xFFA98258);
const Color _beige  = Color(0xFFEFE2C9);
const Color _white  = Colors.white;
const Color _dark   = Color(0xFF2D2A26);

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// DATA  (replace with API calls)
// ─────────────────────────────────────────────────────────────────────────────

const _summaryCards = <SummaryCardData>[
  SummaryCardData(label: 'TOTAL CUSTOMERS', value: '389',      delta: '+1.2%', deltaPositive: true,  icon: Icons.people_outline_rounded,          accent: Color(0xFF4CAF50)),
  SummaryCardData(label: 'TOTAL SALES',     value: '43,112',   delta: '+1.2%', deltaPositive: true,  icon: Icons.show_chart_rounded,              accent: Color(0xFF2196F3)),
  SummaryCardData(label: 'TOTAL INCOME',    value: '₱244,219', delta: '+1.2%', deltaPositive: true,  icon: Icons.account_balance_wallet_outlined,  accent: Color(0xFFA98258)),
];

const _menuItems = <TopMenuItem>[
  TopMenuItem(rank: 1, name: 'Breaded Pork Red Pesto Pasta', price: '₱120', sold: 312),
  TopMenuItem(rank: 2, name: 'Truffle Pasta',                price: '₱100', sold: 287),
  TopMenuItem(rank: 3, name: 'Loaded Sausage Fries',         price: '₱100', sold: 256),
  TopMenuItem(rank: 4, name: 'Chicken Burger',               price: '₱95',  sold: 221),
  TopMenuItem(rank: 5, name: 'Biscoff (non-coffee)',         price: '₱200', sold: 194),
];

const _orders = <DashboardOrderRow>[
  DashboardOrderRow(orderId: '#LL-401', customerName: 'Maria Santos',  payment: 'Paid', status: 'Pending',   orderTime: '02-07-26  1:14 PM',  amount: '₱520'),
  DashboardOrderRow(orderId: '#LL-400', customerName: 'Jose Reyes',    payment: 'Paid', status: 'Preparing', orderTime: '02-07-26 12:45 PM',  amount: '₱345'),
  DashboardOrderRow(orderId: '#LL-399', customerName: 'Walk-In',       payment: 'Paid', status: 'Done',      orderTime: '02-07-26 11:58 AM',  amount: '₱980'),
  DashboardOrderRow(orderId: '#LL-398', customerName: 'Rico Bautista', payment: 'Paid', status: 'Done',      orderTime: '02-07-26 11:30 AM',  amount: '₱420'),
  DashboardOrderRow(orderId: '#LL-397', customerName: 'Liza Mercado',  payment: 'Paid', status: 'Delivery',  orderTime: '02-07-26 10:52 AM',  amount: '₱186'),
];

const _revenueBars = <RevenueBarData>[
  RevenueBarData(month: 'Jan', value: 0.88, rawLabel: '₱88k'),
  RevenueBarData(month: 'Feb', value: 0.80, rawLabel: '₱80k'),
  RevenueBarData(month: 'Mar', value: 0.41, rawLabel: '₱41k'),
  RevenueBarData(month: 'Apr', value: 0.58, rawLabel: '₱58k'),
  RevenueBarData(month: 'May', value: 0.83, rawLabel: '₱83k'),
  RevenueBarData(month: 'Jun', value: 0.88, rawLabel: '₱88k'),
  RevenueBarData(month: 'Jul', value: 0.75, rawLabel: '₱75k'),
  RevenueBarData(month: 'Aug', value: 0.83, rawLabel: '₱83k'),
  RevenueBarData(month: 'Sep', value: 0.89, rawLabel: '₱89k'),
  RevenueBarData(month: 'Oct', value: 0.95, rawLabel: '₱95k', isHighlighted: true),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  final int activeIndex;
  final VoidCallback onLogout;
  const AdminDashboardScreen({
    super.key,
    this.activeIndex = 0,
    required this.onLogout,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  double _targetProgress = 0.75;
  String _targetAmount   = '₱ 7,000.56';
  String _targetMax      = '₱10,100';
  double _targetRawMax   = 10100;
  double _targetRawCur   = 7000.56;

  // ── Set Target dialog ─────────────────────────────────────────────────────
  void _showSetTargetDialog() {
    final ctrl = TextEditingController(text: _targetRawMax.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _beige,
        title: Row(children: [
          Container(
            width: 4, height: 20,
            decoration: BoxDecoration(
                color: _green2, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          const Text('SET DAILY TARGET',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                  fontSize: 16, color: _green1)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Enter your daily revenue target (₱):',
              style: TextStyle(fontFamily: 'Urbanist', fontSize: 12,
                  color: _green1.withOpacity(0.65))),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontFamily: 'Urbanist', fontSize: 15,
                fontWeight: FontWeight.w700, color: _green1),
            decoration: InputDecoration(
              prefixText: '₱ ',
              prefixStyle: const TextStyle(fontFamily: 'Urbanist', fontSize: 15,
                  fontWeight: FontWeight.w700, color: _green1),
              filled: true, fillColor: _white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _green2.withOpacity(0.3))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _green2, width: 1.5)),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL',
                style: TextStyle(fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700, color: _gold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _green2, foregroundColor: _white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0),
            onPressed: () {
              final val =
                  double.tryParse(ctrl.text.replaceAll(',', ''));
              if (val != null && val > 0) {
                setState(() {
                  _targetRawMax   = val;
                  _targetMax      = '₱${_fmtK(val)}';
                  _targetProgress =
                      (_targetRawCur / val).clamp(0.0, 1.0);
                });
                // TODO: await dashboardService.setTarget(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('SAVE',
                style: TextStyle(fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  String _fmtK(double v) => v >= 1000
      ? '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k'
      : v.toStringAsFixed(0);

  void _goToOrders() => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              OrderScreen(activeIndex: 1, onLogout: widget.onLogout)));

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 254, 251),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Sidebar(activeIndex: widget.activeIndex, onLogout: widget.onLogout),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminHeader(title: 'DASHBOARD', onLogout: widget.onLogout),
                // ✅ Expanded + LayoutBuilder — no IntrinsicHeight, no
                //    unconstrained height conflicts.
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return _buildContent(constraints);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Content — uses LayoutBuilder constraints for true sizes ───────────────
  Widget _buildContent(BoxConstraints constraints) {
    const padding = 20.0;
    const gap     = 16.0;
    const leftW   = 280.0;

    // Right column width
    final rightW =
        constraints.maxWidth - leftW - gap - padding * 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left column ───────────────────────────────────────────────
          SizedBox(
            width: leftW,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TargetIncomeCard(
                  amount: _targetAmount,
                  progress: _targetProgress,
                  maxLabel: _targetMax,
                  onSetTarget: _showSetTargetDialog,
                ),
                const SizedBox(height: gap),
                _MenusCard(items: _menuItems),
              ],
            ),
          ),

          const SizedBox(width: gap),

          // ── Right column ──────────────────────────────────────────────
          SizedBox(
            width: rightW,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SummaryRow(cards: _summaryCards),
                const SizedBox(height: gap),
                _RevenueMapCard(bars: _revenueBars),
                const SizedBox(height: gap),
                _OrdersCard(
                  orders: _orders,
                  onViewAll: _goToOrders,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DAILY TARGET INCOME CARD
// ─────────────────────────────────────────────────────────────────────────────

class _TargetIncomeCard extends StatelessWidget {
  final String amount, maxLabel;
  final double progress;
  final VoidCallback onSetTarget;
  const _TargetIncomeCard({
    required this.amount,
    required this.progress,
    required this.maxLabel,
    required this.onSetTarget,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toStringAsFixed(0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dark gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF758C6D), Color(0xFF1C2419)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 4, height: 18,
                    decoration: BoxDecoration(
                        color: _beige,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 8),
                  Text('DAILY TARGET INCOME',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: _beige.withOpacity(0.85))),
                ]),
                const SizedBox(height: 14),
                Text(amount,
                    style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        color: _white)),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: _white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('Out of $maxLabel',
                        style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontStyle: FontStyle.italic,
                            fontSize: 10,
                            color: Colors.white60)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: _white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('$pct% reached',
                        style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _white)),
                  ),
                ]),
              ],
            ),
          ),

          // Progress bar + Set Target button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            color: _beige,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 9,
                            color: _green1.withOpacity(0.5))),
                    Text('$pct%',
                        style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            color: _green2)),
                    Text(maxLabel,
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 9,
                            color: _green1.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(builder: (_, box) => Stack(children: [
                  Container(
                      height: 8,
                      width: box.maxWidth,
                      decoration: BoxDecoration(
                          color: _green2.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10))),
                  Container(
                      height: 8,
                      width: box.maxWidth * progress.clamp(0.0, 1.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF758C6D), Color(0xFF3D5A45)]),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: _green2.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ],
                      )),
                ])),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: onSetTarget,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_gold, Color(0xFF8B6340)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: _gold.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.tune_rounded, color: _white, size: 14),
                          SizedBox(width: 7),
                          Text('SET TARGET',
                              style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                  color: _white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REVENUE MAP CARD
// ─────────────────────────────────────────────────────────────────────────────

class _RevenueMapCard extends StatelessWidget {
  final List<RevenueBarData> bars;
  const _RevenueMapCard({required this.bars});
  static const _yLabels = ['125k+', '100k', '75k', '50k', '25k', '0'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _beige,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _green2.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
              color: _green1.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(title: 'REVENUE MAP'),
          const SizedBox(height: 14),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis labels
                Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _yLabels
                        .map((l) => Text(l,
                            style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 9,
                                color: _green1.withOpacity(0.5))))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 10),
                // Bars + x-labels
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: bars
                              .map((b) => _RevenueBar(bar: b))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: bars
                            .map((b) => SizedBox(
                                  width: 28,
                                  child: Center(
                                    child: Text(b.month,
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 10,
                                            fontWeight: b.isHighlighted
                                                ? FontWeight.w800
                                                : FontWeight.w500,
                                            color: b.isHighlighted
                                                ? _green1
                                                : _green1.withOpacity(0.5))),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueBar extends StatelessWidget {
  final RevenueBarData bar;
  const _RevenueBar({required this.bar});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${bar.month}: ${bar.rawLabel}',
      child: LayoutBuilder(builder: (_, box) {
        const reservedTop = 20.0;
        final availH = box.maxHeight - reservedTop;
        final barH = (availH * bar.value).clamp(4.0, availH);

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: reservedTop,
              child: bar.isHighlighted
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                            color: _green1,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(bar.rawLabel,
                            style: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: _white)),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Container(
              width: 28,
              height: barH,
              decoration: BoxDecoration(
                gradient: bar.isHighlighted
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF758C6D), Color(0xFF1C2419)])
                    : null,
                color: bar.isHighlighted ? null : _gold.withOpacity(0.45),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                boxShadow: bar.isHighlighted
                    ? [
                        BoxShadow(
                            color: _green2.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, -2))
                      ]
                    : [],
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MENUS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _MenusCard extends StatelessWidget {
  final List<TopMenuItem> items;
  const _MenusCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final top5    = items.take(5).toList();
    final maxSold = top5.isEmpty ? 1 : top5.first.sold;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _beige,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _green2.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
              color: _green1.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            const _CardHeader(title: 'TOP 5 MENUS'),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('BY SALES',
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: _gold)),
            ),
          ]),
          const SizedBox(height: 16),
          // ✅ Column of items with intrinsic sizing — no Expanded inside Column
          ...top5.asMap().entries.map((e) {
            final ratio = e.value.sold / maxSold;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: e.key < top5.length - 1 ? 16 : 0),
              child: _MenuItemTile(
                  item: e.value, ratio: ratio, isFirst: e.key == 0),
            );
          }),
        ],
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final TopMenuItem item;
  final double ratio;
  final bool isFirst;
  const _MenuItemTile({
    required this.item,
    required this.ratio,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: isFirst ? _gold : _green2.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('#${item.rank}',
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      color: isFirst ? _white : _green2)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _green1)),
                Text('${item.price}  ·  ${item.sold} sold',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 10,
                        color: _green1.withOpacity(0.5))),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (_, box) => Stack(children: [
          Container(
              height: 4,
              width: box.maxWidth,
              decoration: BoxDecoration(
                  color: _green2.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10))),
          Container(
              height: 4,
              width: box.maxWidth * ratio,
              decoration: BoxDecoration(
                  color: isFirst ? _gold : _green2.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10))),
        ])),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ORDERS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _OrdersCard extends StatelessWidget {
  final List<DashboardOrderRow> orders;
  final VoidCallback onViewAll;
  const _OrdersCard({required this.orders, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final top5 = orders.take(5).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _beige,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _green2.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
              color: _green1.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const _CardHeader(title: 'RECENT ORDERS'),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _green2.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('TOP 5',
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: _green2)),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onViewAll,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_green2, _green1]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: _green2.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('VIEW ALL',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 0.5,
                            color: _white)),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_forward_rounded,
                        color: _white, size: 13),
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _green2.withOpacity(0.1)),
            ),
            child: Column(children: [
              const _OrderTableHeader(),
              ...top5.asMap().entries.map((e) => _OrderTableRow(
                    order: e.value,
                    isShaded: e.key.isEven,
                    isLast: e.key == top5.length - 1,
                  )),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Table header ──────────────────────────────────────────────────────────────

class _OrderTableHeader extends StatelessWidget {
  const _OrderTableHeader();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.7,
        color: _green1.withOpacity(0.55));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _beige.withOpacity(0.7),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(14)),
        border:
            Border(bottom: BorderSide(color: _green2.withOpacity(0.1))),
      ),
      child: Row(children: [
        Expanded(flex: 14, child: Text('ORDER ID',  style: style)),
        Expanded(flex: 20, child: Text('CUSTOMER',  style: style)),
        Expanded(flex: 13, child: Text('PAYMENT',   style: style)),
        Expanded(flex: 16, child: Text('STATUS',    style: style)),
        Expanded(flex: 22, child: Text('TIME',      style: style)),
        Expanded(flex: 15, child: Text('AMOUNT',    style: style)),
      ]),
    );
  }
}

// ── Table row ─────────────────────────────────────────────────────────────────

class _OrderTableRow extends StatelessWidget {
  final DashboardOrderRow order;
  final bool isShaded, isLast;
  const _OrderTableRow({
    required this.order,
    this.isShaded = false,
    this.isLast = false,
  });

  Color get _statusColor {
    switch (order.status.toLowerCase()) {
      case 'done':      return const Color(0xFF2E7D32);
      case 'pending':   return const Color(0xFFE65100);
      case 'preparing': return const Color(0xFF1565C0);
      case 'delivery':  return const Color(0xFF6A1B9A);
      case 'cancelled': return const Color(0xFFC62828);
      default:          return _green2;
    }
  }

  Color get _statusBg {
    switch (order.status.toLowerCase()) {
      case 'done':      return const Color(0xFFE8F5E9);
      case 'pending':   return const Color(0xFFFFF3E0);
      case 'preparing': return const Color(0xFFE3F2FD);
      case 'delivery':  return const Color(0xFFF3E5F5);
      case 'cancelled': return const Color(0xFFFFEBEE);
      default:          return _beige;
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 11,
        color: _green1.withOpacity(0.8));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isShaded ? _beige.withOpacity(0.35) : _white,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(14))
            : BorderRadius.zero,
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: _green2.withOpacity(0.07))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 14,
              child: Text(order.orderId,
                  style: base.copyWith(
                      fontWeight: FontWeight.w800, color: _gold))),
          Expanded(
              flex: 20,
              child: Text(order.customerName,
                  style: base.copyWith(
                      fontWeight: FontWeight.w700, color: _dark))),
          Expanded(
              flex: 13,
              child: Row(children: [
                Icon(
                  order.payment.toLowerCase() == 'paid'
                      ? Icons.check_circle_outline_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 13,
                  color: order.payment.toLowerCase() == 'paid'
                      ? const Color(0xFF4CAF50)
                      : Colors.redAccent,
                ),
                const SizedBox(width: 4),
                Text(order.payment, style: base),
              ])),
          Expanded(
            flex: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status,
                  style: base.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _statusColor,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              flex: 22,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(order.orderTime, style: base),
              )),
          Expanded(
              flex: 15,
              child: Text(order.amount,
                  style: base.copyWith(
                      fontWeight: FontWeight.w900, color: _dark))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  final String title;
  const _CardHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 4, height: 20,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_green2, _green1]),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 9),
      Text(title,
          style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              color: _green1)),
    ]);
  }
}