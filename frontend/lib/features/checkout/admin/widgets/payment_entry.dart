import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/config/theme/app_text_styles.dart';

class PaymentEntry extends StatefulWidget {
  final double total;
  final double change;
  final Function(double) onCashChanged;
  final VoidCallback onSubmit;
  final List<Map<String, dynamic>> orderItems;

  const PaymentEntry({
    super.key,
    required this.total,
    required this.change,
    required this.onCashChanged,
    required this.orderItems,
    required this.onSubmit,
  });

  @override
  State<PaymentEntry> createState() => _PaymentEntryState();
}

class _PaymentEntryState extends State<PaymentEntry> {
  double cashGiven = 0;
  int selectedMethod = 0; // 0 = Cash, 1 = Card, 2 = E-Wallet

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = widget.change >= 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24.00, horizontal: 24.00),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.wallet_membership, size: 26, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                const Expanded(child: Text("PAYMENT ENTRY", style: AppTextStyles.title)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _paymentMethodCard("Cash", Icons.payments, selectedMethod == 0, 0)),
                        const SizedBox(width: 8),
                        Expanded(child: _paymentMethodCard("Card", Icons.credit_card, selectedMethod == 1, 1)),
                        const SizedBox(width: 8),
                        Expanded(child: _paymentMethodCard("E-Wallet", Icons.account_balance_wallet, selectedMethod == 2, 2)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.title.copyWith(fontSize: 22, color: AppColors.primary),
                      decoration: InputDecoration(
                        labelText: "Amount Received",
                        prefixText: "₱ ",
                        prefixStyle: AppTextStyles.title.copyWith(fontSize: 22, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.background.withOpacity(0.4),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.tertiary.withOpacity(0.3))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      ),
                      onChanged: (value) {
                        setState(() => cashGiven = double.tryParse(value) ?? 0);
                        widget.onCashChanged(cashGiven);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [100, 200, 500, 1000].map((amount) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() => cashGiven = amount.toDouble());
                                widget.onCashChanged(cashGiven);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.background.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.tertiary.withOpacity(0.5), width: 1)
                                ),
                                alignment: Alignment.center,
                                child: Text("₱$amount", style: AppTextStyles.subtitle.copyWith(color: AppColors.tertiary, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: canSubmit ? AppColors.secondary : Colors.redAccent.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(canSubmit ? "CHANGE DUE" : "INSUFFICIENT FUNDS", style: TextStyle(fontSize: 10, color: AppColors.white.withOpacity(0.9), fontWeight: FontWeight.w800, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text("₱${widget.change.toStringAsFixed(2)}", style: AppTextStyles.title.copyWith(color: AppColors.white, fontSize: 28)),
                    ],
                  ),
                  const Icon(Icons.payments, color: AppColors.white, size: 36),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canSubmit ? AppColors.primary : AppColors.tertiary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: canSubmit ? 4 : 0,
                ),
                onPressed: canSubmit ? widget.onSubmit : null,
                child: const Text("COMPLETE CHECKOUT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodCard(String label, IconData icon, bool selected, int index) {
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 85,
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : AppColors.background.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.secondary : AppColors.tertiary.withOpacity(0.2), width: selected ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: selected ? AppColors.white : AppColors.primary),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: selected ? AppColors.white : AppColors.primary)),
          ],
        ),
      ),
    );
  }
}