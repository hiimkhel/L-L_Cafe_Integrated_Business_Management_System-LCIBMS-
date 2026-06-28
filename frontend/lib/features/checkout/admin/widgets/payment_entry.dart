import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/config/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/receipt.dart';
import 'package:frontend/features/orders/presentation/pos/screens/order_queue_screen.dart';
import 'package:frontend/core/models/receipt_model.dart';

class PaymentEntry extends StatefulWidget {
  final double total;
  final double change;
  final Function(double) onCashChanged;
  final Function(int) onSubmit; 
  final List<Map<String, dynamic>> orderItems;
  final bool isStacked;

  const PaymentEntry({
    super.key,
    required this.total,
    required this.change,
    required this.onCashChanged,
    required this.orderItems,
    required this.onSubmit,
    this.isStacked = false, 
  });

  @override
  State<PaymentEntry> createState() => _PaymentEntryState();
}

class _PaymentEntryState extends State<PaymentEntry> {
  double cashGiven = 0;
  int selectedMethod = 0; // 0 = Cash, 1 = Card, 2 = E-Wallet
  
  // 1. Added a controller to manually control the text inside the TextField
  final TextEditingController _cashController = TextEditingController();

  @override
  void dispose() {
    _cashController.dispose(); // Always dispose controllers to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCashless = selectedMethod != 0;
    final bool canSubmit = isCashless || widget.change >= 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: widget.isStacked ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // Clean Header
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.point_of_sale_rounded, size: 24, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Text("Payment Details", style: AppTextStyles.title.copyWith(fontSize: 18, color: AppColors.primary)),
              ],
            ),
          ),
          
          // Payment Method Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Row(
              children: [
                Expanded(child: _paymentCard("Cash", Icons.payments_rounded, 0)),
                const SizedBox(width: 12),
                Expanded(child: _paymentCard("Card", Icons.credit_card_rounded, 1)),
                const SizedBox(width: 12),
                Expanded(child: _paymentCard("E-Wallet", Icons.qr_code_scanner_rounded, 2)),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // Dynamic Content Area
          widget.isStacked 
            ? _buildDynamicContent(isCashless)
            : Expanded(child: _buildDynamicContent(isCashless)),

          // Bottom Action Area
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isCashless ? "NO CHANGE DUE" : (canSubmit ? "CHANGE DUE" : "INSUFFICIENT AMOUNT"), 
                        style: TextStyle(fontSize: 11, color: canSubmit ? AppColors.tertiary : Colors.redAccent, fontWeight: FontWeight.w800, letterSpacing: 1.0)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₱${(isCashless ? 0.0 : (widget.change < 0 ? 0 : widget.change)).toStringAsFixed(2)}", 
                        style: AppTextStyles.title.copyWith(color: canSubmit ? AppColors.primary : Colors.redAccent, fontSize: 28, height: 1)
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canSubmit ? AppColors.secondary : AppColors.tertiary.withOpacity(0.1),
                      foregroundColor: canSubmit ? Colors.white : AppColors.tertiary,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: canSubmit ? 4 : 0,
                      shadowColor: AppColors.secondary.withOpacity(0.4),
                    ),
                    onPressed: canSubmit ? () => widget.onSubmit(selectedMethod) : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("FINALIZE", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: canSubmit ? Colors.white : AppColors.tertiary)),
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle_rounded, size: 20, color: canSubmit ? Colors.white : AppColors.tertiary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicContent(bool isCashless) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
      child: isCashless 
          ? _buildQRPlaceholder(selectedMethod == 1 ? "Card Terminal" : "E-Wallet Scan")
          : _buildCashInput(),
    );
  }

  Widget _buildQRPlaceholder(String methodLabel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2_rounded, size: 80, color: AppColors.primary.withOpacity(0.8)),
          const SizedBox(height: 24),
          Text(
            methodLabel,
            style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Awaiting terminal sync for\n₱${widget.total.toStringAsFixed(2)}",
            style: AppTextStyles.body.copyWith(color: AppColors.tertiary, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCashInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Amount Received", style: AppTextStyles.body.copyWith(fontSize: 13, color: AppColors.tertiary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _cashController, // 2. Attached the controller here
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.title.copyWith(fontSize: 28, color: AppColors.primary),
            decoration: InputDecoration(
              prefixText: "₱ ",
              prefixStyle: AppTextStyles.title.copyWith(fontSize: 28, color: AppColors.tertiary.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            ),
            onChanged: (value) {
              setState(() => cashGiven = double.tryParse(value) ?? 0);
              widget.onCashChanged(cashGiven);
            },
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [100, 200, 500, 1000].map((amount) {
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  cashGiven = amount.toDouble();
                  // 3. Update the text field visually when a button is pressed
                  _cashController.text = amount.toString(); 
                });
                widget.onCashChanged(cashGiven);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: Text("+ ₱$amount", style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
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
          if (index != 0) {
            cashGiven = widget.total;
            // 4. Optionally clear the text box when shifting away from cash
            _cashController.clear(); 
            widget.onCashChanged(cashGiven);
          } else {
            cashGiven = 0; 
            _cashController.clear(); // Reset text when coming back to cash
            widget.onCashChanged(cashGiven);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: selected ? AppColors.secondary.withOpacity(0.3) : AppColors.primary.withOpacity(0.04), 
              blurRadius: 12, 
              offset: const Offset(0, 6)
            )
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: selected ? Colors.white : AppColors.primary),
              const SizedBox(height: 10),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}