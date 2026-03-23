import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/config/theme/app_text_styles.dart';

class HeaderBar extends StatelessWidget {
  final String title;

  const HeaderBar({
    super.key,
    required this.title, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          _backButton(),
          const SizedBox(width: 16),

          /// TITLE
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("ORDER QUEUE", style: AppTextStyles.title),
              SizedBox(height: 4),
              Text("REAL-TIME SYSTEM MONITORING",
                  style: AppTextStyles.small),
            ],
          ),

          const Spacer(),

          /// COUNTER
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text("IN PROGRESS", style: AppTextStyles.small),
              SizedBox(height: 4),
              Text("3", style: AppTextStyles.title),
            ],
          ),
        ],
      ),
    );
  }

  Widget _backButton() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.card,
      ),
      child: const Icon(Icons.arrow_back, color: AppColors.textDark),
    );
  }
}