import 'package:flutter/material.dart';
import 'dart:math' as math;

class RevenueTab extends StatelessWidget {
  const RevenueTab({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Row: stats on left, gauge on right — fills all available height
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Left: stats ──────────────────────────────────────────────────
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Revenue amount
              const Text(
                '₱2,660',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Total Revenue',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Stat row
              Row(
                children: [
                  _StatPill(
                    icon: Icons.trending_up_rounded,
                    label: '+5% vs yesterday',
                    color: const Color(0xFF7BC67E),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mini breakdown
              _BreakdownRow(label: 'Online Orders', value: '₱2,000', ratio: 0.625),
              const SizedBox(height: 8),
              _BreakdownRow(label: 'Walk-in',       value: '₱660',  ratio: 0.375),
            ],
          ),
        ),

        const SizedBox(width: 20),

        // ── Right: gauge ─────────────────────────────────────────────────
        Expanded(
          flex: 3,
          child: LayoutBuilder(builder: (_, c) {
            // Make the gauge square based on available width
            final size = c.maxWidth.clamp(80.0, 200.0);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size,
                  height: size / 2 + 16,
                  child: CustomPaint(
                    painter: GaugePainter(progress: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '80%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'of monthly target',
                  style: TextStyle(color: Colors.white54, fontSize: 10),
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
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label, value;
  final double ratio;
  const _BreakdownRow(
      {required this.label, required this.value, required this.ratio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(color: Colors.white60, fontSize: 10)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(builder: (_, c) {
          return Stack(children: [
            Container(
              height: 3,
              width: c.maxWidth,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              height: 3,
              width: c.maxWidth * ratio,
              decoration: BoxDecoration(
                color: const Color(0xFFD4C89A),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ]);
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GAUGE PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class GaugePainter extends CustomPainter {
  final double progress;
  const GaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx     = size.width / 2;
    final cy     = size.height - 10;
    final radius = size.width / 2 - 12;

    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFFD4C89A)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      math.pi, math.pi, false, trackPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      math.pi, math.pi * progress, false, fillPaint,
    );
  }

  @override
  bool shouldRepaint(GaugePainter old) => old.progress != progress;
}