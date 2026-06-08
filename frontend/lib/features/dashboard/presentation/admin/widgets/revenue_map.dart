import 'package:flutter/material.dart';
import 'package:frontend/core/models/dashboard_models.dart';
import './card_header.dart';

const Color _green1 = Color(0xFF3D5A45);
const Color _green2 = Color(0xFF758C6D);
const Color _gold   = Color(0xFFA98258);
const Color _beige  = Color(0xFFEFE2C9);
const Color _white  = Colors.white;
const Color _dark   = Color(0xFF2D2A26);

class RevenueMapCard extends StatelessWidget {
  final List<RevenueBarData> bars;
  const RevenueMapCard({required this.bars});
  static const _yLabels = ['125k+', '100k', '75k', '50k', '25k', '0'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _beige,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _green2.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
              color: _green1.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(title: 'REVENUE MAP'),
          const SizedBox(height: 14),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis labels
                Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _yLabels
                        .map((l) => Text(l,
                            style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 9,
                                color: _green1.withOpacity(0.5))))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 10),
                // Bars + x-labels
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: bars
                              .map((b) => _RevenueBar(bar: b))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: bars
                            .map((b) => SizedBox(
                                  width: 28,
                                  child: Center(
                                    child: Text(b.month,
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 10,
                                            fontWeight: b.isHighlighted
                                                ? FontWeight.w800
                                                : FontWeight.w500,
                                            color: b.isHighlighted
                                                ? _green1
                                                : _green1.withOpacity(0.5))),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueBar extends StatelessWidget {
  final RevenueBarData bar;
  const _RevenueBar({required this.bar});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${bar.month}: ${bar.rawLabel}',
      child: LayoutBuilder(builder: (_, box) {
        const reservedTop = 20.0;
        final availH = box.maxHeight - reservedTop;
        final barH = (availH * bar.value).clamp(4.0, availH);

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: reservedTop,
              child: bar.isHighlighted
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                            color: _green1,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(bar.rawLabel,
                            style: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: _white)),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Container(
              width: 28,
              height: barH,
              decoration: BoxDecoration(
                gradient: bar.isHighlighted
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF758C6D), Color(0xFF1C2419)])
                    : null,
                color: bar.isHighlighted ? null : _gold.withOpacity(0.45),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                boxShadow: bar.isHighlighted
                    ? [
                        BoxShadow(
                            color: _green2.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, -2))
                      ]
                    : [],
              ),
            ),
          ],
        );
      }),
    );
  }
}
