import 'dart:math' as math;
import 'package:flutter/material.dart';

const double _kMobile = 768;
const Color _kBambooColor = Color(0xFF758C6D);

// ─────────────────────────────────────────────────────────────────────────────
// GENTLE BREEZE BAMBOO BACKGROUND
// Each node now gets 1 or 2 leaves pseudo-randomly, so stalks look natural.
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
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
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

  static const List<List<double>> _stalks = [
    [0.04,  8.0, 0.07, 0.00],
    [0.10,  5.0, 0.06, 0.20],
    [0.18, 11.0, 0.08, 0.45],
    [0.27,  6.0, 0.06, 0.70],
    [0.35, 10.0, 0.07, 0.15],
    [0.45,  4.0, 0.05, 0.55],
    [0.54, 13.0, 0.08, 0.30],
    [0.62,  5.0, 0.06, 0.80],
    [0.70,  9.0, 0.07, 0.10],
    [0.78,  6.0, 0.06, 0.60],
    [0.86, 11.0, 0.08, 0.40],
    [0.93,  5.0, 0.05, 0.90],
  ];

  /// Deterministic leaf presence — no Random(), no state, always stable.
  /// Returns true ~67% of the time for a natural sparse look.
  bool _hasLeftLeaf(int stalkIdx, int seg) =>
      (stalkIdx * 7 + seg * 13) % 3 != 0;

  bool _hasRightLeaf(int stalkIdx, int seg) =>
      (stalkIdx * 11 + seg * 5 + 2) % 3 != 0;

  @override
  void paint(Canvas canvas, Size size) {
    final stalkList = _stalks.asMap().entries.toList();
    final stalksToUse =
        isMobile ? stalkList.where((e) => e.key.isEven).toList() : stalkList;

    for (final entry in stalksToUse) {
      final stalkIdx = entry.key;
      final stalk = entry.value;

      final xFrac = stalk[0];
      final w = stalk[1];
      final op = isMobile ? stalk[2] * 0.6 : stalk[2];
      final phase = stalk[3];

      final stalkSway =
          math.sin((t * math.pi * 2) + (phase * math.pi * 2)) * 0.021;

      final x = size.width * xFrac;
      final h = size.height;

      final paint = Paint()
        ..color = _kBambooColor.withOpacity(op)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, h);
      canvas.rotate(stalkSway);
      canvas.translate(0, -h);

      // Stalk body
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-w / 2, 0, w, h),
          Radius.circular(w / 2),
        ),
        paint,
      );

      // Nodes + leaves
      final nodePaint = Paint()
        ..color = _kBambooColor.withOpacity(op * 1.3)
        ..style = PaintingStyle.fill;

      final segCount = (h / 120).clamp(3, 8).toInt();

      for (int seg = 1; seg < segCount; seg++) {
        final nodeY = h * (seg / segCount);

        // Node joint
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-w / 2 - 1.5, nodeY - 1.5, w + 3, 3),
            const Radius.circular(1.5),
          ),
          nodePaint,
        );

        final leafLength = w * 3.5 + 14;
        final leafWidth = leafLength * 0.22;
        const leafSpeed = 3.5;
        const amplitude = 0.18;

        // ── Left leaf ────────────────────────────────────────────────────────
        if (_hasLeftLeaf(stalkIdx, seg)) {
          final leftPhase = phase + seg * 0.37;
          final leftFlutter = math.sin(
                  (t * math.pi * 2 * leafSpeed) + (leftPhase * math.pi * 2)) *
              amplitude;
          _drawLeaf(
            canvas,
            Offset(-w / 2, nodeY),
            math.pi * 0.75 + leftFlutter,
            leafLength,
            leafWidth,
            paint,
          );
        }

        // ── Right leaf ───────────────────────────────────────────────────────
        if (_hasRightLeaf(stalkIdx, seg)) {
          final rightPhase = phase + seg * 0.37 + 0.5;
          final rightFlutter = math.sin(
                  (t * math.pi * 2 * leafSpeed) + (rightPhase * math.pi * 2)) *
              amplitude;
          _drawLeaf(
            canvas,
            Offset(w / 2, nodeY),
            math.pi * 0.25 + rightFlutter,
            leafLength,
            leafWidth,
            paint,
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
      ..quadraticBezierTo(length * 0.65, width, 0, 0)
      ..close();
    c.drawPath(path, paint);
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _BreezePainter old) =>
      old.t != t || old.isMobile != isMobile;
}