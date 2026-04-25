import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/config/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/admin_header.dart';
import 'package:frontend/core/widgets/admin_sidebar.dart';
import 'package:frontend/features/reports/presentation/widget/business_performance_card.dart';



class SalesReportScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const SalesReportScreen({super.key, required this.onLogout});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Row(
        children: [
          /// SIDEBAR
          Sidebar(activeIndex: 3, onLogout: widget.onLogout),

          /// MAIN CONTENT
          Expanded(
            child: Column(
              children: [
                AdminHeader(title: "SALES & REPORTS", onLogout: widget.onLogout),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _topBar(),
                        const SizedBox(height: 20),

                        Expanded(
                          child: Column(
                            children: [
                              /// TOP SECTION
                              Expanded(
                                flex: 9,
                                child: Row(
                                  children: [
                                    const Expanded(child: BusinessPerformanceCard()),
                                    const SizedBox(width: 16),
                                    Expanded(child: _salesSummaryCard()),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              /// BOTTOM SECTION
                              Expanded(
                                flex: 7,
                                child: Row(
                                  children: [
                                    Expanded(flex: 3, child: _topPicksCard()),
                                    const SizedBox(width: 16),
                                    Expanded(flex: 1, child: _topCustomersCard()),
                                  ],
                                ),
                              ),
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

  // ─────────────────────────────
  // TOP BAR
  // ─────────────────────────────

  Widget _topBar() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Text("Last 24 hours"),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),

        const Spacer(),

        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download),
          label: const Text("EXPORT CSV"),
        ),
      ],
    );
  }

  // ─────────────────────────────
  // SALES SUMMARY
  // ─────────────────────────────

  Widget _salesSummaryCard() {
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("SALES SUMMARY"),
          const SizedBox(height: 16),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// Y-AXIS
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(8, (index) {
                    final value = (20000 ~/ 7) * (7 - index);
                    return Text(
                      value.toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  }),
                ),

                const SizedBox(width: 8),

                /// CHART
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(
                            7,
                            (index) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                height: (index + 2) * 30,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: List.generate(
                          7,
                          (index) => Expanded(
                            child: Center(
                              child: Text(
                                days[index],
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ),
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

  // ─────────────────────────────
  // TOP PICKS
  // ─────────────────────────────

  Widget _topPicksCard() {
    return _baseCard(
      title: "TOP PICKS",
      child: Wrap(
        spacing: 45,
        runSpacing: 70,
        alignment: WrapAlignment.spaceAround,
        children: List.generate(
          8,
          (index) => SizedBox(
            width: 200,
            child: Row(
              children: [
                const CircleAvatar(radius: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Item ${index + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Sold: ${index * 5 + 10}"),
                      Text("Price: ₱${(index + 1) * 100}"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────
  // TOP CUSTOMERS
  // ─────────────────────────────

  Widget _topCustomersCard() {
    return _baseCard(
      title: "TOP CUSTOMER",
      child: Column(
        children: List.generate(
          4,
          (index) => ListTile(
            leading: const CircleAvatar(),
            title: const Text("John Doe"),
            trailing: const Text("₱1000"),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────
  // BASE CARD
  // ─────────────────────────────

  Widget _baseCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}