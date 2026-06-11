import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/admin_header.dart';
import 'dart:math' as math;
import 'package:frontend/core/widgets/admin_sidebar.dart';
import 'package:frontend/features/reports/presentation/widget/business_performance_card.dart';
import 'package:frontend/core/services/admin/sales_reports_services.dart';
import 'package:frontend/core/services/admin/pdf_admin_export.dart';
import 'package:frontend/features/customers/presentation/admin/customers_screen.dart';
import '../widget/sales_summary_card.dart';
import '../widget/base_card.dart';

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
                                child: SalesSummaryCard(
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
                              Expanded(flex: 1, child: _TopCustomersCard( customers: topCustomers, 
                              onViewAll: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CustomersScreen(
                                        onLogout: widget.onLogout,
                                      ),
                                    ),
                                  );
                                },)),
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
      return const BaseCard(
        title: 'TOP PICKS',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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

    // Limit to exactly 10 items maximum if it's a Top 10 list
    final displayItems = menuItems.take(10).toList();

    return BaseCard(
      title: 'TOP PICKS',
      trailing: _pill('${displayItems.length} ITEMS', _gold),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 5 items per row
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          // Adjusted aspect ratio to give vertical height for the stacked text metrics
          childAspectRatio: 1.5, 
        ),
        itemCount: displayItems.length,
        itemBuilder: (_, i) => _PickTile(
          item: displayItems[i],
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

  
  String getMenuImageUrl(String? imageName) {
    if (imageName == null || imageName.isEmpty) {
      return '';
    }

    return 'http://localhost:3006/uploads/menu-items/$imageName';
  }

@override
  Widget build(BuildContext context) {
    final String name = item['name']?.toString() ?? 'Unknown Item';
    final double price = double.tryParse(item['price'].toString()) ?? 0.0;
    final int sold = int.tryParse(item['total_sold'].toString()) ?? 0;
    
    final String imageUrl = getMenuImageUrl(
      item['image_url']?.toString(),
    );

    final double totalRevenue = price * sold;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16), // Softer corners for modern UI
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centered alignment strategy
        children: [
          // 1. HEADER: Image & Rank Badge Overlay Stack
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                        )
                      : _buildPlaceholderIcon(),
                ),
              ),
              // Floating Rank Badge over the image
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      color: Colors.white, // Crisp white contrast against accent theme
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 2. MIDDLE: Centered Item Typography
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: _dark,
                  height: 1.15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),
          const Divider(height: 1, color: Colors.black12), // Subtle separator 
          const SizedBox(height: 6),

          // 3. BOTTOM: Balanced Centered Metrics Box
          Row(
            children: [
              // Sold Counter
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'SOLD',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: _muted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      sold.toString(),
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: _dark,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Vertical Divider line between stats
              Container(width: 1, height: 16, color: Colors.black12),

              // Revenue Counter
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'REVENUE',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: _muted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '₱${totalRevenue.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: _dark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Extracted Helper Method for Clean Fallbacks
  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey.shade50,
      child: const Icon(
        Icons.fastfood_rounded,
        size: 20,
        color: _muted,
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// TOP CUSTOMERS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _TopCustomersCard extends StatelessWidget {
  final List<dynamic> customers;
    final VoidCallback? onViewAll;

  const _TopCustomersCard({
    required this.customers,
    this.onViewAll
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
        return BaseCard(
          title: 'TOP CUSTOMERS',
            trailing: GestureDetector(
              onTap: onViewAll,
              child: _pill('ALL', _primary),
            ),
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

    return BaseCard(
      title: 'TOP CUSTOMERS',
      trailing: GestureDetector(
        onTap: onViewAll,
        child: _pill('ALL', _primary),
      ),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: customers.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final customer = customers[i];

          final String customerName =
              customer['customer_name'] ??
              'Unknown Customer';

          final String profilePicture =
              customer['profile_picture'] ?? '';

          final double amount =
              double.tryParse(
                    customer['total_spent'].toString(),
                  ) ??
                  0;

          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [

                _rankBadge(i + 1),

                const SizedBox(width: 10),

                _buildAvatar(
                  customerName,
                  profilePicture,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: _dark,
                        ),
                      ),

                      const SizedBox(height: 2),
                    ],
                  ),
                ),

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
          );
        },
      ),
    );
  }


  Widget _buildAvatar(
    String customerName,
    String profilePicture,
  ) {
    if (profilePicture.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(profilePicture),
        backgroundColor: Colors.grey.shade200,
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: _primary.withOpacity(0.12),
      child: Text(
        getInitials(customerName),
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w900,
          fontSize: 11,
          color: _primary,
        ),
      ),
    );
  }

  Widget _rankBadge(int rank) {
    return SizedBox(
      width: 24,
      child: Text(
        '#$rank',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: _primary,
        ),
      ),
    );
  }
}



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