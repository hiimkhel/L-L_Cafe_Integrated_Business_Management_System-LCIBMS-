import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/constants/cart_provider.dart';
import 'package:frontend/features/checkout/customer/presentation/cart_checkout_screen.dart';
import 'package:frontend/core/constants/cart_item.dart' as legacy;

const double _kMobile = 768;
const double _kDesktopMaxWidth = 1280;
const Color _primary = Color(0xFF758C6D);

// ─────────────────────────────────────────────────────────────────────────────
// BAMBOO BACKGROUND (retained)
// ─────────────────────────────────────────────────────────────────────────────

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
        vsync: this, duration: const Duration(seconds: 30))
      ..repeat();
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
      builder: (_, __) => CustomPaint(
        painter: _BambooPainter(
            animationValue: _controller.value, isMobile: isMobile),
        size: Size.infinite,
      ),
    );
  }
}

class _BambooPainter extends CustomPainter {
  final double animationValue;
  final bool isMobile;

  _BambooPainter({required this.animationValue, required this.isMobile});

  static const _bamboos = [
    [0.040, 13.0, 0.12, 1.53], [0.095, 7.0, 0.10, -1.84],
    [0.133, 14.0, 0.13, 1.45], [0.190, 9.0, 0.10, -0.72],
    [0.236, 9.5, 0.10, -0.71], [0.283, 13.0, 0.12, -1.53],
    [0.321, 13.0, 0.11, 1.24], [0.374, 1.9, 0.08, 0.29],
    [0.423, 2.2, 0.08, 0.35], [0.469, 2.6, 0.08, -0.34],
    [0.503, 20.0, 0.13, 2.00], [0.560, 4.1, 0.09, 1.06],
    [0.598, 17.6, 0.12, 1.82], [0.656, 8.9, 0.10, -0.98],
    [0.693, 15.5, 0.11, 1.72], [0.739, 17.9, 0.12, 1.99],
    [0.783, 18.8, 0.12, 1.81], [0.839, 8.9, 0.10, 0.66],
    [0.890, 5.2, 0.08, -1.98], [0.936, 16.6, 0.11, -1.89],
  ];

  void _drawLeaf(Canvas c, Offset o, double angle, double len, double w,
      Paint p) {
    c.save(); c.translate(o.dx, o.dy); c.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.4, -w, len, 0)
      ..quadraticBezierTo(len * 0.6, w, 0, 0)
      ..close();
    c.drawPath(path, p); c.restore();
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
      final x =
          ((baseX + animationValue * size.width * (op * 8)) % size.width);
      final sway =
          math.sin((animationValue * math.pi * 4) + (x * 0.01)) * 0.015;
      final rad = (deg * math.pi / 180) + sway;
      paint.color = _primary.withOpacity(op);
      canvas.save();
      canvas.translate(x + w / 2, h / 2);
      canvas.rotate(rad);
      canvas.drawRect(Rect.fromLTWH(-w / 2, -h / 2 - 20, w, h + 40), paint);
      int segments = (h / (w * 10 + 60)).ceil().clamp(3, 10);
      double segH = (h + 40) / segments;
      for (int i = 1; i < segments; i++) {
        double jY = (-h / 2 - 20) + (i * segH);
        canvas.drawRect(
            Rect.fromLTWH(-w / 2 - 1.5, jY - 1, w + 3, 2.5), paint);
        if ((index + i) % 4 != 0) {
          bool isLeft = (index + i) % 2 == 0;
          double ll = w * 2.5 + 20.0, lw = ll * 0.25;
          _drawLeaf(canvas, Offset(isLeft ? -w / 2 : w / 2, jY),
              isLeft ? math.pi * 0.8 : math.pi * 0.2, ll, lw, paint);
          if (i % 2 == 0) {
            _drawLeaf(canvas, Offset(isLeft ? -w / 2 : w / 2, jY),
                isLeft ? math.pi * 1.1 : -math.pi * 0.1, ll * 0.8, lw * 0.8,
                paint);
          }
        }
      }
      canvas.translate(0, h * 0.2);
      canvas.rotate(math.pi / 4);
      canvas.drawRect(
          Rect.fromLTWH(-w * 0.6, -w * 0.6, w * 1.2, w * 1.2), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BambooPainter old) =>
      old.animationValue != animationValue || old.isMobile != isMobile;
}

// ─────────────────────────────────────────────────────────────────────────────
// CART SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Subscribe to CartProvider — rebuilds automatically on any cart change
    final cart = CartProvider.of(context);
    final isMobile = MediaQuery.of(context).size.width < _kMobile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _BambooBackground()),
          Column(
            children: [
              // Navbar — cart badge live-updates from CartProvider
              CustomerNavbar(
                activeRoute: '/cart',
                cartCount: cart.totalCount,
                notifCount: 1,
                onCart: () {},
                onNotif: () {},
                onProfile: () =>
                    Navigator.pushReplacementNamed(context, '/profile'),
                onLogout: () =>
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (r) => false),
              ),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // ── Content ───────────────────────────────
                            if (cart.isEmpty)
                              _EmptyCart(isMobile: isMobile)
                            else if (isMobile)
                              _MobileLayout(cart: cart)
                            else
                              _DesktopLayout(cart: cart),

                            // ── Footer always at bottom ────────────────
                            const CustomerFooter(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  final bool isMobile;
  const _EmptyCart({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 64, vertical: 80),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_cart_outlined,
                  size: 48, color: AppColors.primary.withOpacity(0.4)),
            ),
            const SizedBox(height: 28),
            Text(
              'YOUR CART IS EMPTY',
              style: TextStyle(
                fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 22, letterSpacing: -0.5,
                color: AppColors.receiptDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add items from the menu to get started.',
              style: TextStyle(
                fontFamily: 'Urbanist', fontWeight: FontWeight.w500,
                fontSize: 14, color: AppColors.receiptDark.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 36),
            GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/menu'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 36, vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.receiptDark, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xFF2D2A26),
                        blurRadius: 0,
                        offset: Offset(4, 4))
                  ],
                ),
                child: const Text(
                  'BROWSE THE MENU',
                  style: TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 13, letterSpacing: 2.0, color: Colors.white,
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

// ─────────────────────────────────────────────────────────────────────────────
// DESKTOP LAYOUT
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  final CartNotifier cart;
  const _DesktopLayout({required this.cart});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _kDesktopMaxWidth),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SelectionHeader(cart: cart, isMobile: false),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.primary.withOpacity(0.3)),
                ),
                const SizedBox(height: 15),
                _CartItemList(cart: cart),
                const SizedBox(height: 8),
                _ReturnButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: _CartSummary(cart: cart, isMobile: false),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE LAYOUT
