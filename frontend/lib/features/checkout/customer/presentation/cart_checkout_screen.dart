import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/constants/cart_item.dart';
import 'package:frontend/core/services/customer/order_service.dart';
import 'package:frontend/core/models/order_request.dart';

const double _kMobile = 768;
const Color _primary = Color(0xFF758C6D);

//--------------------------------------------bambooBackground------------------------------------------------
class _BambooBackground extends StatefulWidget {
  const _BambooBackground();
  @override
  State<_BambooBackground> createState() => _BambooBackgroundState();
}

class _BambooBackgroundState extends State<_BambooBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < _kMobile;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _BambooPainter(
            animationValue: _controller.value,
            isMobile: isMobile,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BambooPainter extends CustomPainter {
  final double animationValue;
  final bool isMobile;

  _BambooPainter({required this.animationValue, required this.isMobile});

  static const _bamboos = [
    [0.040, 13.0, 0.12, 1.53],
    [0.095, 7.0, 0.10, -1.84],
    [0.133, 14.0, 0.13, 1.45],
    [0.190, 9.0, 0.10, -0.72],
    [0.236, 9.5, 0.10, -0.71],
    [0.283, 13.0, 0.12, -1.53],
    [0.321, 13.0, 0.11, 1.24],
    [0.374, 1.9, 0.08, 0.29],
    [0.423, 2.2, 0.08, 0.35],
    [0.469, 2.6, 0.08, -0.34],
    [0.503, 20.0, 0.13, 2.00],
    [0.560, 4.1, 0.09, 1.06],
    [0.598, 17.6, 0.12, 1.82],
    [0.656, 8.9, 0.10, -0.98],
    [0.693, 15.5, 0.11, 1.72],
    [0.739, 17.9, 0.12, 1.99],
    [0.783, 18.8, 0.12, 1.81],
    [0.839, 8.9, 0.10, 0.66],
    [0.890, 5.2, 0.08, -1.98],
    [0.936, 16.6, 0.11, -1.89],
  ];

  void _drawLeaf(
    Canvas canvas,
    Offset offset,
    double angle,
    double length,
    double width,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle);

    final path =
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(length * 0.4, -width, length, 0)
          ..quadraticBezierTo(length * 0.6, width, 0, 0)
          ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _primary;
    int index = 0;
    for (final b in _bamboos) {
      index++;
      if (isMobile && index % 3 != 0) continue;
      final baseX = size.width * (b[0] as double);
      final w = b[1] as double;
      final deg = b[3] as double;
      final h = size.height;
      final double baseOp = b[2] as double;
      final op = isMobile ? baseOp * 0.4 : baseOp;
      final movementX = animationValue * size.width * (op * 8);
      final x = (baseX + movementX) % size.width;
      final sway =
          math.sin((animationValue * math.pi * 4) + (x * 0.01)) * 0.015;
      final rad = (deg * math.pi / 180) + sway;

      paint.color = _primary.withOpacity(op);

      canvas.save();
      canvas.translate(x + w / 2, h / 2);
      canvas.rotate(rad);

      canvas.drawRect(Rect.fromLTWH(-w / 2, -h / 2 - 20, w, h + 40), paint);
      int segments = (h / (w * 10 + 60)).ceil().clamp(3, 10);
      double segmentHeight = (h + 40) / segments;

      for (int i = 1; i < segments; i++) {
        double jointY = (-h / 2 - 20) + (i * segmentHeight);
        canvas.drawRect(
          Rect.fromLTWH(-w / 2 - 1.5, jointY - 1, w + 3, 2.5),
          paint,
        );
        if ((index + i) % 4 != 0) {
          bool isLeft = (index + i) % 2 == 0;
          double leafLength = w * 2.5 + 20.0;
          double leafWidth = leafLength * 0.25;

          double angle = isLeft ? math.pi * 0.8 : math.pi * 0.2;

          _drawLeaf(
            canvas,
            Offset(isLeft ? -w / 2 : w / 2, jointY),
            angle,
            leafLength,
            leafWidth,
            paint,
          );
          if (i % 2 == 0) {
            double secondaryAngle = isLeft ? math.pi * 1.1 : -math.pi * 0.1;
            _drawLeaf(
              canvas,
              Offset(isLeft ? -w / 2 : w / 2, jointY),
              secondaryAngle,
              leafLength * 0.8,
              leafWidth * 0.8,
              paint,
            );
          }
        }
      }

      canvas.translate(0, h * 0.2);
      canvas.rotate(math.pi / 4);
      canvas.drawRect(
        Rect.fromLTWH(-w * 0.6, -w * 0.6, w * 1.2, w * 1.2),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BambooPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isMobile != isMobile;
  }
}

//--------------------------CartCheckoutScreenState------------------------------------------------

class CartCheckoutScreen extends StatefulWidget {
  final List<CartItem> items;
  

  const CartCheckoutScreen({super.key, required this.items});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  //--------------------------ScrollController-----------------------------------
  final ScrollController _scrollController = ScrollController();
  List<CartItem> _items = [];
  final OrderService _orderService = OrderService();
  bool _isLoading = false;

  bool _isDelivery = true;
  bool _isCash = true;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
  }

  Future<void> _createOrder() async {
    setState(() => _isLoading = true);

    const double deliveryFee = 45.0;

    final subtotal = _items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    final total = _isDelivery
        ? subtotal + deliveryFee
        : subtotal;

    final order = OrderRequest(
      source: "online",
      orderType: _isDelivery ? "delivery" : "pickup",
      subtotal: subtotal,
      deliveryFee: _isDelivery ? deliveryFee : 0,
      total: total,
      paymentMethod: _isCash ? "cash" : "e-wallet",
      paymentStatus: "unpaid",
      customerName: null,
      customerPhone: null,
      notes: "this is a note for delivery",
      items: _items.map((item) {
        return {
          "menu_item_id": item.id,
          "name": item.name,
          "quantity": item.quantity ?? 1,
          "unit_price": item.price,
          "subtotal": item.price * item.quantity
        };
      }).toList(),
    );

    final success = await _orderService.createOrder(order);

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/success');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to place order")),
      );
    }
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < _kMobile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _BambooBackground()),
          Column(
            children: [
              CustomerNavbar(
                activeRoute: '/cart',
                cartCount: 3,
                notifCount: 1,
                onCart: () {},
                onNotif: () {},
                onProfile: () => Navigator.pushNamed(context, '/profile'),
                onLogout: () {},
              ),
              const SizedBox(height: 15),
              _finalizeHeader(isMobile: isMobile),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.fromLTRB(45, 0, 30, 0),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (isMobile) ...[
                        const SizedBox(height: 15),
                        _orderMethod(isMobile: isMobile),
                        const SizedBox(height: 15),
                        _deliveryPickup(isMobile: isMobile),
                        const SizedBox(height: 15),
                        _clientDetails(isMobile: isMobile),
                        const SizedBox(height: 20),
                        _fieldNotes(isMobile: isMobile),
                        const SizedBox(height: 25),
                        _paymentMethod(isMobile: isMobile),
                        const SizedBox(height: 10),
                        _paymentChoices(isMobile: isMobile),
                        const SizedBox(height: 10),
                        _cartCheckoutSummary(isMobile: true),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 15),
                                  _orderMethod(),
                                  const SizedBox(height: 15),
                                  _deliveryPickup(),
                                  const SizedBox(height: 15),
                                  _clientDetails(),
                                  const SizedBox(height: 25),
                                  _paymentMethod(),
                                  const SizedBox(height: 10),
                                  _paymentChoices(),
                                  const SizedBox(height: 20),
                                  _fieldNotes(),
                                ],
                              ),
                            ),
                            Expanded(flex: 1, child: _cartCheckoutSummary()),
                          ],
                        ),
                      ],
                      const CustomerFooter(),
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

  Widget _finalizeHeader({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 45,
        15,
        isMobile ? 16 : 30,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              child: Icon(
                Icons.chevron_left,
                color: AppColors.primary,
                size: 30,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              children: const [
                TextSpan(
                  text: 'FINALIZE ',
                  style: TextStyle(color: AppColors.receiptDark),
                ),
                TextSpan(
                  text: 'ORDER',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderMethod({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 60,
        15,
        isMobile ? 16 : 60,
        5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.access_time, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Text(
            'ORDER METHOD',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryPickup({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 60,
        0,
        isMobile ? 16 : 60,
        5,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isDelivery = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 58,
                decoration: BoxDecoration(
                  color: _isDelivery ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'DELIVERY',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                    color: _isDelivery ? AppColors.white : AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isDelivery = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 58,
                decoration: BoxDecoration(
                  color: !_isDelivery ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'SITE PICKUP',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                    color: !_isDelivery ? AppColors.white : AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clientDetails({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 60,
        0,
        isMobile ? 16 : 60,
        5,
      ),
      child:
          _isDelivery
              ? _deliveryDetails(isMobile: isMobile)
              : _pickupDetails(isMobile: isMobile),
    );
  }

  Widget _deliveryDetails({bool isMobile = false}) {
    // helper to avoid repeating the field decoration
    Widget _field({
      required String label,
      required String hint,
      required IconData icon,
      TextInputType? keyboard,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.09),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(13),
              ),
              child: TextField(
                keyboardType: keyboard,
                style: TextStyle(fontSize: 14, color: AppColors.primary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    icon,
                    size: 17,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final nameField = _field(
      label: 'FULL NAME',
      hint: 'ENTER NAME...',
      icon: Icons.person_2_outlined,
    );
    final contactField = _field(
      label: 'CONTACT NUMBER',
      hint: '09XX XXX XXXX',
      icon: Icons.call_outlined,
      keyboard: TextInputType.phone,
    );

    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_2_outlined,
                color: AppColors.secondary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'CLIENT SPECIFICATIONS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.receiptDark,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          //stacks vertically on mobile, side-by-side on desktop
          if (isMobile) ...[
            nameField,
            const SizedBox(height: 16),
            contactField,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: nameField),
                const SizedBox(width: 20),
                Expanded(child: contactField),
              ],
            ),

          const SizedBox(height: 20),
          // address field, also fix width
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DELIVERY ADDRESS',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.09),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: TextField(
                    style: TextStyle(fontSize: 14, color: AppColors.primary),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'ENTER FULL ADDRESS...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.location_pin,
                        size: 17,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pickupDetails({bool isMobile = false}) {
    // helper to avoid repeating the field decoration
    Widget _field({
      required String label,
      required String hint,
      required IconData icon,
      TextInputType? keyboard,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            //width: double.infinity,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.09),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(13),
              ),
              child: TextField(
                keyboardType: keyboard,
                style: TextStyle(fontSize: 14, color: AppColors.primary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    icon,
                    size: 17,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final nameField = _field(
      label: 'FULL NAME',
      hint: 'ENTER NAME...',
      icon: Icons.person_2_outlined,
    );
    final contactField = _field(
      label: 'CONTACT NUMBER',
      hint: '09XX XXX XXXX',
      icon: Icons.call_outlined,
      keyboard: TextInputType.phone,
    );

    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_2_outlined,
                color: AppColors.secondary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'CLIENT SPECIFICATIONS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.receiptDark,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          //stacks vertically on mobile, side-by-side on desktop
          if (isMobile) ...[
            SizedBox(width: double.infinity, child: nameField),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: contactField),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: nameField),
                const SizedBox(width: 20),
                Expanded(child: contactField),
              ],
            ),

          const SizedBox(height: 20),
          // address field, also fix width
        ],
      ),
    );
  }

  Widget _paymentMethod({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 60,
        15,
        isMobile ? 16 : 60,
        5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_rounded, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Text(
            'PAYMENT METHOD',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentChoices({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 60,
        0,
        isMobile ? 16 : 60,
        5,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCash = true),
              child: AnimatedContainer(
                padding: const EdgeInsets.only(top: 14),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 58,
                decoration: BoxDecoration(
                  color: _isCash ? AppColors.secondary : AppColors.white,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.money,
                      color: _isCash ? AppColors.white : AppColors.primary,
                      size: 15,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'CASH ON DELIVERY',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                        color: _isCash ? AppColors.white : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCash = false),
              child: AnimatedContainer(
                padding: const EdgeInsets.only(top: 14),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 58,
                decoration: BoxDecoration(
                  color: !_isCash ? AppColors.secondary : AppColors.white,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_iphone,
                      color: _isCash ? AppColors.primary : AppColors.white,
                      size: 15,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'ONLINE PAYMENT',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                        color: _isCash ? AppColors.primary : AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldNotes({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 60,
        15,
        isMobile ? 16 : 60,
        5,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.message_sharp, size: 20, color: AppColors.secondary),
              const SizedBox(width: 12),
              Text(
                'FIELD NOTES',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 90,
            child: TextField(
              minLines: 4,
              maxLines: 4,
              style: TextStyle(fontSize: 12, color: AppColors.primary),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'ADD SPECIAL INSTRUCTIONS...',
                hintStyle: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: AppColors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartCheckoutSummary({bool isMobile = false}) {
    const double deliveryFee = 45.0;
    final double subTotal = _items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    //if pickup fee is 0
    final double appliedDeliveryFee = _isDelivery ? deliveryFee : 0.0;

    final double orderTotal = _isDelivery ? subTotal + deliveryFee : subTotal;

    return Container(
      padding: const EdgeInsets.all(25),
      margin:
          isMobile
              ? const EdgeInsets.fromLTRB(16, 8, 16, 20) // full-width on mobile
              : const EdgeInsets.fromLTRB(1, 20, 30, 20), // original desktop
      decoration: BoxDecoration(
        color: AppColors.receiptDark,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.receiptDark.withOpacity(.3),
            offset: const Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    CupertinoIcons.checkmark_shield,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'ORDER LOG',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            //the pulled ordered item should be displayed here
            ..._items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name.toUpperCase(),
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'X${item.quantity} UNITS',
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.7),
                              fontSize: 9,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₱${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_items.isEmpty)
              Text("NO ITEMS PASSED", style: TextStyle(color: Colors.white)),

            const SizedBox(height: 16),
            Divider(thickness: 1, color: AppColors.white.withOpacity(0.1)),
            const SizedBox(height: 10),

            Row(
              children: [
                Text(
                  'SUBTOTAL',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.55),
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),

                const Spacer(),

                Text(
                  '₱${subTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Text(
                  _isDelivery ? 'DELIVERY FEE' : ' ',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.55),
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),

                const Spacer(),

                Text(
                  _isDelivery
                      ? '₱${appliedDeliveryFee.toStringAsFixed(2)}'
                      : ' ',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'TOTAL COST',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),

                Text(
                  '₱${orderTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 29),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: AppColors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_android,
                    size: 18,
                    color: AppColors.white.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _isCash
                          ? 'PAYMENT METHOD: CASH ON DELIVERY'
                          : 'PAYMENT METHOD: ONLINE PAYMENT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 19),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                
                onPressed: _isLoading ? null : _createOrder,
                
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'CONFIRM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
