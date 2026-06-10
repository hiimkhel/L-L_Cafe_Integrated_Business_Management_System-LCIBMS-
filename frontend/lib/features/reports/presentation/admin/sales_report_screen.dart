import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/admin_header.dart';
import 'dart:math' as math;
import 'package:frontend/core/widgets/admin_sidebar.dart';
import 'package:frontend/features/reports/presentation/widget/business_performance_card.dart';
import 'package:frontend/core/services/admin/sales_reports_services.dart';
import 'package:frontend/core/services/admin/pdf_admin_export.dart';

const Color _cardBg  = AppColors.background;
const Color _primary = Color(0xFF3D5A45);
const Color _accent  = Color(0xFF758C6D);
const Color _gold    = Color(0xFFA98258);
const Color _dark    = Color(0xFF2D2A26);
const Color _muted   = Color(0xFF8A8070);

class SalesReportScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final int activeIndex;

  const SalesReportScreen({
    super.key,
    required this.activeIndex,
    required this.onLogout,
  });

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  List<dynamic> topCustomers = [];
  List<dynamic> topMenuItems = [];

  Map<String, dynamic> revenueData = {};
  Map<String, dynamic> ordersData = {};
  Map<String, dynamic> salesData = {};

  List<dynamic> salesSummaryData = [];

  bool isLoading = true;
  static const List<String> _ranges = [
    'Last 24 hours',
    'Last 7 days',
    'Last 30 days',
    'Last 3 months',
    'This year',
    'All Time'
  ];
  String _selectedRange = _ranges[2];

  Map<String, String?> getDateRange() {
    final now = DateTime.now();

    switch (_selectedRange) {
      case 'Last 24 hours':
        return {
          'startDate': now
              .subtract(const Duration(days: 1))
              .toIso8601String()
              .split('T')
              .first,
          'endDate': now
              .toIso8601String()
              .split('T')
              .first,
        };

      case 'Last 7 days':
        return {
          'startDate': now
              .subtract(const Duration(days: 7))
              .toIso8601String()
              .split('T')
              .first,
          'endDate': now
              .toIso8601String()
              .split('T')
              .first,
        };

      case 'Last 30 days':
        return {
          'startDate': now
              .subtract(const Duration(days: 30))
              .toIso8601String()
              .split('T')
              .first,
          'endDate': now
              .toIso8601String()
              .split('T')
              .first,
        };

      case 'Last 3 months':
        return {
          'startDate': DateTime(
            now.year,
            now.month - 3,
            now.day,
          ).toIso8601String().split('T').first,
          'endDate': now
              .toIso8601String()
              .split('T')
              .first,
        };

      case 'This year':
        return {
          'startDate': '${now.year}-01-01',
          'endDate': now
              .toIso8601String()
              .split('T')
              .first,
        };

      case 'All Time':
        return {
          'startDate': null,
          'endDate': null,
        };

      default:
        return {
          'startDate': null,
          'endDate': null,
        };
    }
  }

  String getChartRange() {
    switch (_selectedRange) {
      case 'Last 24 hours':
        return 'last24hours';

      case 'Last 7 days':
        return 'last7days';

      case 'Last 30 days':
        return 'last30days';

      case 'Last 3 months':
        return 'last3months';

      case 'This year':
        return 'thisyear';

      case 'All Time':
        return 'alltime';

      default:
        return 'last24hours';
    }
  }