// ─────────────────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final CartNotifier cart;
  const _MobileLayout({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SelectionHeader(cart: cart, isMobile: true),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.primary.withOpacity(0.3)),
        ),
        const SizedBox(height: 10),
        _ReturnButton(),
        const SizedBox(height: 8),
        _CartItemList(cart: cart),
        const SizedBox(height: 8),
        _CartSummary(cart: cart, isMobile: true),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SELECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _SelectionHeader extends StatelessWidget {
  final CartNotifier cart;
  final bool isMobile;
  const _SelectionHeader({required this.cart, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          isMobile ? 16 : 45, 15, isMobile ? 16 : 30, 0),
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
              const Text(
                'TAX',
                style: TextStyle(
                  color: AppColors.secondary, fontSize: 11,
                  letterSpacing: 0.6, fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${cart.totalCount} UNITS',
                  style: const TextStyle(
                    color: AppColors.primary, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CART ITEM LIST
// ─────────────────────────────────────────────────────────────────────────────

class _CartItemList extends StatelessWidget {
  final CartNotifier cart;
  const _CartItemList({required this.cart});

  @override
  Widget build(BuildContext context) {
    final items = cart.items;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.receiptDark.withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Item image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        width: 72, height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
              const SizedBox(width: 14),

              // Name, category, qty controls
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold,
                        letterSpacing: 0.5, color: AppColors.receiptDark,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.secondary.withOpacity(0.9),
                        letterSpacing: 0.4, fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Qty stepper
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.09)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QtyBtn(Icons.remove, () =>
                              cart.decrement(item.id)),
                          SizedBox(
                            width: 28,
                            child: Text(
                              '${item.quantity}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          _QtyBtn(Icons.add, () =>
                              cart.increment(item.id)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Price + delete
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      cart.remove(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${item.name} REMOVED',
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    child: Container(
                      width: 32, height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD95555).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline,
                          size: 18, color: Color(0xFFD95555)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'UNIT PRICE: ₱${item.originalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary.withOpacity(0.5),
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    '₱${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold,
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

  Widget _placeholderImage() {
    return Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.fastfood_rounded,
          color: AppColors.primary.withOpacity(0.3), size: 28),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QTY BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 26, height: 26,
        child: Icon(icon, size: 14, color: AppColors.primary),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RETURN BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ReturnButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, '/menu'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chevron_left, size: 22, color: AppColors.primary),
            Text(
              'RETURN TO LNL CAFE MENU',
              style: TextStyle(
                fontSize: 12, color: AppColors.primary,
                fontWeight: FontWeight.bold, letterSpacing: 0.9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CART SUMMARY
// ─────────────────────────────────────────────────────────────────────────────

class _CartSummary extends StatelessWidget {
  final CartNotifier cart;
  final bool isMobile;
  const _CartSummary({required this.cart, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final items = cart.items;
    final subtotal = cart.subtotal;

    return Container(
      padding: const EdgeInsets.all(25),
      margin: isMobile
          ? const EdgeInsets.fromLTRB(16, 8, 16, 20)
          : const EdgeInsets.fromLTRB(20, 20, 30, 20),
      decoration: BoxDecoration(
        color: AppColors.receiptDark,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.receiptDark.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32, height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    size: 22, color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Text(
                'ORDER SUMMARY',
                style: TextStyle(
                  color: AppColors.white, fontSize: 20,
                  fontWeight: FontWeight.bold, letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Line items
          ...items.map(
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
                          style: const TextStyle(
                            color: AppColors.white, fontSize: 11,
                            fontWeight: FontWeight.bold, letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'X${item.quantity} UNITS',
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.7),
                            fontSize: 9, letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₱${(item.price).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.secondary, fontSize: 12,
                      fontWeight: FontWeight.w600, letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
          const SizedBox(height: 10),

          // Subtotal
          Row(
            children: [
              Text(
                'SUBTOTAL',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.55),
                  fontSize: 10, letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Text(
                '₱${subtotal.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.55),
                  fontSize: 11, fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Order total
          Row(
            children: [
              const Text(
                'ORDER TOTAL',
                style: TextStyle(
                  color: Colors.white, fontSize: 13,
                  fontWeight: FontWeight.bold, letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                '₱${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.secondary, fontSize: 24,
                  fontWeight: FontWeight.bold, letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Checkout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartCheckoutScreen(
                    // Pass a plain List<CartItem> copy to the checkout screen
                    items: cart.items.map((c) => legacy.CartItem(
                      id: c.id,
                      name: c.name,
                      category: c.category,
                      price: c.price,
                      originalPrice: c.originalPrice,
                      quantity: c.quantity,
                    )).toList(),
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 19),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: const Text(
                'PROCEED TO CHECKOUT',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.4,
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
                fontSize: 8, letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}