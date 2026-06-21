import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';

const Color _cardBg  = AppColors.background;
const Color _accent  = Color(0xFF758C6D);
const Color _dark    = Color(0xFF2D2A26);
const Color _green1 = Color(0xFF3D5A45);
const Color _green2 = Color(0xFF758C6D);

// ─────────────────────────────────────────────────────────────────────────────
// BASE CARD
// ─────────────────────────────────────────────────────────────────────────────

class BaseCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const BaseCard(
      {required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withOpacity(0.12)),
        boxShadow: [BoxShadow(
            color: _dark.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 4, height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_green2, _green1]),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 9),
            Text(title,
                style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    color: _green1)),
            const Spacer(),
            if (trailing != null) trailing!,
          ]),
          const SizedBox(height: 14),
          Expanded(child: ClipRect(child: child)),
        ],
      ),
    );
  }

  
}