void _handleExport() async {

  try {
    setState(() => isLoading = true);

    final pdfBytes = await PdfExportService.generateSalesReportPdf(
      range: _selectedRange,
      topCustomers: topCustomers,
      topMenuItems: topMenuItems,
      revenueData: revenueData,
      ordersData: ordersData,
      salesData: salesData,
    );

    await PdfExportService.printPdf(pdfBytes);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF exported successfully')),
    );

  } catch (e) {
    debugPrint("EXPORT ERROR: $e");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export failed: $e'),
        backgroundColor: Colors.red,
      ),
    );

  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}

  Future<void> loadReports() async {
    final range = getDateRange();
    
    final startDate = range['startDate'];
    final endDate = range['endDate'];

    final ReportsService reportsService = ReportsService();
    final customers =
        await reportsService.getTopCustomers(startDate, endDate);

    final menuItems =
        await reportsService.getTopMenuItems(startDate, endDate);

     final revenue =
          await reportsService.getRevenueReport(
              startDate, endDate);

      final orders =
          await reportsService.getOrdersReport(
            startDate, endDate);

      final sales =
          await reportsService.getSalesDistributionReport(
            startDate, endDate);

      final salesSummary =
        await reportsService.getSalesSummaryReport(
          getChartRange()
        );

    setState(() {
      salesSummaryData = salesSummary;
      topCustomers = customers;
      topMenuItems = menuItems;

      revenueData = revenue;
      ordersData = orders;
      salesData = sales;

      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadReports();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Sidebar(activeIndex: 3, onLogout: widget.onLogout),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminHeader(
                    title: 'SALES & REPORTS', onLogout: widget.onLogout),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top bar (fixed height — shrinks to content)
                        _buildTopBar(),
                        const SizedBox(height: 16),

                        // ── Row 1: Business Performance + Sales Summary ────
                        Expanded(
                          flex: 52,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: BusinessPerformanceCard(
                                  revenueData: revenueData,
                                  ordersData: ordersData,
                                  salesData: salesData,
                                )
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _SalesSummaryCard(
                                  salesSummaryData: salesSummaryData,
                                  rangeLabel: _selectedRange,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Row 2: Top Picks + Top Customers ──────────────
                        Expanded(
                          flex: 44,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(flex: 3, child: _TopPicksCard( menuItems: topMenuItems)),
                              const SizedBox(width: 16),
                              Expanded(flex: 1, child: _TopCustomersCard( customers: topCustomers)),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildTopBar() {
    return Row(
      children: [
        _RangeSelector(
          selected: _selectedRange,
          options: _ranges,
          onChanged: (v) async {
            setState(() {
              _selectedRange = v;
              isLoading = true;
            });

            await loadReports();
          },
        ),
        const Spacer(),
        _ExportButton(onTap: _handleExport),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RANGE SELECTOR
// ─────────────────────────────────────────────────────────────────────────────

class _RangeSelector extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _RangeSelector({
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final renderBox = context.findRenderObject() as RenderBox;
        final offset    = renderBox.localToGlobal(Offset.zero);
        final size      = renderBox.size;

        final result = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
              offset.dx, offset.dy + size.height + 4, offset.dx + size.width, 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          elevation: 8,
          items: options.map((o) => PopupMenuItem<String>(
            value: o,
            child: Row(children: [
              Icon(
                o == selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 14,
                color: o == selected ? _accent : _muted,
              ),
              const SizedBox(width: 8),
              Text(o,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: o == selected ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 13,
                    color: o == selected ? _accent : _dark,
                  )),
            ]),
          )).toList(),
        );
        if (result != null) onChanged(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _accent.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(color: _dark.withOpacity(0.05), blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.calendar_today_outlined, size: 13, color: _accent),
          const SizedBox(width: 6),
          Text(selected,
              style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _dark)),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down_rounded, color: _accent, size: 18),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPORT BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ExportButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ExportButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(
              color: _primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.download_rounded, size: 16, color: Colors.white),
          SizedBox(width: 8),
          Text('EXPORT PDF',
              style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  color: Colors.white)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SALES SUMMARY CARD
// ─────────────────────────────────────────────────────────────────────────────

class _SalesSummaryCard extends StatelessWidget {
  final List<dynamic> salesSummaryData;
  final String rangeLabel;

  const _SalesSummaryCard({
    required this.salesSummaryData,
    required this.rangeLabel,
  });

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000)    return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }

  List<Map<String, dynamic>> _normalizeData() {
    final map = {
      for (final item in salesSummaryData)
        item['label'].toString(): item
    };

    switch (rangeLabel) {
      case 'Last 24 hours':
        return List.generate(24, (i) {
          final label = i.toString().padLeft(2, '0');

          return {
            'label': label,
            'sales': double.tryParse(
                  map[label]?['sales']?.toString() ?? '0',
                ) ??
                0,
          };
        });

      case 'Last 7 days':
        const days = [
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun',
        ];

        return days.map((day) {
          return {
            'label': day,
            'sales': double.tryParse(
                  map[day]?['sales']?.toString() ?? '0',
                ) ??
                0,
          };
        }).toList();

      case 'Last 30 days':
        const weeks = [
          'W1',
          'W2',
          'W3',
          'W4',
          'W5',
        ];

        return weeks.map((week) {
          return {
            'label': week,
            'sales': double.tryParse(
                  map[week]?['sales']?.toString() ?? '0',
                ) ??
                0,
          };
        }).toList();

      default:
        return salesSummaryData
            .map((e) => {
                  'label': e['label'],
                  'sales': double.tryParse(
                        e['sales'].toString(),
                      ) ??
                      0,
                })
            .toList();
    }
  }

  

  @override
  Widget build(BuildContext context) {
    
    final normalizedData = _normalizeData();

    final values = normalizedData
        .map((e) => e['sales'] as double)
        .toList();

    final labels = normalizedData
        .map((e) => e['label'].toString())
        .toList();

  final totalSales =
    values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

if (totalSales == 0) {
  return _BaseCard(
    title: 'SALES SUMMARY',
    child: const Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 42,
            color: _muted,
          ),
          SizedBox(height: 12),
          Text(
            'No sales recorded',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'No completed orders were recorded during this period.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

}
  final maxVal = values.reduce((a, b) => a > b ? a : b);
    if (salesSummaryData.isEmpty) {
    return _BaseCard(
      title: 'SALES SUMMARY',
      child: const Center(
        child: Text('No sales data available'),
      ),
    );
  }
   
    final step   = (maxVal / 4).ceilToDouble();
    final ticks  = List.generate(5, (i) => step * i);

    return _BaseCard(
      title: 'SALES SUMMARY',
      trailing: _pill(rangeLabel, _accent),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Y-axis labels
          SizedBox(
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: ticks.reversed.map((t) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(_fmt(t),
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 9,
                        color: _muted.withOpacity(0.7))),
              )).toList(),
            ),
          ),
          const SizedBox(width: 8),
          // Bars + x-labels
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: math.max(
                  labels.length * 35.0,
                  300,
                ),
                child: Column(children: [
              Expanded(
                child: LayoutBuilder(builder: (_, box) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(values.length, (i) {
                      final ratio  = maxVal > 0 ? values[i] / maxVal : 0.0;
                      final maxIndex = values.indexOf(maxVal);
                      final isMax = i == maxIndex;
                      final barH   = (box.maxHeight * ratio)
                          .clamp(0.0, box.maxHeight - (isMax ? 20.0 : 0.0));
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isMax)
                                Text(_fmt(values[i]),
                                    style: const TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: _primary)),
                              const SizedBox(height: 2),
                              Container(
                                height: barH,
                                decoration: BoxDecoration(
                                  color: isMax
                                      ? _primary
                                      : _accent.withOpacity(0.55),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(labels.length, (i) => Expanded(
                  child: Center(
                    child: Text(labels[i],
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _muted.withOpacity(0.8))),
                  ),
                )),
              ),
            ]),
          ),
            ),
          )
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP PICKS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _TopPicksCard extends StatelessWidget {
  final List<dynamic> menuItems;

  const _TopPicksCard({
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    if (menuItems.isEmpty) {
      return const _BaseCard(
        title: 'TOP PICKS',
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu_outlined,
                size: 42,
                color: _muted,
              ),
              SizedBox(height: 12),
              Text(
                'No menu sales found',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'No completed orders were recorded during this period.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return _BaseCard(
      title: 'TOP PICKS',
      trailing: _pill('${menuItems.length} ITEMS', _gold),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3.6,
        ),
        itemCount: menuItems.length,
        itemBuilder: (_, i) => _PickTile(
          item: menuItems[i],
          rank: i + 1,
        ),
      ),
    );
  }
}


class _PickTile extends StatelessWidget {
  final dynamic item;
  final int rank;

  const _PickTile({
    required this.item,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final String name =
        item['name']?.toString() ?? 'Unknown Item';

    final int sold =
        int.tryParse(item['total_sold'].toString()) ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                  color: _accent,
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: _dark,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'Sold: $sold',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 9,
                    color: _muted,
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
// TOP CUSTOMERS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _TopCustomersCard extends StatelessWidget {
  final List<dynamic> customers;

  const _TopCustomersCard({
    required this.customers,
  });

  String getInitials(String name) {
    if (name.trim().isEmpty) return '?';

    final parts = name.trim().split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      try{
        return const _BaseCard(
          title: 'TOP CUSTOMERS',
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 42,
                  color: _muted,
                ),
                SizedBox(height: 12),
                Text(
                  'No customer purchases found',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'No completed orders were recorded during this period.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }catch (e, stack) {
        print(e);
        print(stack);

        return const Center(
          child: Text('Error loading customers'),
        );
      }
     
    }

    final topAmount =
        double.parse(customers.first['total_spent'].toString());

    return _BaseCard(
      title: 'TOP CUSTOMERS',
      child: Column(
        children: List.generate(customers.length, (i) {
          final customer = customers[i];

          final String customerName =
              customer['customer_name'] ?? 'Unknown Customer';

          final double amount =
              double.parse(customer['total_spent'].toString());

          final double ratio =
              topAmount > 0 ? amount / topAmount : 0;

          final bool isLast =
              i == customers.length - 1;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 10,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        getInitials(customerName),
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          color: _primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: _dark,
                          ),
                        ),

                        const SizedBox(height: 4),

                        LayoutBuilder(
                          builder: (_, box) {
                            return Stack(
                              children: [
                                Container(
                                  height: 4,
                                  width: box.maxWidth,
                                  decoration: BoxDecoration(
                                    color: _accent.withOpacity(
                                      0.12,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 4,
                                  width:
                                      box.maxWidth * ratio,
                                  decoration: BoxDecoration(
                                    color: _accent,
                                    borderRadius:
                                        BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    '₱${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: _gold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BASE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _BaseCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const _BaseCard(
      {required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withOpacity(0.12)),
        boxShadow: [BoxShadow(
            color: _dark.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(title,
                style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.5,
                    color: _dark)),
            const Spacer(),
            if (trailing != null) trailing!,
          ]),
          const SizedBox(height: 14),
          Expanded(child: ClipRect(child: child)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PILL BADGE
// ─────────────────────────────────────────────────────────────────────────────

Widget _pill(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 9,
            letterSpacing: 1.2,
            color: color)),
  );
}