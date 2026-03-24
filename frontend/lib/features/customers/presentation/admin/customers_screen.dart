import 'package:flutter/material.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../config/theme/app_colors.dart';

class CustomersScreen extends StatefulWidget {
  final int activeIndex;
  const CustomersScreen({super.key, this.activeIndex = 4});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
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
                'This is the Customers Screen',
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