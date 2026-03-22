import 'package:flutter/material.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../config/theme/app_colors.dart';

class ReportsScreen extends StatefulWidget {
  final int activeIndex;
  const ReportsScreen({super.key, this.activeIndex = 3});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late int activeIndex;

  @override
  void initState() {
    super.initState();
    activeIndex = widget.activeIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar with index-based navigation
          Sidebar(
            activeIndex: activeIndex),

          // Main content
          Expanded(
            child: Center(
              child: Text(
                'This is the Sales And Reports Screen',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}