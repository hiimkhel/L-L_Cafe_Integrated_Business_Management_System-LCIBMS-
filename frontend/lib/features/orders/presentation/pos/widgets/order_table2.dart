import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'order_row2.dart';

class OrderTable2 extends StatelessWidget {
  const OrderTable2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),
      child: Column(
        children: [
          _header(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  OrderRow2(
                    id: "LL-402",
                    customer: "Marcus D.",
                    items: ["Chicken Burger x2", "Nutella Frappe x1"],

                    time: "9m",
                  ),
                  OrderRow2(
                    id: "LL-403",
                    customer: "Sarah K.",
                    items: ["Biscoff x1"],

                    time: "4m",
                  ),
                  OrderRow2(
                    id: "LL-401",
                    customer: "Jun P.",
                    items: ["Red Velvet x3", "S'more x2"],

                    time: "16m",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text("ORDER ID")),
          Expanded(flex: 3, child: Text("CUSTOMER")),
          Expanded(flex: 4, child: Text("ITEMS")),
          Expanded(flex: 3, child: Text("TIME")),
        ],
      ),
    );
  }
}