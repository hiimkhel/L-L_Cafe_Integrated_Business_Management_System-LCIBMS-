import 'package:flutter/material.dart';
import 'package:frontend/core/models/dashboard_models.dart';
import './card_header.dart';

const Color _green1 = Color(0xFF3D5A45);
const Color _green2 = Color(0xFF758C6D);
const Color _gold   = Color(0xFFA98258);
const Color _beige  = Color(0xFFEFE2C9);

class RevenueMapCard extends StatefulWidget {
  final List<RevenueBarData> bars;

  const RevenueMapCard({super.key, required this.bars});

  @override
  State<RevenueMapCard> createState() => _RevenueMapCardState();
}

class _RevenueMapCardState extends State<RevenueMapCard> {
  double getChartMax(List<RevenueBarData> bars) {
    final maxValue = bars.fold<double>(
      0,
      (prev, e) => e.value > prev ? e.value : prev,
    );

    if (maxValue <= 0) return 1000;

    return maxValue * 1.2;
  }

  List<String> getYAxisLabels(double maxValue) {
    final step = maxValue / 5;

    return [
      formatPeso(maxValue),
      formatPeso(step * 4),
      formatPeso(step * 3),
      formatPeso(step * 2),
      formatPeso(step),
      '₱0',
    ];
  }

  

  int? _hoveredIndex;

  List<RevenueBarData> _normalize(List<RevenueBarData> input) {
    final Map<int, RevenueBarData> map = {};

    for (final b in input) {
      try {
        final cleanMonthStr = b.month.contains('-') && b.month.split('-').length == 2 
            ? "${b.month}-01" 
            : b.month;
            
        final date = DateTime.parse(cleanMonthStr);
        map[date.month] = b;
      } catch (_) {}
    }

    return List.generate(12, (i) {
      final monthIndex = i + 1;
      final existing = map[monthIndex];

      return RevenueBarData(
        month: "2026-${monthIndex.toString().padLeft(2, '0')}-01",
        value: existing?.value ?? 0.0,
        rawLabel: existing?.rawLabel ?? "₱0",
        isHighlighted: existing?.isHighlighted ?? false,
      );
    });
  }

  String _formatMonth(int month) {
    const months = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];
    return months[(month - 1).clamp(0, 11)];
  }
  
  String formatPeso(double value) {
    if (value >= 1000000) {
      return '₱${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '₱${(value / 1000).toStringAsFixed(1)}K';
    }

    return '₱${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    // Access widget.bars instead of bars since we are in a State class
    final safeBars = _normalize(widget.bars); 
    final chartMax = getChartMax(safeBars);
    final yLabels = getYAxisLabels(chartMax);

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
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(title: 'REVENUE MAP'),
          const SizedBox(height: 14),

          SizedBox(
            height: 240,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y AXIS
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: yLabels
                        .map(
                          (l) => Text(
                            l,
                            style: TextStyle(
                              fontSize: 9,
                              color: _green1.withOpacity(0.5),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(width: 10),

                // CHART
                Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(safeBars.length, (index) {
                        final b = safeBars[index];
                        final date = DateTime.parse(b.month);

                        final normalized = chartMax == 0
                            ? 0.0
                            : (b.value / chartMax).clamp(0.0, 1.0);

                        final height = b.value > 0
                          ? (normalized * 160).clamp(12.0, 160.0)
                          : 8.0;
                        final isTop = b.value >= chartMax;
                        
                        // Check if this specific bar is being hovered
                        final isHovered = _hoveredIndex == index;

                        return Expanded(
                          child: Tooltip(
                            message: 'Revenue: ${formatPeso(b.value)}',
                            preferBelow: false,
                            child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) => setState(() => _hoveredIndex = index),
                          onExit: (_) => setState(() => _hoveredIndex = null),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 150),
                                  opacity: (b.value > 0 && isHovered) ? 1.0 : 0.0,
                                  child: SizedBox(
                                    height: 14,
                                    child: Text(
                                      formatPeso(b.value),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: _green1,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 4),

                                // BAR
                               AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,

                                width: double.infinity,

                                height: height,

                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),

                                  gradient: isTop
                                      ? const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFF3D5A45),
                                            Color(0xFF1C2419),
                                          ],
                                        )
                                      : LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            _gold.withOpacity(
                                              isHovered ? 1.0 : (b.value > 0 ? 0.75 : 0.15),
                                            ),
                                            _gold.withOpacity(
                                              isHovered ? 0.7 : (b.value > 0 ? 0.35 : 0.05),
                                            ),
                                          ],
                                        ),

                                  boxShadow: isHovered
                                      ? [
                                          BoxShadow(
                                            color: _gold.withOpacity(0.4),
                                            blurRadius: 14,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                              ),
                                const SizedBox(height: 6),

                                const SizedBox(height: 8),

                                // MONTH LABEL
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    _formatMonth(date.month),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: (b.isHighlighted || isHovered)
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: (b.isHighlighted || isHovered)
                                          ? _green1
                                          : _green1.withOpacity(0.55),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                        );
                          
                      }),
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
