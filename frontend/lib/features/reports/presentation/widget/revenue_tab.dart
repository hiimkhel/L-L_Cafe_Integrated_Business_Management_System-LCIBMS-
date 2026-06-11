import 'package:flutter/material.dart';
import 'dart:math' as math;

class RevenueTab extends StatelessWidget {
  final Map<String, dynamic> revenueData;

  const RevenueTab({
    super.key,
    required this.revenueData,
  });

  @override
  Widget build(BuildContext context) {
    final double totalRevenue =
        double.tryParse(revenueData['total_revenue']?.toString() ?? '0') ?? 0;

    final double onlineRevenue =
        double.tryParse(revenueData['online_revenue']?.toString() ?? '0') ?? 0;

    final double walkinRevenue =
        double.tryParse(revenueData['walkin_revenue']?.toString() ?? '0') ?? 0;

    final double monthlyTarget =
        double.tryParse(revenueData['monthly_target']?.toString() ?? '1') ?? 1;

    final double growthRate =
        double.tryParse(revenueData['growth_rate']?.toString() ?? '0') ?? 0;

    final double progress =
        monthlyTarget > 0 ? (totalRevenue / monthlyTarget).clamp(0.0, 1.0) : 0;
    final bool isAllTime = revenueData['is_all_time'] == true;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '₱${totalRevenue.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),

              const Text(
                'Total Revenue',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  if (!isAllTime)
                    _StatPill(
                      icon: growthRate >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      label:
                          '${growthRate >= 0 ? '+' : ''}${growthRate.toStringAsFixed(1)}% vs previous period',
                      color: growthRate >= 0
                          ? const Color(0xFF7BC67E)
                          : Colors.redAccent,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'No comparison available',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              _BreakdownRow(
                label: 'Online Orders',
                value: '₱${onlineRevenue.toStringAsFixed(2)}',
                ratio: totalRevenue > 0
                    ? onlineRevenue / totalRevenue
                    : 0,
              ),

              const SizedBox(height: 8),

              _BreakdownRow(
                label: 'Walk-in',
                value: '₱${walkinRevenue.toStringAsFixed(2)}',
                ratio: totalRevenue > 0
                    ? walkinRevenue / totalRevenue
                    : 0,
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          flex: 3,
          child: LayoutBuilder(
            builder: (_, c) {
              final size =
                  c.maxWidth.clamp(80.0, 200.0);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: size,
                    height: size / 2 + 16,
                    child: CustomPaint(
                      painter: GaugePainter(
                        progress: progress,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '₱${monthlyTarget.toStringAsFixed(0)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Monthly Target Progress',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white60,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              );
            },
          ),
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