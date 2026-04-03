import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class AdminHeader extends StatelessWidget {
  final String title;

  const AdminHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withOpacity(.5)),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.tertiary,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          _topIcon(Icons.dark_mode_outlined),
          const SizedBox(width: 8),
          _topIcon(Icons.notifications_rounded),
          const SizedBox(width: 8),
          _topIcon(Icons.settings_rounded),
          const SizedBox(width: 10),
          Container(width: 2.5, height: 30, color: AppColors.tertiary),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.tertiary,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "L&L CAFE",
                style: TextStyle(fontSize: 10, color: AppColors.secondary),
              ),
              Text(
                "ADMIN",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tertiary,
                ),
              ),
              Container(height: 2, width: 35, color: Colors.black),
            ],
          ),
          const SizedBox(width: 12),
          _topIcon(Icons.logout_rounded),
        ],
      ),
    );
  }

  Widget _topIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary),
      ),
      child: Icon(icon, color: AppColors.tertiary, size: 25),
    );
  }
}
