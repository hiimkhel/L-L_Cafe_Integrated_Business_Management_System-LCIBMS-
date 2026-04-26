import 'package:flutter/material.dart';
import 'dart:math' as math;

class AvgOrderTab extends StatelessWidget {
  const AvgOrderTab({super.key});

  static const _categories = [
    ("FOODS",      "\$35,000", Color(0xFFF5A623)),
    ("PARTY TRAY", "\$0",      Color(0xFFE74C3C)),
    ("WAFFLES",    "\$0",      Color(0xFF9B59B6)),
    ("COFFEE",     "\$40,000", Color(0xFF3498DB)),
    ("FRAPPE",     "\$0",      Color(0xFF2ECC71)),
    ("NON-COFFEE", "\$25,000", Color(0xFF1ABC9C)),
  ];

  static const _donutData   = [35000.0, 0.0, 0.0, 40000.0, 0.0, 25000.0];
  static const _donutColors = [
    Color(0xFFF5A623), Color(0xFFE74C3C), Color(0xFF9B59B6),
    Color(0xFF3498DB), Color(0xFF2ECC71), Color(0xFF1ABC9C),
  ];

  @override
  Widget build(BuildContext context) {
  return SizedBox(
  height: 264, // adjust as needed
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: const [
          Icon(Icons.attach_money, color: Colors.white70, size: 18),
          Text(
            "Number of Sales",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
        const Text(
          "\$90,000.00",
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 35), // reduced spacing
        Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CustomPaint(
                painter: DonutPainter(data: _donutData, colors: _donutColors),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "200",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "Weekly Visits",
                        style: TextStyle(color: Colors.white60, fontSize: 9),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 30), // reduced spacing
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  return SizedBox(
                    width: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 20,
                              decoration: BoxDecoration(
                                color: c.$3,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              c.$1,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          c.$2,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    )
    );
  }
}

class DonutPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;
  const DonutPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      if (data[i] == 0) continue;
      final sweep = (data[i] / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i]
        ..strokeWidth = 18
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweep - 0.05, false, paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(DonutPainter old) => false;
}