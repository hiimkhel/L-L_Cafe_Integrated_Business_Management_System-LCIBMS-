import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';

class CheckoutConfirmationScreen extends StatefulWidget {
  const CheckoutConfirmationScreen({super.key});

  @override
  State<CheckoutConfirmationScreen> createState() => _CheckoutConfirmationScreenState();

}
  class _CheckoutConfirmationScreenState extends State<CheckoutConfirmationScreen>{
     @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(children: [
            _buildHeader(),
            Expanded(child: Row(children: [
              // Expanded(child: __buildOrderSummary()),
              // Expanded(child: _buildPaymentEntry()),
            ],),)
        ],)
      );
    }

    Widget _buildHeader(){
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        width: double.infinity,
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
                color: AppColors.tertiary,
              ),

            ),
          ),

          const SizedBox(width: 10),

          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "CHECKOUT CONFIRMATION",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            Text(
              "FINAL PHASE OF TRANSACTION",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.tertiary,
              ),
            ),
          ],
        ),
        ],)
        
      );
    }

    // Widget __buildOrderSummary(){

    // }

    // Widget _buildPaymentEntry(){

    // }
  }

 
