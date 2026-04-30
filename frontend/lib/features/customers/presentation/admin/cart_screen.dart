import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/constants/cart_item.dart';
import 'package:frontend/features/checkout/customer/presentation/cart_checkout_screen.dart';

const double _kMobile = 768;
const double _kDesktopMaxWidth = 1280;
const Color _primary = Color(0xFF758C6D);

//--------------------------BambooBackground-----------------------------------

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

//--------------------------CartScreen-----------------------------------

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  //--------------------------ScrollController-----------------------------------
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  //-------------------------------------Build-----------------------------------

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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (isMobile) ...[
                        // MOBILE: stack vertically
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _selectionHeader(isMobile: true),
                            const SizedBox(height: 15),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _returnButton(),
                            ),
                            const SizedBox(height: 8),
                            _cartItems(),
                            const SizedBox(height: 8),
                            _cartSummary(isMobile: true),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ] else ...[
                        // DESKTOP: side-by-side
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _selectionHeader(),
                                  const SizedBox(height: 15),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                    ),
                                    child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.primary.withOpacity(0.3),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  _cartItems(),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: _returnButton(),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            Expanded(flex: 1, child: _cartSummary()),
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

  //--------------------------SelectionHeader-----------------------------------
  Widget _selectionHeader({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 45,
        15,
        isMobile ? 16 : 30,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              children: const [
                TextSpan(
                  text: 'YOUR ',
                  style: TextStyle(color: AppColors.receiptDark),
                ),
                TextSpan(
                  text: 'SELECTION',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ],
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TAX',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${orders.expand((o) => o.items).length} UNITS',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //-----------------------------cartItemData-----------------------------------
  final List<Order> orders = [
    Order(
      id: 'LL-001',
      status: OrderStatus.pending,
      items: [
        CartItem(
          name: 'Caramel Biscoff',
          category: 'Waffles',
          price: 120.0,
          originalPrice: 130.0,
        ),
        CartItem(
          name: 'Hot Honey Sandwich',
          category: 'Foods',
          price: 115.0,
          originalPrice: 110.0,
        ),
        CartItem(
          name: 'Chicken Sandwich',
          category: 'Foods',
          price: 95.0,
          originalPrice: 95.0,
        ),
      ],
    ),
  ];

  // flat list of CartItems from all orders
  List<CartItem> get _cartItems2 => orders.expand((o) => o.items).toList();

  //--------------------------CartItems-----------------------------------

  Widget _cartItems() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      itemCount: _cartItems2.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _cartItems2[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.receiptDark.withOpacity(.3),

                offset: Offset(0, 4),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              //placeholder for item image, replace with actual image later
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: AppColors.receiptDark,
                      ),
                    ),
                    const SizedBox(height: 1),

                    Text(
                      item.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.secondary.withOpacity(0.9),
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.09),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _qtyButton(Icons.remove, () {
                            setState(() {
                              if (item.quantity > 1) item.quantity--;
                            });
                          }),
                          SizedBox(
                            width: 28,
                            child: Text(
                              '${item.quantity}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _qtyButton(Icons.add, () {
                            setState(() => item.quantity++);
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap:
                        () => setState(() {
                          for (final order in orders) {
                            if (order.items.remove(item)) break;
                          }
                        }),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFD95555,
                        ).withOpacity(0.1), // light red bg
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFFD95555),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'VALUE: ₱${item.originalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary.withOpacity(0.5),
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    '₱${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        child: Icon(icon, size: 14, color: AppColors.primary),
      ),
    );
  }

  //--------------------------ReturnButton-----------------------------------
  Widget _returnButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chevron_left, size: 22, color: AppColors.primary),
            Text(
              'RETURN TO LNL CAFE MENU',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //--------------------------CartSummary-----------------------------------
  Widget _cartSummary({bool isMobile = false}) {
    //const double deliveryFee = 45.0;
    final items = orders.expand((o) => o.items).toList();
    final double subtotal = items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final double orderTotal = subtotal;

    return Container(
      padding: const EdgeInsets.all(25),
      margin:
          isMobile
              ? const EdgeInsets.fromLTRB(16, 8, 16, 20) // full-width on mobile
              : const EdgeInsets.fromLTRB(20, 20, 30, 20), // original desktop
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
      // ... rest of the method stays exactly the same
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
                    Icons.shopping_bag_outlined,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'ORDER SUMMARY',
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

            ..._cartItems2.map(
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
                            'X${orders.expand((o) => o.items).fold(0, (sum, i) => sum + i.quantity)} UNITS',
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
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ), //------------------------------------------------------------------------

            Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
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
                const Spacer(), //-----------------------------------------------------------------

                Text(
                  '₱${subtotal.toStringAsFixed(2)}',
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
                  'ORDER TOTAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(), //-----------------------------------------------------------------

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
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CartCheckoutScreen(
                              items: orders.expand((o) => o.items).toList(),
                            ),
                      ),
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'PROCEED TO CHECKOUT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 13),

            Center(
              child: Text(
                'PRICES ARE INCLUSIVE OF TAXES AND ENVIRONMENTAL FEES.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 8,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
