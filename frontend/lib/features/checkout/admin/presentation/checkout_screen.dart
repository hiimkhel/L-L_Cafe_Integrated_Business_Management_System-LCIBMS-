import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import '../widgets/order_summary.dart';
import '../widgets/payment_entry.dart';
import 'package:frontend/config/theme/app_text_styles.dart';

class CheckoutConfirmationScreen extends StatefulWidget {
  const CheckoutConfirmationScreen({super.key});


  @override
  State<CheckoutConfirmationScreen> createState() => _CheckoutConfirmationScreenState();

}
  class _CheckoutConfirmationScreenState extends State<CheckoutConfirmationScreen>{

    // TEMPORARY VALUES
    final List<Map<String, dynamic>> orderItems = [
      {"name": "Chicken Burger", "qty": 1, "price": 180.00},
      {"name": "S'more", "qty": 1, "price": 165.00},
      {"name": "Nutella Frappe", "qty": 1, "price": 140.00},
      {"name": "Nutella Frappe", "qty": 1, "price": 140.00},
      {"name": "Nutella Frappe", "qty": 1, "price": 140.00},
      {"name": "Nutella Frappe", "qty": 1, "price": 140.00},
      {"name": "Nutella Frappe", "qty": 1, "price": 140.00},
      {"name": "Nutella Frappe", "qty": 1, "price": 140.00},
      {"name": "Nutella Frappe", "qty": 1, "price": 140.00},
      {"name": "Nutella Frappe", "qty": 1, "price": 140.00},
      {"name": "Nutella Frappe", "qty": 1, "price": 140.00},
      {"name": "Nutella Frappe", "qty": 1, "price": 140.00},
      {"name": "Nutella Frappe", "qty": 1, "price": 140.00},
      {"name": "Nutella Frappe", "qty": 1, "price": 140.00},
    ];

    double cashGiven = 0;

    double get subtotal =>
        orderItems.fold(0, (sum, item) => sum + item["price"]);

    double get tax => subtotal * 0.12;

    double get total => subtotal + tax;

    double get change => cashGiven - total;
     @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(children: [
            _buildHeader(),
            Expanded(child: Row(children: [
              Expanded(flex: 4, child: OrderSummary(
                orderItems: orderItems,
                subtotal: subtotal,
                tax: tax,
                total: total
              )),
              Expanded(flex: 6, child: PaymentEntry(
                total: total,
                change: change,
                onCashChanged: (value) => setState(() => cashGiven = value),
                orderItems: orderItems
              )),
            ],),)
        ],)
      );
    }

    Widget _buildHeader(){
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.primary, width: 1),
          ),
        ),
        child: Row(children: [
          Container(
            decoration: BoxDecoration(
              
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 32
              ),

            ),
          ),

          const SizedBox(width: 15),

          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "CHECKOUT CONFIRMATION",
              style: AppTextStyles.title.copyWith(color: AppColors.secondary)
            ),
            Text(
              "FINAL PHASE OF TRANSACTION",
              style: AppTextStyles.body.copyWith(
                color: AppColors.tertiary,
              )
            ),
          ],
        ),
        ],)
        
      );
    }
  }

 
