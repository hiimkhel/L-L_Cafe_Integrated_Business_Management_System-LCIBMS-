import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class AdminHeader extends StatelessWidget {
  final String title;

  const AdminHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: AppColors.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Page title ───────────────────────────
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: AppColors.secondary,
              letterSpacing: 2,
            ),
          ),

          const Spacer(),

          // ── Icon actions ─────────────────────────
          _HeaderIconBtn(icon: Icons.dark_mode_outlined),
          const SizedBox(width: 8),
          _HeaderIconBtn(icon: Icons.notifications_rounded),
          const SizedBox(width: 8),
          _HeaderIconBtn(icon: Icons.settings_rounded),

          const SizedBox(width: 12),

          // ── Vertical divider ─────────────────────
          Container(
            width: 2,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(width: 12),

          // ── Avatar ───────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),

          const SizedBox(width: 8),

          // ── Name + role ──────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'L&L CAFE',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'ADMIN',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                height: 1.5,
                width: 36,
                color: AppColors.primary.withOpacity(0.4),
              ),
            ],
          ),

          const SizedBox(width: 10),

          // ── Logout ───────────────────────────────
          _HeaderIconBtn(icon: Icons.logout_rounded),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE ICON BUTTON
// ─────────────────────────────────────────────

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderIconBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}