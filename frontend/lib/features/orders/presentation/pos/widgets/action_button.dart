import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/config/theme/app_text_styles.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.label,
    this.isPrimary = false,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isPrimary ? AppColors.secondary : AppColors.primary,
        foregroundColor:
            isPrimary ? Colors.white : AppColors.primary,
        elevation: isPrimary ? 2 : 0,
        side: isPrimary
            ? null
            : const BorderSide(color: AppColors.primary),
      ),
      onPressed: onPressed,
      child: Text(label, style: AppTextStyles.button),
    );
  }
}
