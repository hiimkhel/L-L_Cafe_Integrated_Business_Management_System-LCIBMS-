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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wallet_membership, // Payment icon
                  color: AppColors.secondary, // optional, match your theme
                  
                ),
                SizedBox(width: 8),
                Text(
                  "PAYMENT ENTRY",
                  style: AppTextStyles.title
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Payment Methods
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _paymentMethodCard("Cash", Icons.payments, selectedMethod == 0, 0),
                _paymentMethodCard("Card", Icons.credit_card, selectedMethod == 1, 1),
                _paymentMethodCard("E-Wallet", Icons.account_balance_wallet, selectedMethod == 2, 2),
              ],
            ),
            const SizedBox(height: 15),

            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount Received (₱)",
                border: OutlineInputBorder(),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [100, 200, 500, 1000].map((amount) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      cashGiven = amount.toDouble();
                      widget.onCashChanged(cashGiven);
                    });
                  },
                  child: Text("₱$amount"),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    cashGiven = widget.total;
                    widget.onCashChanged(cashGiven);
                  });
                },
                child: Text("Exact Amount (₱${widget.total.toStringAsFixed(2)})"),
              ),
            ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: change >= 0 ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "CHANGE: ₱${change.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: change >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: change < 0 ? null : () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                ),
                child: const Text("CONFIRM PAYMENT"),
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
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: selected ? Colors.blue : Colors.black54),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.blue : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}