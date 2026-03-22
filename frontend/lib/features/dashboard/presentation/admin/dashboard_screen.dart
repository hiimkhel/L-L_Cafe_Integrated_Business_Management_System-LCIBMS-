import 'package:flutter/material.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import "../../../../config/theme/app_colors.dart";
import 'menu_management.dart';
import 'order_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final int activeIndex;
  const AdminDashboardScreen({super.key, this.activeIndex = 0});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>{
  late int activeIndex;

  @override
  void initState(){
    super.initState();
    activeIndex = widget.activeIndex;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Row(
        children: [
          Sidebar(activeIndex: activeIndex),
          Expanded(
            child: Center(
              child: Text(
                'This is the Dashboard Screen',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tertiary,
                ),
              ),
            ),
          ),
        ]
      )
    );
  }
}