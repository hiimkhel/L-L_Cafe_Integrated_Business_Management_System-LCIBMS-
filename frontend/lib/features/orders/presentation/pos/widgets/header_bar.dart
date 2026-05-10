import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/config/theme/app_text_styles.dart';
import 'package:frontend/features/orders/presentation/pos/screens/order_history_screen.dart ';
import 'package:frontend/features/dashboard/presentation/pos/order_entry.dart';

class HeaderBar extends StatelessWidget {
  final String title;

 final int preparingCount;

  const HeaderBar({
    super.key,
    required this.title,
    required this.preparingCount,
  });
  

  @override
  Widget build(BuildContext context) {
    return Container(
      
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          _backButton(context),
          const SizedBox(width: 24),

          /// TITLE SECTION
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.secondary
              )),
              const Text(
                "REAL-TIME SYSTEM MONITORING",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.tertiary
                ),
              ),
            ],
          ),

          const Spacer(),

        
          /// COUNTER
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "PREPARING",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                preparingCount.toString(),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

        _historyButton(context),

        const SizedBox(width: 16),

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
          builder: (context) => POSOrderScreen(),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.card,
      ),
    
  child: const Icon(Icons.arrow_back, color: AppColors.primary),
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
      child: const Icon(Icons.history, color: AppColors.primary),
    ),
  );
}

}
