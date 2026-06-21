import 'package:flutter/material.dart';

class OrdersTab extends StatelessWidget {
  final Map<String, dynamic> ordersData;

  const OrdersTab({
    super.key,
    required this.ordersData,
  });

  @override
  Widget build(BuildContext context) {
    final int totalOrders =
        int.tryParse(ordersData['total_orders']?.toString() ?? '0') ?? 0;

    final int dineInOrders =
        int.tryParse(ordersData['dine_in_orders']?.toString() ?? '0') ?? 0;

    final int takeoutOrders =
        int.tryParse(ordersData['takeout_orders']?.toString() ?? '0') ?? 0;

    final int deliveryOrders =
        int.tryParse(ordersData['delivery_orders']?.toString() ?? '0') ?? 0;

    final double orderGrowth =
      double.tryParse(
        ordersData['order_growth']?.toString() ?? '0',
      ) ??
      0;

    final String peakOrderTime =
        ordersData['peak_order_time']?.toString() ?? 'N/A';
    final bool isAllTime = ordersData['is_all_time'] == true;
   
    return Row(
  
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
                children: [
                  Text(
                    '$totalOrders',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  if (!isAllTime)
                    _StatPill(
                      icon: orderGrowth >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      label:
                          '${orderGrowth >= 0 ? '+' : ''}${orderGrowth.toStringAsFixed(1)}% vs previous period',
                      color: orderGrowth >= 0
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
                  children: [
                    _OrderTypeCol(
                      label: 'Dine in',
                      value: dineInOrders.toString(),
                    ),
                    const _VDivider(),
                    _OrderTypeCol(
                      label: 'Takeout',
                      value: takeoutOrders.toString(),
                    ),
                    const _VDivider(),
                    _OrderTypeCol(
                      label: 'Delivery',
                      value: deliveryOrders.toString(),
                    ),
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
                  children: [
                    Text(
                      'Peak Order Time',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Text(
                      peakOrderTime,
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