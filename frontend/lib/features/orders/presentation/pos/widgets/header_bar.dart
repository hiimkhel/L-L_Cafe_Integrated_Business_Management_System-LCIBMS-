import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/config/theme/app_text_styles.dart';
import 'package:frontend/features/orders/presentation/pos/screens/order_history_screen.dart ';
import 'package:frontend/features/dashboard/presentation/pos/order_entry.dart';

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
          _backButton(context),
          const SizedBox(width: 16),

          /// TITLE SECTION
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.title),
              const SizedBox(height: 4),
              const Text(
                "REAL-TIME SYSTEM MONITORING",
                style: AppTextStyles.small,
              ),
            ],
          ),

          const Spacer(),

          _historyButton(context),

         
          /// COUNTER
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text("IN PROGRESS", style: AppTextStyles.small),
              SizedBox(height: 4),
              Text("3", style: AppTextStyles.title),
            ],
          ),

          const SizedBox(width: 16),

          /// 🔥 HISTORY BUTTON (ADDED HERE)
          
        ],
      ),
    );
  }

Widget _backButton(BuildContext context) {
  return InkWell(
    borderRadius: BorderRadius.circular(50),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const POSOrderScreen(),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.card,
      ),
    
  child: const Icon(Icons.arrow_back, color: AppColors.textDark),
    ),
  );
}

Widget _historyButton(BuildContext context) {
  return InkWell(
    borderRadius: BorderRadius.circular(50),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OrderHistoryScreen(),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.card,
      ),
      child: const Icon(Icons.history, color: AppColors.textDark),
    ),
  );
}

}
