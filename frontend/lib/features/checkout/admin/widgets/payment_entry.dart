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
    // For cashless methods, we assume exact amount is paid via terminal/scan.
    final bool isCashless = selectedMethod != 0;
    final bool canSubmit = isCashless || widget.change >= 0;

    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.08), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Payment Method", style: AppTextStyles.title.copyWith(fontSize: 18, color: AppColors.primary)),
          const SizedBox(height: 20),
          
          // Payment Method Selector
          Row(
            children: [
              Expanded(child: _paymentCard("Cash", Icons.payments_outlined, 0)),
              const SizedBox(width: 12),
              Expanded(child: _paymentCard("Card", Icons.credit_card_outlined, 1)),
              const SizedBox(width: 12),
              Expanded(child: _paymentCard("E-Wallet", Icons.qr_code_scanner_outlined, 2)),
            ],
          ),
          
          const SizedBox(height: 32),

          // Dynamic Content Area (Cash Input vs QR Placeholder)
          Expanded(
            child: isCashless 
                ? _buildQRPlaceholder(selectedMethod == 1 ? "Card Terminal" : "E-Wallet")
                : _buildCashInput(),
          ),
          
          const SizedBox(height: 24),

          // Action Area
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCashless ? "NO CHANGE DUE" : (canSubmit ? "CHANGE DUE" : "INSUFFICIENT"), 
                      style: TextStyle(fontSize: 12, color: AppColors.tertiary, fontWeight: FontWeight.w700, letterSpacing: 1)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₱${(isCashless ? 0.0 : (widget.change < 0 ? 0 : widget.change)).toStringAsFixed(2)}", 
                      style: AppTextStyles.title.copyWith(color: canSubmit ? AppColors.secondary : Colors.redAccent, fontSize: 32, height: 1)
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSubmit ? AppColors.secondary : AppColors.background,
                    foregroundColor: canSubmit ? Colors.white : AppColors.tertiary,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: canSubmit ? widget.onSubmit : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("CHECKOUT", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1)),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle_outline_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── QR PLACEHOLDER (For Card & E-Wallet) ──────────────────────────────────
  Widget _buildQRPlaceholder(String methodLabel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.08), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2_rounded, size: 100, color: AppColors.primary.withOpacity(0.8)),
          const SizedBox(height: 16),
          Text(
            "Scan QR for $methodLabel",
            style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            "Awaiting payment confirmation of ₱${widget.total.toStringAsFixed(2)}",
            style: AppTextStyles.body.copyWith(color: AppColors.tertiary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── CASH INPUT SECTION ────────────────────────────────────────────────────
  Widget _buildCashInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Amount Received", style: AppTextStyles.title.copyWith(fontSize: 18, color: AppColors.primary)),
        const SizedBox(height: 16),
        TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.title.copyWith(fontSize: 28, color: AppColors.primary),
          decoration: InputDecoration(
            prefixText: "₱ ",
            prefixStyle: AppTextStyles.title.copyWith(fontSize: 28, color: AppColors.primary.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.15), width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          ),
          onChanged: (value) {
            setState(() => cashGiven = double.tryParse(value) ?? 0);
            widget.onCashChanged(cashGiven);
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [100, 200, 500, 1000].map((amount) {
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() => cashGiven = amount.toDouble());
                widget.onCashChanged(cashGiven);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Text("+ ₱$amount", style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _paymentCard(String label, IconData icon, int index) {
    final bool selected = selectedMethod == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = index;
          // Auto-fill exact amount if cashless to bypass manual input
          if (index != 0) {
            cashGiven = widget.total;
            widget.onCashChanged(cashGiven);
          } else {
            cashGiven = 0; // Reset when switching back to cash
            widget.onCashChanged(cashGiven);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 90,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.primary.withOpacity(0.1), 
            width: selected ? 2 : 1
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: selected ? AppColors.primary : AppColors.tertiary),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? AppColors.primary : AppColors.tertiary)),
            ],
          ),
        ),
      ),
    );
  }
}