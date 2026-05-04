import 'package:flutter/material.dart';
import 'dart:math' as math;

class AvgOrderTab extends StatelessWidget {
  const AvgOrderTab({super.key});

  static const _categories = [
    ('FOODS',      '₱35,000', Color(0xFFF5A623)),
    ('PARTY TRAY', '₱0',      Color(0xFFE74C3C)),
    ('WAFFLES',    '₱0',      Color(0xFF9B59B6)),
    ('COFFEE',     '₱40,000', Color(0xFF3498DB)),
    ('FRAPPE',     '₱0',      Color(0xFF2ECC71)),
    ('NON-COFFEE', '₱25,000', Color(0xFF1ABC9C)),
  ];

  static const _donutData = [35000.0, 0.0, 0.0, 40000.0, 0.0, 25000.0];
  static const _donutColors = [
    Color(0xFFF5A623), Color(0xFFE74C3C), Color(0xFF9B59B6),
    Color(0xFF3498DB), Color(0xFF2ECC71), Color(0xFF1ABC9C),
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ Row: stats + legend on left, donut on right — fills available height
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Left: amount + legend ─────────────────────────────────────────
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: const [
                Icon(Icons.bar_chart_rounded,
                    color: Colors.white70, size: 16),
                SizedBox(width: 6),
                Text('Number of Sales',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
              const SizedBox(height: 6),
              const Text(
                '₱90,000',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),

              // Legend grid
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: _categories.map((c) {
                  return SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: c.$3,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.$1,
                                  style: const TextStyle(
                                      fontSize: 8,
                                      color: Colors.white60)),
                              Text(c.$2,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        // ── Right: donut chart ────────────────────────────────────────────
        Expanded(
          flex: 3,
          child: LayoutBuilder(builder: (_, c) {
            final size = c.maxWidth.clamp(80.0, 180.0);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: DonutPainter(
                        data: _donutData, colors: _donutColors),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '200',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Weekly\nVisits',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white60, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DONUT PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class DonutPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;
  const DonutPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      if (data[i] == 0) continue;
      final sweep = (data[i] / total) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep - 0.05,
        false,
        Paint()
          ..color = colors[i]
          ..strokeWidth = 18
          ..style = PaintingStyle.stroke,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(DonutPainter old) => false;
}