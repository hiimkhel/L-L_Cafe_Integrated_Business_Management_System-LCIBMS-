import 'dart:math' as math;
import 'package:flutter/material.dart';

const Color _kGreen  = Color(0xFF758C6D);
const double _kMobile = 768;

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class BambooBackground extends StatefulWidget {
  const BambooBackground({super.key});

  @override
  State<BambooBackground> createState() => _BambooBackgroundState();
}

class _BambooBackgroundState extends State<BambooBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
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
        painter: _BreezyBambooPainter(wind: _ctrl.value, isMobile: isMobile),
        size: Size.infinite,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _BreezyBambooPainter extends CustomPainter {
  final double wind;
  final bool isMobile;

  const _BreezyBambooPainter({required this.wind, required this.isMobile});

  // ── ALL stalks (desktop) ──────────────────────────────────────────────────
  // [xFraction, widthPx, opacity, phaseOffset]
  static const _allStalks = <List<double>>[
    [0.03,  7.0, 0.07, 0.00],
    [0.10,  5.0, 0.05, 0.35],
    [0.18,  9.0, 0.08, 0.70],
    [0.26,  6.0, 0.06, 0.15],
    [0.35,  4.0, 0.05, 0.55],
    [0.44, 10.0, 0.08, 0.80],
    [0.52,  5.5, 0.06, 0.25],
    [0.60,  8.0, 0.07, 0.60],
    [0.68,  4.5, 0.05, 0.40],
    [0.76,  9.5, 0.08, 0.10],
    [0.84,  6.0, 0.06, 0.90],
    [0.92,  7.5, 0.07, 0.50],
    [0.97,  5.0, 0.05, 0.20],
  ];

  // ✅ MOBILE stalks — thicker widths, slightly higher opacity
  static const _mobileStalks = <List<double>>[
    [0.04,  10.0, 0.10, 0.00],
    [0.22,   9.0, 0.09, 0.40],
    [0.50,  12.0, 0.10, 0.70],
    [0.76,   9.0, 0.09, 0.20],
    [0.94,  10.0, 0.10, 0.55],
  ];

  // ── Smooth sway value ─────────────────────────────────────────────────────
  // Returns ±maxRad radians — stalk sways from its base like a real bamboo
  double _sway(double phase, {double maxRad = 0.025}) {
    final t = (wind + phase) % 1.0;
    return math.sin(t * 2 * math.pi) * maxRad;
  }

  // ── Realistic wavy bamboo leaf ────────────────────────────────────────────
  // Uses two cubic bezier curves to create an S-shaped midrib with
  // a tapered tip — much closer to a real bamboo leaf than a simple oval.
  // `wind` is passed in so the leaf tip can ripple as well as rotate.
  void _wavyLeaf(Canvas c, Offset origin, double angle, double len, double w,
      double phase, Paint p) {
    c.save();
    c.translate(origin.dx, origin.dy);
    c.rotate(angle);

    // Tip ripple — the leaf tip flutters slightly independently
    final tipRipple = math.sin(
          ((wind + phase + 0.3) % 1.0) * 2 * math.pi,
        ) *
        w *
        0.35; // subtle — just the tip, not the whole leaf

    final path = Path()
      ..moveTo(0, 0)
      // Upper edge: slight S-curve using two cubics
      ..cubicTo(
        len * 0.25, -w * 0.9,   // control 1 — sweeps up near base
        len * 0.65, -w * 1.1,   // control 2 — peaks before midpoint
        len,         tipRipple, // tip — animated ripple
      )
      // Lower edge: mirror S-curve back to base
      ..cubicTo(
        len * 0.65,  w * 0.9,  // control 1
        len * 0.25,  w * 0.5,  // control 2 — flatter near base
        0,           0,         // back to origin
      )
      ..close();

    c.drawPath(path, p);
    c.restore();
  }

  // Keep the simple leaf for any internal fallback use
  void _leaf(Canvas c, Offset origin, double angle, double len, double w,
      Paint p) {
    c.save();
    c.translate(origin.dx, origin.dy);
    c.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.35, -w, len, 0)
      ..quadraticBezierTo(len * 0.65,  w, 0, 0)
      ..close();
    c.drawPath(path, p);
    c.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint  = Paint()..isAntiAlias = true;
    final stalks = isMobile ? _mobileStalks : _allStalks;

    for (final b in stalks) {
      final xFrac = b[0];
      final w     = isMobile ? b[1] * 1.0 : b[1];   // full thickness on mobile
      // ✅ Mobile opacity slightly higher so the sparse stalks remain visible
      final op    = isMobile ? b[2] * 0.85 : b[2];
      final phase = b[3];

      final x     = size.width * xFrac;
      final h     = size.height;

      // Stalk sways gently from its root
      final stalkSway = _sway(phase);

      paint.color = _kGreen.withOpacity(op);

      canvas.save();
      canvas.translate(x, h);       // pivot at ground level
      canvas.rotate(stalkSway);
      canvas.translate(-w / 2, 0);

      // ── Stalk body ──────────────────────────────────────────────────────
      canvas.drawRect(Rect.fromLTWH(0, -h, w, h), paint);

      // ── Joints + leaves ─────────────────────────────────────────────────
      // ✅ Both mobile AND desktop get the same number of joints now
      const segCount = 5;
      final segH     = h / (segCount + 1);

      for (int i = 1; i <= segCount; i++) {
        final jointY = -(i * segH); // upward = negative

        // Knuckle ring
        canvas.drawRect(
          Rect.fromLTWH(-1.5, jointY - 1, w + 3, 2),
          paint,
        );

        // ✅ Leaves — natural size, wavy realistic shape
        final leafLen = isMobile ? w * 3.2 + 10 : w * 3.8 + 14;
        final leafW   = leafLen * 0.18; // slimmer = more realistic bamboo leaf

        // Each leaf gets its own phase so it flutters independently
        final leafPhase  = phase + 0.18 * i;
        final leafPhase2 = phase + 0.18 * i + 0.5; // offset for right leaf

        // Gentle primary sway — same as before
        final leafSway  = _sway(leafPhase,  maxRad: isMobile ? 0.045 : 0.040);
        final leafSway2 = _sway(leafPhase2, maxRad: isMobile ? 0.040 : 0.035);

        // Left leaf
        _wavyLeaf(
          canvas,
          Offset(0, jointY),
          math.pi * 0.75 + leafSway,
          leafLen,
          leafW,
          leafPhase,
          paint,
        );

        // Right leaf — every joint on mobile, alternating on desktop
        final showRight = isMobile || i.isOdd;
        if (showRight) {
          _wavyLeaf(
            canvas,
            Offset(w, jointY),
            math.pi * 0.25 - leafSway2,
            leafLen * 0.85,
            leafW   * 0.85,
            leafPhase2,
            paint,
          );
        }
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BreezyBambooPainter old) =>
      old.wind != wind || old.isMobile != isMobile;
}