import 'package:flutter/material.dart';
import 'package:frontend/core/models/dashboard_models.dart';
import './card_header.dart';

const Color _green1 = Color(0xFF3D5A45);
const Color _green2 = Color(0xFF758C6D);
const Color _gold = Color(0xFFA98258);
const Color _beige = Color(0xFFEFE2C9);
const Color _white = Colors.white;
const Color _dark   = Color(0xFF2D2A26);


class OrdersCard extends StatelessWidget {
  final List<DashboardOrderRow> orders;
  final VoidCallback onViewAll;
  const OrdersCard({required this.orders, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final top5 = orders.take(5).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _beige,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _green2.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
              color: _green1.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const CardHeader(title: 'RECENT ORDERS'),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _green2.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('TOP 5',
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: _green2)),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onViewAll,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_green2, _green1]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: _green2.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('VIEW ALL',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 0.5,
                            color: _white)),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_forward_rounded,
                        color: _white, size: 13),
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _green2.withOpacity(0.1)),
            ),
            child: Column(children: [
              const _OrderTableHeader(),
              ...top5.asMap().entries.map((e) => _OrderTableRow(
                    order: e.value,
                    isShaded: e.key.isEven,
                    isLast: e.key == top5.length - 1,
                  )),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Table header ──────────────────────────────────────────────────────────────

class _OrderTableHeader extends StatelessWidget {
  const _OrderTableHeader();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.7,
        color: _green1.withOpacity(0.55));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _beige.withOpacity(0.7),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(14)),
        border:
            Border(bottom: BorderSide(color: _green2.withOpacity(0.1))),
      ),
      child: Row(children: [
        Expanded(flex: 14, child: Text('ORDER ID',  style: style)),
        Expanded(flex: 20, child: Text('CUSTOMER',  style: style)),
        Expanded(flex: 13, child: Text('PAYMENT',   style: style)),
        Expanded(flex: 16, child: Text('STATUS',    style: style)),
        Expanded(flex: 22, child: Text('TIME',      style: style)),
        Expanded(flex: 15, child: Text('AMOUNT',    style: style)),
      ]),
    );
  }
}

// ── Table row ─────────────────────────────────────────────────────────────────

class _OrderTableRow extends StatelessWidget {
  final DashboardOrderRow order;
  final bool isShaded, isLast;
  const _OrderTableRow({
    required this.order,
    this.isShaded = false,
    this.isLast = false,
  });

  Color get _statusColor {
    switch (order.status.toLowerCase()) {
      case 'done':      return const Color(0xFF2E7D32);
      case 'pending':   return const Color(0xFFE65100);
      case 'preparing': return const Color(0xFF1565C0);
      case 'delivery':  return const Color(0xFF6A1B9A);
      case 'cancelled': return const Color(0xFFC62828);
      default:          return _green2;
    }
  }

  Color get _statusBg {
    switch (order.status.toLowerCase()) {
      case 'done':      return const Color(0xFFE8F5E9);
      case 'pending':   return const Color(0xFFFFF3E0);
      case 'preparing': return const Color(0xFFE3F2FD);
      case 'delivery':  return const Color(0xFFF3E5F5);
      case 'cancelled': return const Color(0xFFFFEBEE);
      default:          return _beige;
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 11,
        color: _green1.withOpacity(0.8));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isShaded ? _beige.withOpacity(0.35) : _white,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(14))
            : BorderRadius.zero,
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: _green2.withOpacity(0.07))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 14,
              child: Text(order.orderId,
                  style: base.copyWith(
                      fontWeight: FontWeight.w800, color: _gold))),
          Expanded(
              flex: 20,
              child: Text(order.customerName,
                  style: base.copyWith(
                      fontWeight: FontWeight.w700, color: _dark))),
          Expanded(
              flex: 13,
              child: Row(children: [
                Icon(
                  order.payment.toLowerCase() == 'paid'
                      ? Icons.check_circle_outline_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 13,
                  color: order.payment.toLowerCase() == 'paid'
                      ? const Color(0xFF4CAF50)
                      : Colors.redAccent,
                ),
                const SizedBox(width: 4),
                Text(order.payment, style: base),
              ])),
          Expanded(
            flex: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status,
                  style: base.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _statusColor,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              flex: 22,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(order.orderTime, style: base),
              )),
          Expanded(
              flex: 15,
              child: Text(order.amount,
                  style: base.copyWith(
                      fontWeight: FontWeight.w900, color: _dark))),
        ],
      ),
    );
  }
}

