import 'dart:math' as math;
import 'package:flutter/material.dart';

const double _kMobile = 768;
const Color _kBambooColor = Color(0xFF758C6D);

// ─────────────────────────────────────────────────────────────────────────────
// GENTLE BREEZE BAMBOO BACKGROUND
// Mobile: denser stalks, more visible opacity, realistic layered wind.
// Desktop: unchanged calm sway with independent leaf flutter.
// ─────────────────────────────────────────────────────────────────────────────

class BreezeBambooBackground extends StatefulWidget {
  const BreezeBambooBackground({super.key});

  @override
  State<BreezeBambooBackground> createState() => _BreezeBambooBackgroundState();
}

class _BreezeBambooBackgroundState extends State<BreezeBambooBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // 45s — slow enough to feel calm, fast enough to see wind
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < _kMobile;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _BreezePainter(t: _ctrl.value, isMobile: isMobile),
        size: Size.infinite,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _BreezePainter extends CustomPainter {
  final double t;
  final bool isMobile;

  const _BreezePainter({required this.t, required this.isMobile});

  // Desktop stalks — full set across the screen
  // [xFraction, widthPx, opacityBase, phaseOffset]
  static const List<List<double>> _desktopStalks = [
    [0.03,  8.0, 0.07, 0.00],
    [0.08,  5.0, 0.06, 0.18],
    [0.13, 11.0, 0.08, 0.42],
    [0.19,  6.0, 0.06, 0.67],
    [0.25, 10.0, 0.07, 0.13],
    [0.31,  4.0, 0.05, 0.52],
    [0.37, 13.0, 0.08, 0.28],
    [0.43,  5.0, 0.06, 0.78],
    [0.49,  9.0, 0.07, 0.08],
    [0.55,  6.0, 0.06, 0.58],
    [0.61, 11.0, 0.08, 0.38],
    [0.67,  5.0, 0.05, 0.88],
    [0.73,  8.0, 0.07, 0.22],
    [0.79, 12.0, 0.08, 0.48],
    [0.85,  5.0, 0.06, 0.72],
    [0.91,  9.0, 0.07, 0.35],
    [0.96,  6.0, 0.06, 0.95],
  ];

static const List<List<double>> _mobileStalks = [
    // [X-Position, Thickness, Opacity, Y-Offset/Phase]
    [0.05,  8.0, 0.13, 0.00], // Far left
    [0.22,  5.0, 0.11, 0.25], // Mid left
    [0.40, 10.0, 0.14, 0.50], // Center left
    [0.60,  6.0, 0.11, 0.10], // Center right
    [0.78,  9.0, 0.13, 0.70], // Mid right
    [0.95,  7.0, 0.12, 0.85], // Far right
  ];

  // Realistic multi-layer wind:
  // Layer 1 — primary slow gust (base sway)
  // Layer 2 — secondary faster ripple (mid-frequency)
  // Layer 3 — high-frequency micro-tremor (realistic turbulence)
  double _stalkSway(double phase) {
    final gust    = math.sin((t * math.pi * 2 * 0.8)  + phase * math.pi * 2) * 0.018;
    final ripple  = math.sin((t * math.pi * 2 * 2.1)  + phase * math.pi * 2 + 1.2) * 0.007;
    final tremor  = math.sin((t * math.pi * 2 * 5.3)  + phase * math.pi * 2 + 0.5) * 0.003;
    return gust + ripple + tremor;
  }

  double _leafFlutter(double phase, int seg, bool isLeft) {
    final basePhase = phase + seg * 0.37 + (isLeft ? 0.0 : 0.5);
    // Leaves react faster than stalks and have more variation
    final sway1 = math.sin((t * math.pi * 2 * 3.2) + basePhase * math.pi * 2) * 0.20;
    final sway2 = math.sin((t * math.pi * 2 * 6.7) + basePhase * math.pi * 2 + 0.8) * 0.08;
    final sway3 = math.sin((t * math.pi * 2 * 1.4) + basePhase * math.pi * 2 + 2.1) * 0.05;
    return sway1 + sway2 + sway3;
  }

  bool _hasLeftLeaf(int stalkIdx, int seg) =>
      (stalkIdx * 7 + seg * 13) % 3 != 0;

  bool _hasRightLeaf(int stalkIdx, int seg) =>
      (stalkIdx * 11 + seg * 5 + 2) % 3 != 0;

  @override
  void paint(Canvas canvas, Size size) {
    final stalks = isMobile ? _mobileStalks : _desktopStalks;

    for (int si = 0; si < stalks.length; si++) {
      final stalk = stalks[si];
      final xFrac = stalk[0];
      final w     = stalk[1];
      final op    = stalk[2];
      final phase = stalk[3];

      final sway = _stalkSway(phase);
      final x = size.width * xFrac;
      final h = size.height;

      final paint = Paint()
        ..color = _kBambooColor.withOpacity(op)
        ..style = PaintingStyle.fill;

      canvas.save();
      // Pivot from bottom so the stalk rocks like a real bamboo rooted in ground
      canvas.translate(x, h);
      canvas.rotate(sway);
      canvas.translate(0, -h);

      // Stalk body with rounded cap
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-w / 2, 0, w, h),
          Radius.circular(w / 2),
        ),
        paint,
      );

      // Node joints + leaves
      final nodePaint = Paint()
        ..color = _kBambooColor.withOpacity((op * 1.35).clamp(0, 1))
        ..style = PaintingStyle.fill;

      // More segments on mobile so the detail is visible on shorter viewport
      final segCount = isMobile
          ? (h / 90).clamp(4, 10).toInt()
          : (h / 120).clamp(3, 8).toInt();

      for (int seg = 1; seg < segCount; seg++) {
        final nodeY = h * (seg / segCount);

        // Node ring
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-w / 2 - 1.5, nodeY - 1.5, w + 3, 3),
            const Radius.circular(1.5),
          ),
          nodePaint,
        );

        // Leaves are slightly bigger on mobile so they read at small scale
        final leafLength = isMobile ? w * 4.2 + 16 : w * 3.5 + 14;
        final leafWidth  = leafLength * 0.22;

        if (_hasLeftLeaf(si, seg)) {
          final flutter = _leafFlutter(phase, seg, true);
          _drawLeaf(
            canvas,
            Offset(-w / 2, nodeY),
            math.pi * 0.75 + flutter,
            leafLength, leafWidth, paint,
          );
        }

        if (_hasRightLeaf(si, seg)) {
          final flutter = _leafFlutter(phase, seg, false);
          _drawLeaf(
            canvas,
            Offset(w / 2, nodeY),
            math.pi * 0.25 + flutter,
            leafLength, leafWidth, paint,
          );
        }
      }

      canvas.restore();
    }
  }

  void _drawLeaf(
    Canvas c,
    Offset origin,
    double angle,
    double length,
    double width,
    Paint paint,
  ) {
    c.save();
    c.translate(origin.dx, origin.dy);
    c.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(length * 0.35, -width, length, 0)
      ..quadraticBezierTo(length * 0.65,  width, 0, 0)
      ..close();
    c.drawPath(path, paint);
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _BreezePainter old) =>
      old.t != t || old.isMobile != isMobile;
}