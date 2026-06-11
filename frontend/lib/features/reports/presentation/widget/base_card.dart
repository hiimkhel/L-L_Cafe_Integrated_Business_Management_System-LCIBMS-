import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';

const Color _cardBg  = AppColors.background;
const Color _accent  = Color(0xFF758C6D);
const Color _dark    = Color(0xFF2D2A26);

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
            Text(title,
                style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.5,
                    color: _dark)),
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
