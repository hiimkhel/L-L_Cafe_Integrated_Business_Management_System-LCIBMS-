import 'package:flutter/material.dart';
import 'package:frontend/core/models/dashboard_models.dart';

const Color _green1 = Color(0xFF3D5A45);
const Color _beige = Color(0xFFEFE2C9);

class SummaryCard extends StatelessWidget {
  final SummaryCardData data;

  const SummaryCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _beige,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: data.accent.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
              color: data.accent.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              color: data.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(data.icon, color: data.accent, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Flexible(
                  child: Text(data.value,
                      style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: _green1)),
                ),
                const SizedBox(width: 5),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(children: [
                    Icon(
                      data.deltaPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 10,
                      color: data.deltaPositive
                          ? const Color(0xFF4CAF50)
                          : Colors.redAccent,
                    ),
                    Text(data.delta,
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: data.deltaPositive
                                ? const Color(0xFF4CAF50)
                                : Colors.redAccent)),
                  ]),
                ),
              ]),
              Text(data.label,
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 8,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      color: _green1.withOpacity(0.55))),
            ],
          ),
        ),
      ]),
    );
  }
}