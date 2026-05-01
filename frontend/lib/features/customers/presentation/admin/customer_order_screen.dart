import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/constants/menu_data.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/constants/cart_item.dart';
import 'package:frontend/features/customers/presentation/admin/cart_screen.dart';
import 'package:frontend/core/constants/cart_provider.dart';


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

//-------------------------------------------screen------------------------------------------------------------
class CustomerOrderScreen extends StatefulWidget {
  final List<Order> orders; // ← add this

  const CustomerOrderScreen({super.key, this.orders = const []});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);
    final isMobile = MediaQuery.of(context).size.width < _kMobile;
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Stack(
        children: [        
          const Positioned.fill(child: _BambooBackground()),
          Column(
            children: [
              CustomerNavbar(
                activeRoute: '/orders',
                cartCount: cart.totalCount,
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
                      if (isMobile)
                        ...[

                      ] else ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _customerOrderHeader(),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Divider(
                                thickness: 1.2,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _customerOderCategory(),
                            const SizedBox(height: 10),
                            _customerOrders(),
                            const SizedBox(height: 10),
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

  Widget _customerOrderHeader({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 45,
        15,
        isMobile ? 16 : 30,
        0,
      ),
      child: Row(
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
                  text: 'ORDER STATUS: ',
                  style: TextStyle(color: AppColors.receiptDark),
                ),
                TextSpan(
                  text: 'ORDERS',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerOderCategory() {
    final List<Map<String, String>> categories = [
      {'label': 'PENDING'},
      {'label': 'IN PROGRESS'},
      {'label': 'ARCHIVE (2)'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        children: List.generate(categories.length, (i) {
          final isActive = i == _selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: i < categories.length - 1 ? 20 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 55,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      isActive ? const Color(0xFF9E7145) : AppColors.background,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  categories[i]['label']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                    color:
                        isActive
                            ? Colors.white
                            : AppColors.primary.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _customerOrders() {
    final filtered =
        widget.orders.where((o) {
          if (_selectedIndex == 0) return o.status == OrderStatus.pending;
          if (_selectedIndex == 1) return o.status == OrderStatus.inProgress;
          return o.status == OrderStatus.archived;
        }).toList();

    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          'No orders yet.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      children:
          filtered.map((order) {
            // ← loop through orders
            return Container(
              margin: const EdgeInsets.only(
                bottom: 12,
              ), // spacing between cards
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            'REFERENCE CODE',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text('#${order.id}'), // ← pull the ID here
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
