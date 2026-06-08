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
import 'package:frontend/core/services/admin/dashboard_service.dart';

const _menuItems = <TopMenuItem>[
  TopMenuItem(rank: 1, name: 'Breaded Pork Red Pesto Pasta', price: '₱120', sold: 312),
  TopMenuItem(rank: 2, name: 'Truffle Pasta',                price: '₱100', sold: 287),
  TopMenuItem(rank: 3, name: 'Loaded Sausage Fries',         price: '₱100', sold: 256),
  TopMenuItem(rank: 4, name: 'Chicken Burger',               price: '₱95',  sold: 221),
  TopMenuItem(rank: 5, name: 'Biscoff (non-coffee)',         price: '₱200', sold: 194),
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
    final DashboardService dashboardService = DashboardService();

  bool isLoading = false;

  RevenueSummary? revenueSummary;
  DashboardSummary? dashboardSummary;

  List<TopMenuItem> topMenus = [];
  List<DashboardOrderRow> recentOrders = [];
  List<RevenueBarData> revenueTrend = [];

  List<SummaryCardData> get summaryCards {
    return [
      SummaryCardData(
        label: 'TOTAL CUSTOMERS',
        value:
            '${dashboardSummary?.customers ?? 0}',
        delta: '+0%',
        deltaPositive: true,
        icon: Icons.people_outline_rounded,
        accent: const Color(0xFF4CAF50),
      ),
      SummaryCardData(
        label: 'TOTAL SALES',
        value:
            '${dashboardSummary?.sales ?? 0}',
        delta: '+0%',
        deltaPositive: true,
        icon: Icons.show_chart_rounded,
        accent: const Color(0xFF2196F3),
      ),
      SummaryCardData(
        label: 'TOTAL INCOME',
        value:
            '₱${dashboardSummary?.revenue.toStringAsFixed(0) ?? "0"}',
        delta:
            '${revenueSummary?.growthRate ?? 0}%',
        deltaPositive:
            (revenueSummary?.growthRate ?? 0) >= 0,
        icon:
            Icons.account_balance_wallet_outlined,
        accent: const Color(0xFFA98258),
      ),
    ];
  }


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

  Future<void> loadDashboard() async {
    try {
      setState(() {
        isLoading = true;
      });

      final results = await Future.wait([
        dashboardService.getRevenueSummary(),
        dashboardService.getDashboardSummary(),
        dashboardService.getTopMenus(),
        dashboardService.getRecentOrders(),
        dashboardService.getRevenueTrend(),
      ]);

      revenueSummary =
          results[0] as RevenueSummary;

      dashboardSummary =
          results[1] as DashboardSummary;

      topMenus =
          results[2] as List<TopMenuItem>;

      recentOrders =
          results[3] as List<DashboardOrderRow>;

      revenueTrend =
          results[4] as List<RevenueBarData>;

      setState(() {});

    } catch (e) {
      debugPrint(
        'Dashboard Load Error: $e',
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _fmtK(double v) => v >= 1000
      ? '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k'
      : v.toStringAsFixed(0);

  void _goToOrders() => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              OrderScreen(activeIndex: 1, onLogout: widget.onLogout)));
  
  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

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
                MenusCard(
                  items: topMenus.isEmpty
                      ? _menuItems
                      : topMenus,
                ),
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
                SummaryRow(cards: summaryCards),
                const SizedBox(height: gap),
                RevenueMapCard(
                  bars: revenueTrend,
                ),
                const SizedBox(height: gap),
                OrdersCard(
                  orders: recentOrders,
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
