import 'package:flutter/material.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../core/widgets/admin_header.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../features/dashboard/presentation/admin/order_screen.dart';
import "package:frontend/core/models/dashboard_models.dart";
import './widgets/summary_row.dart';
import './widgets/target_income_card.dart';
import './widgets/revenue_map.dart';
import './widgets/card_header.dart';
import './widgets/show_set_target_dialog.dart';
import './widgets/menu_card.dart';
import './widgets/orders_card.dart';

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

  Future<void> _showSetTargetDialog() async {
    final value = await showSetTargetDialog(
      context,
      _targetRawMax,
    );

    if (value == null || value <= 0) return;

    setState(() {
      _targetRawMax = value;
      _targetMax = '₱${_fmtK(value)}';
      _targetProgress =
          (_targetRawCur / value).clamp(0.0, 1.0);
    });

    // TODO:
    // await dashboardService.updateTarget(value);
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
                TargetIncomeCard(
                  amount: _targetAmount,
                  progress: _targetProgress,
                  maxLabel: _targetMax,
                  onSetTarget: _showSetTargetDialog,
                ),
                const SizedBox(height: gap),
                MenusCard(items: _menuItems),
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
                RevenueMapCard(bars: _revenueBars),
                const SizedBox(height: gap),
                OrdersCard(
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
