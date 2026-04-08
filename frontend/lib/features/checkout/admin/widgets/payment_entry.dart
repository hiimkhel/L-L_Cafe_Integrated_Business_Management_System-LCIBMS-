import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/config/theme/app_text_styles.dart';

class PaymentEntry extends StatefulWidget {
  final double total;
  final double change;
  final Function(double) onCashChanged;

  const PaymentEntry({
    super.key,
    required this.total,
    required this.change,
    required this.onCashChanged,
  });

  @override
  State<PaymentEntry> createState() => _PaymentEntryState();
}

class _PaymentEntryState extends State<PaymentEntry> {
  double cashGiven = 0;
  int selectedMethod = 0; // 0 = Cash, 1 = Card, 2 = E-Wallet

  double get change => cashGiven - widget.total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 42.00, horizontal: 20.00),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            bottomLeft: Radius.circular(40),
            // right corners stay sharp
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.wallet_membership,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "PAYMENT ENTRY",
                  style: AppTextStyles.title
                ),
              ],
            ),
            const SizedBox(height: 15),


            // ====== Main Section for Payment Entry ========
            // ===== Main Section =====
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth, // takes the full width available
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        bottomLeft: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Payment Methods Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(child: _paymentMethodCard("Cash", Icons.payments, selectedMethod == 0, 0),),
                              const SizedBox(width: 8),
                              Expanded(child: _paymentMethodCard("Card", Icons.credit_card, selectedMethod == 1, 1),),
                              const SizedBox(width: 8),
                              Expanded(child: _paymentMethodCard("E-Wallet", Icons.account_balance_wallet, selectedMethod == 2, 2),),
                            ],
                          ),
                          const SizedBox(height: 15),

                          TextField(
                            keyboardType: TextInputType.number,
                            style: AppTextStyles.subtitle, // text inside input
                            decoration: InputDecoration(
                              labelText: "Amount Received",
                              prefixText: "₱ ",
                              
                              // Border styles
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.tertiary.withOpacity(0.3)),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.primary, width: 2),
                              ),

                              // Fill color
                              filled: true,
                              fillColor: AppColors.background.withOpacity(0.05),

                              // Label style
                              labelStyle: TextStyle(
                                color: AppColors.tertiary,
                              ),

                              // Padding inside input
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 14,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                cashGiven = double.tryParse(value) ?? 0;
                                widget.onCashChanged(cashGiven);
                              });
                            },
                          ),

                          const SizedBox(height: 10),
                          Row(
                          children: [100, 200, 500, 1000].map((amount) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      cashGiven = amount.toDouble();
                                      widget.onCashChanged(cashGiven);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: AppColors.background.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.tertiary,
                                        width: 1
                                      )
                                    ),
                                    child: Center(
                                      child: Text(
                                        "₱$amount",
                                        style: AppTextStyles.subtitle.copyWith(
                                          color: AppColors.tertiary
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              border: Border.all(
                                color: AppColors.tertiary.withOpacity(0.3),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide.none, // remove default border
                              ),
                              onPressed: () {
                                setState(() {
                                  cashGiven = widget.total;
                                  widget.onCashChanged(cashGiven);
                                });
                              },
                              child: Text(
                                "Exact Amount (₱${widget.total.toStringAsFixed(2)})",
                                style: AppTextStyles.subtitle.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: change >= 0 
                                  ? AppColors.secondary 
                                  : AppColors.alertColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "CHANGE DUE",
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 8,
                                        color: AppColors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.payments, 
                                      color: AppColors.white,
                                    ),
                                  ],
                                ),

                                Text(
                                  "₱${change.toStringAsFixed(2)}",
                                  style: AppTextStyles.title.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10,),

                          Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.receiptDark,
                                    offset: Offset(3, 4),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: change < 0 ? null : () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    elevation: 0, 
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0), 
                                    ),
                                  ),
                                  child: const Text("CONFIRM PAYMENT", style: TextStyle(color: AppColors.white)),
                                ),
                              ),
                          ),
                        ],
                      ),
                    )
                    
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodCard(String label, IconData icon, bool selected, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = index;
        });
      },
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : AppColors.background.withOpacity(0.4),
          borderRadius: BorderRadius.circular(21),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: selected ? AppColors.white : AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}