import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/receipt.dart';
import 'package:frontend/core/models/receipt_model.dart';

// ─────────────────────────────────────────────
// RECEIPT WIDGET (FULLY RESPONSIVE)
// ─────────────────────────────────────────────

class LLCafeReceipt extends StatelessWidget {
  final ReceiptData data;
  final VoidCallback? onPrint;
  final double itemsMaxHeight;

  const LLCafeReceipt({
    super.key,
    required this.data,
    this.onPrint,
    this.itemsMaxHeight = 250,
  });

  static const Color _brown   = AppColors.primary;
  static const Color _dark    = AppColors.receiptDark;
  static const Color _green   = AppColors.secondary;
  static const Color _cream   = AppColors.background;
  static const Color _white   = AppColors.textLight;
  static const Color _creamBg = AppColors.receiptBg; 

  String _peso(double v) => '₱${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Safe bounding logic for infinite constraints (e.g. scrollviews)
        final maxWidth = constraints.maxWidth.isInfinite ? 450.0 : constraints.maxWidth;
        final cardWidth = maxWidth < 450 ? maxWidth : 450.0;
        final hPad = (cardWidth * 0.08).clamp(16.0, 32.0);
        const radius = 24.0;

        return Center(
          child: Container(
            width: cardWidth,
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: const [
                BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 20)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(height: 12, color: _green),
                    Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 20),
                          _buildMetaRow('DATE:', data.formattedDate),
                          const SizedBox(height: 8),
                          _buildOrderBadge(),
                          const SizedBox(height: 8),
                          _buildMetaRow('ORDER TYPE:', data.orderType.label),
                          const SizedBox(height: 20),
                          _buildClientRow(),
                          const SizedBox(height: 20),
                          _buildItemsSection(),
                          const SizedBox(height: 20),
                          _buildTotalsCard(),
                          const SizedBox(height: 24),
                          _buildPaymentButton(),
                          const SizedBox(height: 12),
                          _buildThankYouText(),
                          const SizedBox(height: 20),
                          _buildPrintButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/lnl.jpg', width: 70, height: 70, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 70, height: 70, color: _cream, alignment: Alignment.center,
                  child: const Text('L&L', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: _brown)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text('L&L CAFE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: _dark, letterSpacing: 1)),
        const SizedBox(height: 4),
        const Text(
          'MAKING GOOD FOOD FOR PEOPLE\'S HAPPINESS',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 8, color: _brown, letterSpacing: 3),
        ),
      ],
    );
  }

  Widget _buildOrderBadge() {
    return Row(
      children: [
        Expanded(child: Container(height: 2, color: _cream)),
        const SizedBox(width: 8),
        Text('${data.orderType.label}: #${data.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: _brown, letterSpacing: 1)),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 2, color: _cream)),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: _brown, letterSpacing: 0.5)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: _dark, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildClientRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _cream, width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('CLIENT:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: _brown, letterSpacing: 0.5)),
          Expanded(child: Text(data.clientName.toUpperCase(), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: _dark))),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: itemsMaxHeight),
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: data.items.length,
          itemBuilder: (_, i) => _buildItemRow(data.items[i]),
        ),
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(item.displayName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _dark)),
          ),
          const SizedBox(width: 8),
          Text(_peso(item.total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: _green)),
        ],
      ),
    );
  }

  Widget _buildTotalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _creamBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildTotalLine('MATERIAL COST', data.materialCost),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0x33A98258)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('GRAND TOTAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: _dark)),
              Text(_peso(data.grandTotal), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: _green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalLine(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: _brown)),
        Text(_peso(amount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: _brown)),
      ],
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      width: double.infinity, height: 45,
      decoration: BoxDecoration(color: _brown, borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: Text('PAYMENT METHOD: ${data.paymentMethod.label}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: _white, letterSpacing: 1)),
    );
  }

  Widget _buildThankYouText() {
    return const Center(
      child: Text(
        'THANK YOU FOR CHOOSING L&L CAFE. ALL MATERIALS ARE\nETHICALLY SOURCED AND ENGINEERED FOR FLAVOR PERFECTION',
        textAlign: TextAlign.center,
        style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w700, fontSize: 9, color: _brown, letterSpacing: 1.2, height: 1.5),
      ),
    );
  }

  Widget _buildPrintButton() {
    return GestureDetector(
      onTap: onPrint,
      child: Container(
        width: double.infinity, height: 55,
        decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: const Text('PRINT ORDER LOG & FINISH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: _white, letterSpacing: 1.2)),
      ),
    );
  }
}