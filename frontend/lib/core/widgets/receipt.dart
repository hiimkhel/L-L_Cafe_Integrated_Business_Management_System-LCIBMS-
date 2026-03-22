import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────

class OrderItem {
  final String name;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => unitPrice * quantity;
  String get displayName => '${name.toUpperCase()} X$quantity';
}

enum OrderType { walkIn, dineIn, takeOut }

extension OrderTypeLabel on OrderType {
  String get label {
    switch (this) {
      case OrderType.walkIn:
        return 'WALK-IN';
      case OrderType.dineIn:
        return 'DINE-IN';
      case OrderType.takeOut:
        return 'TAKE-OUT';
    }
  }
}

enum PaymentMethod { cash, card, gcash, maya }

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'CASH';
      case PaymentMethod.card:
        return 'CARD';
      case PaymentMethod.gcash:
        return 'GCASH';
      case PaymentMethod.maya:
        return 'MAYA';
    }
  }
}

class ReceiptData {
  final String orderNumber;
  final String clientName;
  final DateTime dateTime;
  final OrderType orderType;
  final List<OrderItem> items;
  final double taxRate;
  final PaymentMethod paymentMethod;

  const ReceiptData({
    required this.orderNumber,
    required this.clientName,
    required this.dateTime,
    required this.orderType,
    required this.items,
    this.taxRate = 0.12,
    required this.paymentMethod,
  });

  double get materialCost => items.fold(0, (sum, i) => sum + i.total);
  double get engineeringTax => materialCost * taxRate;
  double get grandTotal => materialCost + engineeringTax;

  String get formattedDate {
    final d = dateTime;
    return '${d.year}-${_p(d.month)}-${_p(d.day)} ${_p(d.hour)}:${_p(d.minute)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}

// ─────────────────────────────────────────────
// RECEIPT WIDGET
// ─────────────────────────────────────────────

class LLCafeReceipt extends StatelessWidget {
  final ReceiptData data;
  final VoidCallback? onPrint;

  /// Max height for the scrollable items list.
  /// Defaults to 200. Increase if you want more items visible before scrolling.
  final double itemsMaxHeight;

  const LLCafeReceipt({
    super.key,
    required this.data,
    this.onPrint,
    this.itemsMaxHeight = 200,
  });

  // ── Design tokens ────────────────────────────
  static const Color _brown   = AppColors.primary;
  static const Color _dark    = AppColors.receiptDark;
  static const Color _green   = AppColors.secondary;
  static const Color _cream   = AppColors.background;
  static const Color _white   = AppColors.textLight;
  static const Color _creamBg = AppColors.receiptBg; 

  String _peso(double v) => '₱${v.toStringAsFixed(2)}';

  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final cardWidth   = screenWidth < 500 ? screenWidth : 450.0;
        final hPad        = (cardWidth * 0.107).clamp(24.0, 48.0);
        final radius      = cardWidth * 0.12;

        return Center(
          child: Container(
            width: cardWidth,
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 80,
                  offset: Offset(0, 40),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Top accent bar ──────────────
                  Container(height: 16, color: _green),

                  // ── Body ────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 40),
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
                        const SizedBox(height: 32),
                        _buildPaymentButton(),
                        const SizedBox(height: 14),
                        _buildThankYouText(),
                        const SizedBox(height: 14),
                        _buildPrintButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo — reads from assets/images/lnl.jpg
        Center(
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 15,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/lnl.jpg',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                // Fallback shown if asset path is missing
                errorBuilder: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: _cream,
                  alignment: Alignment.center,
                  child: const Text(
                    'L&L',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: _brown,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'L&L CAFE',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 28,
              color: _dark,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text(
            'MAKING GOOD FOOD FOR PEOPLE\'S HAPPINESS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 9,
              color: _brown,
              letterSpacing: 4,
            ),
          ),
        ),
      ],
    );
  }

  // ── Order badge ───────────────────────────────
  Widget _buildOrderBadge() {
    return Row(
      children: [
        Expanded(child: Container(height: 2, color: _cream)),
        const SizedBox(width: 8),
        Text(
          '${data.orderType.label}: # LL-${data.orderNumber}',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 10,
            color: _brown,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 2, color: _cream)),
      ],
    );
  }

  // ── Generic label/value row ───────────────────
  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                color: _brown,
                letterSpacing: 0.5)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                color: _dark,
                letterSpacing: 0.5)),
      ],
    );
  }

  // ── Client row ────────────────────────────────
  Widget _buildClientRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _cream, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('CLIENT PROTOCOL:',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: _brown,
                  letterSpacing: 0.5)),
          Text(data.clientName.toUpperCase(),
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: _dark,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  // ── Scrollable items list ─────────────────────
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
            child: Text(item.displayName,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _dark)),
          ),
          const SizedBox(width: 8),
          Text(_peso(item.total),
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _green)),
        ],
      ),
    );
  }

  // ── Totals card ───────────────────────────────
  Widget _buildTotalsCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: _creamBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildTotalLine('MATERIAL COST', data.materialCost),
          const SizedBox(height: 10),
          _buildTotalLine(
            'TAX (${(data.taxRate * 100).toStringAsFixed(0)}%)',
            data.engineeringTax,
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0x33A98258)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('GRAND TOTAL',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: _dark)),
              ),
              Text(_peso(data.grandTotal),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: _green)),
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
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: _brown,
                  letterSpacing: 0.5)),
        ),
        const SizedBox(width: 8),
        Text(_peso(amount),
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: _brown)),
      ],
    );
  }

  // ── Payment button ────────────────────────────
  Widget _buildPaymentButton() {
    return Container(
      width: double.infinity,
      height: 47,
      decoration: BoxDecoration(
        color: _brown,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x33758C6D),
              blurRadius: 15,
              offset: Offset(0, 10))
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'PAYMENT METHOD: ${data.paymentMethod.label}',
        style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 10,
            color: _white,
            letterSpacing: 1),
      ),
    );
  }

  // ── Thank-you text ────────────────────────────
  Widget _buildThankYouText() {
    return const Center(
      child: Text(
        'THANK YOU FOR CHOOSING L&L CAFE. ALL MATERIALS ARE\n'
        'ETHICALLY SOURCED AND ENGINEERED FOR STRUCTURAL FLAVOR PERFECTION',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
            fontSize: 9,
            color: _brown,
            letterSpacing: 1.8,
            height: 1.7),
      ),
    );
  }

  // ── Print button ──────────────────────────────
  Widget _buildPrintButton() {
    return GestureDetector(
      onTap: onPrint,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(color: _dark, offset: Offset(4, 4), blurRadius: 0)
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'PRINT ORDER LOG',
          style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: _white,
              letterSpacing: 1.4),
        ),
      ),
    );
  }
}