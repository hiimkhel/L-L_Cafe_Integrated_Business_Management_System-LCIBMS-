import 'package:flutter/material.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Row: stats on left, breakdown on right — fills available height
    return Row(
      // ✅ stretch so both sides fill the same height, letting us
      // align the bottom cards to each other at the end of each column
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left: total + trend ───────────────────────────────────────────
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end, // ← pushes card to bottom
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: const [
                  Text(
                    '150',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '+9 vs yesterday',
                    style: TextStyle(
                        color: Color(0xFF7BC67E), fontSize: 11),
                  ),
                ],
              ),
              const Text(
                'Total Orders',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Order type breakdown
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _OrderTypeCol(label: 'Dine in',  value: '50'),
                    _VDivider(),
                    _OrderTypeCol(label: 'Takeout',  value: '50'),
                    _VDivider(),
                    _OrderTypeCol(label: 'Delivery', value: '50'),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        // ── Right: peak time + mini bar chart ─────────────────────────────
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end, // ← matches left column
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Peak Order Time',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2–4pm',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    _MiniBarChart(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _OrderTypeCol extends StatelessWidget {
  final String label, value;
  const _OrderTypeCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black87)),
      ],
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: Colors.black12);
}

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart();

  @override
  Widget build(BuildContext context) {
    const heights = [0.3, 0.5, 0.4, 0.7, 0.9, 1.0, 0.8, 0.6];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: heights.map((h) {
        return Container(
          width: 8,
          height: 36 * h,
          decoration: BoxDecoration(
            color: const Color(0xFF3A6B3F),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );
  }
}