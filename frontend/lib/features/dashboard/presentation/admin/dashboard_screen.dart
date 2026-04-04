import 'package:flutter/material.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../core/widgets/admin_header.dart';
import '../../../../config/theme/app_colors.dart';

// ─────────────────────────────────────────────
// DATABASE-READY MODELS
// ─────────────────────────────────────────────

class SummaryCardData {
  final String label;
  final String value;
  final String delta;
  final IconData icon;
  const SummaryCardData({
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
  });
}

class DashboardOrderRow {
  final String orderId;
  final String customerName;
  final String payment;
  final String status;
  final String orderTime;
  final String amount;
  const DashboardOrderRow({
    required this.orderId,
    required this.customerName,
    required this.payment,
    required this.status,
    required this.orderTime,
    required this.amount,
  });
}

class TopMenuItem {
  final int rank;
  final String name;
  final String price;
  final String? imageUrl;
  const TopMenuItem({
    required this.rank,
    required this.name,
    required this.price,
    this.imageUrl,
  });
}

class RevenueBarData {
  final String month;
  final double value; // 0.0–1.0
  final bool isHighlighted;
  const RevenueBarData({
    required this.month,
    required this.value,
    this.isHighlighted = false,
  });
}

// ─────────────────────────────────────────────
// SAMPLE DATA  (replace with API calls)
// ─────────────────────────────────────────────

const _summaryCards = <SummaryCardData>[
  SummaryCardData(label: 'TOTAL CUSTOMERS', value: '389',     delta: '+1.2', icon: Icons.people_outline),
  SummaryCardData(label: 'TOTAL SALES',     value: '43,112',  delta: '+1.2', icon: Icons.show_chart),
  SummaryCardData(label: 'TOTAL INCOME',    value: '244,219', delta: '+1.2', icon: Icons.account_balance_wallet_outlined),
];

const _orders = <DashboardOrderRow>[
  DashboardOrderRow(orderId: '#12345', customerName: 'Juan Dela Cruz', payment: 'Paid',   status: 'Done',    orderTime: '02-06-26 12:35 PM', amount: '₱250'),
  DashboardOrderRow(orderId: '#12346', customerName: 'Juan Dela Cruz', payment: 'Paid',   status: 'Done',    orderTime: '02-06-26 12:35 PM', amount: '₱250'),
  DashboardOrderRow(orderId: '#12347', customerName: 'Juan Dela Cruz', payment: 'Paid',   status: 'Done',    orderTime: '02-06-26 12:35 PM', amount: '₱250'),
  DashboardOrderRow(orderId: '#12348', customerName: 'Juan Dela Cruz', payment: 'Paid',   status: 'Done',    orderTime: '02-06-26 12:35 PM', amount: '₱250'),
  DashboardOrderRow(orderId: '#12349', customerName: 'Juan Dela Cruz', payment: 'Paid',   status: 'Pending', orderTime: '02-06-26 12:35 PM', amount: '₱250'),
  DashboardOrderRow(orderId: '#12350', customerName: 'Juan Dela Cruz', payment: 'Unpaid', status: 'Done',    orderTime: '02-06-26 12:35 PM', amount: '₱250'),
];

const _menuItems = <TopMenuItem>[
  TopMenuItem(rank: 1, name: 'Breaded Pork Red Pesto Pasta', price: '₱120'),
  TopMenuItem(rank: 2, name: 'Truffle Pasta',                price: '₱100'),
  TopMenuItem(rank: 3, name: 'Loaded Sausage Fries',         price: '₱100'),
  TopMenuItem(rank: 4, name: 'Chicken Burger',               price: '₱95'),
  TopMenuItem(rank: 5, name: 'Biscoff (non-coffee)',         price: '₱200'),
  TopMenuItem(rank: 6, name: 'Habanero Mango',               price: '₱130'),
];

const _revenueBars = <RevenueBarData>[
  RevenueBarData(month: 'Jan', value: 0.88),
  RevenueBarData(month: 'Feb', value: 0.80),
  RevenueBarData(month: 'Mar', value: 0.41),
  RevenueBarData(month: 'Apr', value: 0.58),
  RevenueBarData(month: 'May', value: 0.83),
  RevenueBarData(month: 'Jun', value: 0.88),
  RevenueBarData(month: 'Jul', value: 0.75),
  RevenueBarData(month: 'Aug', value: 0.83),
  RevenueBarData(month: 'Sep', value: 0.89),
  RevenueBarData(month: 'Oct', value: 0.89, isHighlighted: true),
];

