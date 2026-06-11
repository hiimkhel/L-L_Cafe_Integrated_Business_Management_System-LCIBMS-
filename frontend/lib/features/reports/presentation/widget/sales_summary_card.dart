import 'package:flutter/material.dart';
import './base_card.dart';
import 'dart:math' as math;


const Color _primary = Color(0xFF3D5A45);
const Color _accent  = Color(0xFF758C6D);
const Color _muted   = Color(0xFF8A8070);

class SalesSummaryCard extends StatefulWidget {
  final List<dynamic> salesSummaryData;
  final String rangeLabel;

  const SalesSummaryCard({
    super.key,
    required this.salesSummaryData,
    required this.rangeLabel,
  });

  @override
  State<SalesSummaryCard> createState() => _SalesSummaryCardState();
}

class _SalesSummaryCardState extends State<SalesSummaryCard> {
  int? hoveredIndex;

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }

  List<Map<String, dynamic>> _normalizeData() {
    final map = {
      for (final item in widget.salesSummaryData)
        item['label'].toString(): item
    };

    switch (widget.rangeLabel) {
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
        return widget.salesSummaryData
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
  return BaseCard(
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
    if (widget.salesSummaryData.isEmpty) {
    return BaseCard(
      title: 'SALES SUMMARY',
      child: const Center(
        child: Text('No sales data available'),
      ),
    );
  }
   
    final step   = (maxVal / 4).ceilToDouble();
    final ticks  = List.generate(5, (i) => step * i);

    return BaseCard(
      title: 'SALES SUMMARY',
      trailing: _pill(widget.rangeLabel, _accent),
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
                      final isHovered = hoveredIndex == i;
                      final isMax = i == maxIndex;
                      final showValue = isHovered || isMax;
                      final barH   = (box.maxHeight * ratio)
                          .clamp(0.0, box.maxHeight - (isMax ? 20.0 : 0.0));
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: MouseRegion(
                            onEnter: (_) {
                              setState(() {
                                hoveredIndex = i;
                              });
                            },
                            onExit: (_) {
                              setState(() {
                                hoveredIndex = null;
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedOpacity(
                                    opacity: showValue ? 1 : 0,
                                    duration: const Duration(milliseconds: 150),
                                    child: Text(
                                      _fmt(values[i]),
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: isHovered ? _primary : _primary,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 2),
                                Container(
                                  height: barH,
                                  decoration: BoxDecoration(
                                    color: isHovered
                                        ? _primary
                                        : isMax
                                            ? _primary.withOpacity(0.85)
                                            : _accent.withOpacity(0.55),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6)),
                                  ),
                                ),
                              ],
                            ),
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