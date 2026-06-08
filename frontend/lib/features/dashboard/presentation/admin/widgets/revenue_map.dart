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

  static const _yLabels = ['125k+', '100k', '75k', '50k', '25k', '0'];

  // 🔥 Track the index of the bar currently being hovered (null if none)
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
                    children: _yLabels
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(safeBars.length, (index) {
                        final b = safeBars[index];
                        final date = DateTime.parse(b.month);

                        final normalized = chartMax == 0
                            ? 0.0
                            : (b.value / chartMax).clamp(0.0, 1.0);

                        final height = (normalized * 160).clamp(4.0, 160.0);
                        final isTop = b.value >= chartMax;
                        
                        // Check if this specific bar is being hovered
                        final isHovered = _hoveredIndex == index;

                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) => setState(() => _hoveredIndex = index),
                          onExit: (_) => setState(() => _hoveredIndex = null),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // VALUE LABEL (Shows if b.value > 0 AND the bar is hovered)
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

                                  width: isHovered ? 34 : 28,

                                  height: isHovered
                                      ? (height + 8).clamp(4.0, 170.0)
                                      : height,

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
                                                isHovered
                                                    ? 1.0
                                                    : (b.value > 0 ? 0.7 : 0.1),
                                              ),
                                              _gold.withOpacity(
                                                isHovered
                                                    ? 0.7
                                                    : (b.value > 0 ? 0.3 : 0.05),
                                              ),
                                            ],
                                          ),

                                    boxShadow: (isTop || isHovered)
                                        ? [
                                            BoxShadow(
                                              color: isHovered
                                                  ? _gold.withOpacity(0.45)
                                                  : _green2.withOpacity(0.35),
                                              blurRadius: isHovered ? 16 : 10,
                                              spreadRadius: isHovered ? 2 : 0,
                                              offset: Offset(
                                                0,
                                                isHovered ? 1 : 3,
                                              ),
                                            ),
                                          ]
                                        : [],
                                  ),
                                ),

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
                        );
                      }),
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