const double _targetProgress = 0.75;
const String  _targetAmount  = '₱ 7,000.56';
const String  _targetMax     = '₱10,100';
const double  _sidebarWidth  = 180;

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  final int activeIndex;
  const AdminDashboardScreen({super.key, this.activeIndex = 0});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late int activeIndex;

  @override
  void initState() {
    super.initState();
    activeIndex = widget.activeIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double totalH  = constraints.maxHeight;
          final double totalW  = constraints.maxWidth;
          final double bodyW   = (totalW - _sidebarWidth).clamp(300.0, 9999.0);
          final double padH    = 16.0;
          final double padW    = 20.0;
          final double innerW  = bodyW - (padW * 2);

          // Left column width (Target + Menus) ≈ 32% of inner
          final double leftW  = (innerW * 0.32).clamp(200.0, 290.0);
          // Right column width (Summary cards + Revenue + Orders)
          final double rightW = innerW - leftW - 12;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Sidebar ───────────────────────────
              Sidebar(activeIndex: activeIndex),

              // ── Main area ─────────────────────────
              SizedBox(
                width: bodyW,
                height: totalH,
                child: ColoredBox(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Universal header
                      const AdminHeader(title: 'DASHBOARD'),

                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(padH),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: padW - padH),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── LEFT COLUMN ─────────────────────
                                SizedBox(
                                  width: leftW,
                                  child: Column(
                                    children: [
                                      // Target income card
                                      _TargetIncomeCard(
                                        amount: _targetAmount,
                                        progress: _targetProgress,
                                        maxLabel: _targetMax,
                                      ),
                                      const SizedBox(height: 12),
                                      // Menus card
                                      _MenusCard(items: _menuItems),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // ── RIGHT COLUMN ────────────────────
                                SizedBox(
                                  width: rightW,
                                  child: Column(
                                    children: [
                                      // Summary cards row
                                      _SummaryRow(
                                        cards: _summaryCards,
                                        width: rightW,
                                      ),
                                      const SizedBox(height: 12),
                                      // Revenue map
                                      _RevenueMapCard(bars: _revenueBars),
                                      const SizedBox(height: 12),
                                      // Orders
                                      _OrdersCard(orders: _orders),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUMMARY CARDS ROW
// ─────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final List<SummaryCardData> cards;
  final double width;
  const _SummaryRow({required this.cards, required this.width});

  @override
  Widget build(BuildContext context) {
    final cardW = (width - 16) / 3;
    return Row(
      children: cards.asMap().entries.map((e) {
        return Row(
          children: [
            SizedBox(width: cardW, child: _SummaryCard(data: e.value)),
            if (e.key < cards.length - 1) const SizedBox(width: 8),
          ],
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// SUMMARY CARD
// ─────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final SummaryCardData data;
  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x28A98258), blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon in rounded square
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(data.value,
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: AppColors.primary)),
                    ),
                    const SizedBox(width: 3),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Text(data.delta,
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 11,
                              color: AppColors.secondary)),
                    ),
                  ],
                ),
                Text(data.label,
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 9,
                        letterSpacing: 0.4,
                        color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DAILY TARGET INCOME CARD
// ─────────────────────────────────────────────

class _TargetIncomeCard extends StatelessWidget {
  final String amount;
  final double progress;
  final String maxLabel;
  const _TargetIncomeCard({
    required this.amount,
    required this.progress,
    required this.maxLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark gradient section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF758C6D), Color(0xFF20261E)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        width: 6, height: 20, color: AppColors.background),
                    const SizedBox(width: 8),
                    Text('DAILY TARGET INCOME',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 12,
                            letterSpacing: 0.5,
                            color: AppColors.background)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(amount,
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        color: AppColors.background)),
                const SizedBox(height: 2),
                Text('Out of $maxLabel',
                    style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontStyle: FontStyle.italic,
                        fontSize: 10,
                        color: Colors.white60)),
              ],
            ),
          ),

          // Cream progress section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            color: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0%',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 10,
                            color: AppColors.primary)),
                    Text('${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 10,
                            color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 5),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(48),
                    ),
                    child: Text('Set Target',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 11,
                            color: AppColors.background)),
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

// ─────────────────────────────────────────────
// REVENUE MAP CARD
// ─────────────────────────────────────────────

