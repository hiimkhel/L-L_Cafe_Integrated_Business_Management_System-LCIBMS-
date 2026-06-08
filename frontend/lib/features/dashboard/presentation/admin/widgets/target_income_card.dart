import 'package:flutter/material.dart';
import 'package:frontend/core/models/dashboard_models.dart';

const Color _green1 = Color(0xFF3D5A45);
const Color _green2 = Color(0xFF758C6D);
const Color _gold   = Color(0xFFA98258);
const Color _beige  = Color(0xFFEFE2C9);
const Color _white  = Colors.white;
const Color _dark   = Color(0xFF2D2A26);

class TargetIncomeCard extends StatelessWidget {
  final String amount, maxLabel;
  final double progress;
  final VoidCallback onSetTarget;
  const TargetIncomeCard({
    required this.amount,
    required this.progress,
    required this.maxLabel,
    required this.onSetTarget,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toStringAsFixed(0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dark gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF758C6D), Color(0xFF1C2419)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 4, height: 18,
                    decoration: BoxDecoration(
                        color: _beige,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 8),
                  Text('DAILY TARGET INCOME',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: _beige.withOpacity(0.85))),
                ]),
                const SizedBox(height: 14),
                Text(amount,
                    style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        color: _white)),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: _white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('Out of $maxLabel',
                        style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontStyle: FontStyle.italic,
                            fontSize: 10,
                            color: Colors.white60)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: _white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('$pct% reached',
                        style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _white)),
                  ),
                ]),
              ],
            ),
          ),

          // Progress bar + Set Target button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            color: _beige,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 9,
                            color: _green1.withOpacity(0.5))),
                    Text('$pct%',
                        style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            color: _green2)),
                    Text(maxLabel,
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 9,
                            color: _green1.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(builder: (_, box) => Stack(children: [
                  Container(
                      height: 8,
                      width: box.maxWidth,
                      decoration: BoxDecoration(
                          color: _green2.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10))),
                  Container(
                      height: 8,
                      width: box.maxWidth * progress.clamp(0.0, 1.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF758C6D), Color(0xFF3D5A45)]),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: _green2.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ],
                      )),
                ])),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: onSetTarget,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_gold, Color(0xFF8B6340)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: _gold.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.tune_rounded, color: _white, size: 14),
                          SizedBox(width: 7),
                          Text('SET TARGET',
                              style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                  color: _white)),
                        ],
                      ),
                    ),
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