class _RevenueMapCard extends StatelessWidget {
  final List<RevenueBarData> bars;
  const _RevenueMapCard({required this.bars});

  static const _yLabels = ['125k+', '100k', '75k', '50k', '25k', '0'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x28A98258), blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(title: 'REVENUE MAP'),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _yLabels
                      .map((l) => Text(l,
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 10,
                              color: AppColors.primary)))
                      .toList(),
                ),
                const SizedBox(width: 8),
                // Bars
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: bars.map((b) => _RevenueBar(bar: b)).toList(),
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
    const maxH = 175.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: maxH * bar.value,
          decoration: BoxDecoration(
            gradient: bar.isHighlighted
                ? const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF758C6D), Color(0xFF20261E)],
                  )
                : null,
            color: bar.isHighlighted
                ? null
                : AppColors.secondary.withOpacity(0.55),
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        const SizedBox(height: 4),
        Text(bar.month,
            style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 10,
                fontWeight:
                    bar.isHighlighted ? FontWeight.w800 : FontWeight.w400,
                color:
                    bar.isHighlighted ? Colors.black87 : Colors.black38)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// MENUS CARD
// ─────────────────────────────────────────────

class _MenusCard extends StatelessWidget {
  final List<TopMenuItem> items;
  const _MenusCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x28A98258), blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(title: 'MENUS'),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((e) => Column(
                children: [
                  _MenuItemRow(item: e.value),
                  if (e.key < items.length - 1)
                    Divider(
                        color: AppColors.secondary.withOpacity(0.3),
                        thickness: 1,
                        height: 12),
                ],
              )),
        ],
      ),
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  final TopMenuItem item;
  const _MenuItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 30,
            child: Text('#${item.rank}',
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: -0.8,
                    color: AppColors.secondary)),
          ),
          const SizedBox(width: 8),
          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 11,
                        color: AppColors.primary)),
                Text(item.price,
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: AppColors.primary)),
              ],
            ),
          ),
          // Image circle
          Container(
            width: 40,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.fastfood_outlined,
                color: AppColors.primary, size: 15),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ORDERS CARD
// ─────────────────────────────────────────────

class _OrdersCard extends StatelessWidget {
  final List<DashboardOrderRow> orders;
  const _OrdersCard({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x28A98258), blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const _CardHeader(title: 'ORDERS'),
              const Spacer(),
              _OutlineBtn(label: 'NEWEST'),
              const SizedBox(width: 8),
              _FilledBtn(label: 'VIEW ALL'),
            ],
          ),
          const SizedBox(height: 12),

          // Table
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const _OrderTableHeader(),
                ...orders.asMap().entries.map((e) =>
                    _OrderTableRow(order: e.value, isShaded: e.key.isEven)),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTableHeader extends StatelessWidget {
  const _OrderTableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.secondary);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('ORDER ID',      style: style)),
          Expanded(flex: 3, child: Text('CUSTOMER NAME', style: style)),
          Expanded(flex: 2, child: Text('PAYMENT',       style: style)),
          Expanded(flex: 2, child: Text('STATUS',        style: style)),
          Expanded(flex: 3, child: Text('ORDER TIME',    style: style)),
          Expanded(flex: 2, child: Text('AMOUNT',        style: style)),
        ],
      ),
    );
  }
}

class _OrderTableRow extends StatelessWidget {
  final DashboardOrderRow order;
  final bool isShaded;
  const _OrderTableRow({required this.order, this.isShaded = false});

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
        fontFamily: 'Urbanist', fontSize: 10, color: AppColors.primary);
    final statusColor = order.status.toLowerCase() == 'done'
        ? AppColors.secondary
        : AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
      decoration: BoxDecoration(
        color: isShaded ? AppColors.background : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(order.orderId,                    style: base)),
          Expanded(flex: 3, child: Text(order.customerName.toUpperCase(), style: base)),
          Expanded(flex: 2, child: Text(order.payment.toUpperCase(),      style: base)),
          Expanded(flex: 2, child: Text(order.status.toUpperCase(),       style: base.copyWith(color: statusColor))),
          Expanded(flex: 3, child: Text(order.orderTime,                  style: base)),
          Expanded(flex: 2, child: Text(order.amount,                     style: base.copyWith(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  final String title;
  const _CardHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
      ],
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  const _OutlineBtn({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.secondary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary)),
    );
  }
}

class _FilledBtn extends StatelessWidget {
  final String label;
  const _FilledBtn({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white)),
    );
  }
}