import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/constants/cart_provider.dart';
import 'package:frontend/core/services/customer/cms_service.dart';


const double _kMobile = 768;
const double _kDesktopMaxWidth = 1280;

// Brand Colors
const Color _bgBeige  = Color(0xFFEFE2C9);
const Color _bgDark   = Color(0xFF2D2A26);
const Color _primary  = Color(0xFF758C6D); // Green
const Color _secondary= Color(0xFFA98258); // Gold

// ─────────────────────────────────────────────────────────────────────────────
// MODELS & DATA
// ─────────────────────────────────────────────────────────────────────────────

class HomeMenuItem {
  final int id;
  final String name;
  final double price;
  final String? imageAsset;
  const HomeMenuItem({required this.id, required this.name, required this.price, this.imageAsset});
  String get display => '₱${price.toStringAsFixed(2)}';
}

const _featuredBeverages = <HomeMenuItem>[
  HomeMenuItem(id: 100, name: 'Nutella Frappe', price: 120.00, imageAsset: null),
  HomeMenuItem(id: 101, name: 'Red Velvet Frappe', price: 150.00, imageAsset: null),
  HomeMenuItem(id: 102, name: 'S\'more', price: 110.00, imageAsset: null),
  HomeMenuItem(id: 103, name: 'Biscoff', price: 180.00, imageAsset: null),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CustomerHomeScreen extends StatefulWidget {
  
  final VoidCallback? onLogout;
  
  const CustomerHomeScreen({super.key, this.onLogout});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _stars    = 4;
  final _ctrl   = TextEditingController();
  bool _sent    = false;
  String _msg   = '';

  @override
  void dispose() { 
    _ctrl.dispose(); 
    super.dispose();
  }


  void _submit() {
    if (_stars == 0) return;
    setState(() {
      _sent = true;
      _msg  = _stars >= 4
          ? '✨ Great! Thank you for the positive feedback!'
          : '🙏 Thank you! We\'ll work on improving your experience.';
    });
  }

  void _logout(BuildContext ctx) {
    // ✅ FIXED: Wipe the user state, then route to the correct '/' path!
    if (widget.onLogout != null) {
      widget.onLogout!();
    }
    Navigator.of(ctx).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);
    return Scaffold(
      backgroundColor: _bgBeige,
      appBar: CustomerNavbar(
        activeRoute: '/home',
        cartCount:   cart.totalCount,
        notifCount:  1,
        onLogout:    () => _logout(context),
        onCart:      () => Navigator.pushNamed(context, '/cart'),
        onNotif:     () {},
        onProfile:   () {},
      ),
      body: Stack(
        children: [
          // Moving Bamboo Background
          const Positioned.fill(child: _BambooBackground()),

          SingleChildScrollView(
            child: Column(children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _kDesktopMaxWidth),
                  child: Column(
                    children: [
                      const _MainHero(),
                      const _PromoSection(),
                      const _FeaturedBeveragesSection(),
                      _ReviewFormSection(
                        stars:    _stars,
                        ctrl:     _ctrl,
                        sent:     _sent,
                        msg:      _msg,
                        onStars:  (s) => setState(() => _stars = s),
                        onSubmit: _submit,
                      ),
                    ]
                  ),
                ),
              ),
              const CustomerFooter(),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE IMAGE SLOT
// ─────────────────────────────────────────────────────────────────────────────

class _ImgSlot extends StatelessWidget {
  final double? width, height;
  final String? asset; 
  final BorderRadius? borderRadius;

  const _ImgSlot({this.width, this.height, this.asset, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    return Container(
      width: width, 
      height: height,
      decoration: BoxDecoration(
        color: _bgBeige.withOpacity(0.5), 
        borderRadius: radius,
        border: Border.all(color: _secondary.withOpacity(0.05)), 
      ),
      child: asset != null
          ? ClipRRect(
              borderRadius: radius,
              child: Image.asset(asset!, fit: BoxFit.cover),
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(border: Border.all(color: _secondary, width: 0.5)),
                    ),
                  ),
                ),
                Icon(Icons.image_outlined, color: _primary.withOpacity(0.3), size: 36),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOVING BAMBOO BACKGROUND WITH ORGANIC LEAVES
// ─────────────────────────────────────────────────────────────────────────────

class _BambooBackground extends StatefulWidget {
  const _BambooBackground();
  @override
  State<_BambooBackground> createState() => _BambooBackgroundState();
}

class _BambooBackgroundState extends State<_BambooBackground> with SingleTickerProviderStateMixin {
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
    [0.040, 13.0,  0.12, 1.53], [0.095, 7.0,   0.10, -1.84],
    [0.133, 14.0,  0.13, 1.45], [0.190, 9.0,   0.10, -0.72],
    [0.236, 9.5,   0.10, -0.71], [0.283, 13.0,  0.12, -1.53],
    [0.321, 13.0,  0.11, 1.24], [0.374, 1.9,   0.08, 0.29],
    [0.423, 2.2,   0.08, 0.35], [0.469, 2.6,   0.08, -0.34],
    [0.503, 20.0,  0.13, 2.00], [0.560, 4.1,   0.09, 1.06],
    [0.598, 17.6,  0.12, 1.82], [0.656, 8.9,   0.10, -0.98],
    [0.693, 15.5,  0.11, 1.72], [0.739, 17.9,  0.12, 1.99],
    [0.783, 18.8,  0.12, 1.81], [0.839, 8.9,   0.10, 0.66],
    [0.890, 5.2,   0.08, -1.98], [0.936, 16.6,  0.11, -1.89],
  ];
  
  void _drawLeaf(Canvas canvas, Offset offset, double angle, double length, double width, Paint paint) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle);
    
    final path = Path()
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
      final baseX  = size.width * (b[0] as double);
      final w      = b[1] as double;
      final deg    = b[3] as double;
      final h      = size.height;
      final double baseOp = b[2] as double;
      final op = isMobile ? baseOp * 0.4 : baseOp;
      final movementX = animationValue * size.width * (op * 8);
      final x = (baseX + movementX) % size.width;
      final sway = math.sin((animationValue * math.pi * 4) + (x * 0.01)) * 0.015;
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
        canvas.drawRect(Rect.fromLTWH(-w / 2 - 1.5, jointY - 1, w + 3, 2.5), paint);
        if ((index + i) % 4 != 0) { 
          bool isLeft = (index + i) % 2 == 0;
          double leafLength = w * 2.5 + 20.0;
          double leafWidth = leafLength * 0.25;
          double angle = isLeft ? math.pi * 0.8 : math.pi * 0.2;
          _drawLeaf(canvas, Offset(isLeft ? -w / 2 : w / 2, jointY), angle, leafLength, leafWidth, paint);
          if (i % 2 == 0) {
             double secondaryAngle = isLeft ? math.pi * 1.1 : -math.pi * 0.1;
             _drawLeaf(canvas, Offset(isLeft ? -w / 2 : w / 2, jointY), secondaryAngle, leafLength * 0.8, leafWidth * 0.8, paint);
          }
        }
      }

      canvas.translate(0, h * 0.2);
      canvas.rotate(math.pi / 4);
      canvas.drawRect(Rect.fromLTWH(-w * 0.6, -w * 0.6, w * 1.2, w * 1.2), paint);
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BambooPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.isMobile != isMobile;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _MainHero extends StatelessWidget {
  
  const _MainHero();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < _kMobile;

      return Padding(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 32 : 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'L&L CAFE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w900,
                fontSize: isMobile ? 48 : 128, 
                height: 1.0,
                letterSpacing: -2.0,
                color: _bgDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ARCHITECTING THE PERFECT BREW.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w900,
                fontSize: isMobile ? 10 : 20,
                letterSpacing: isMobile ? 2.0 : 4.0, 
                color: _secondary.withOpacity(0.8), 
              ),
            ),
            SizedBox(height: isMobile ? 24 : 40),
            
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 40 : 64,
                  vertical: isMobile ? 16 : 24,
                ),
                decoration: BoxDecoration(
                  color: _primary, 
                  border: Border.all(color: _bgDark, width: 1.5),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: const [
                    BoxShadow(color: _bgDark, blurRadius: 0, offset: Offset(4, 4))
                  ],
                ),
                child: Text(
                  'ORDER YOUR IDEAL',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w900,
                    fontSize: isMobile ? 14 : 16,
                    letterSpacing: 2.0,
                    color: Colors.white, 
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROMO BANNERS
// ─────────────────────────────────────────────────────────────────────────────
  String? getImageUrl(dynamic data) {
    try {
      final image = data['image'];
      if (image == null) return null;

      // Strapi v5 flattened structure
      final String? path = image['url'];

      if (path == null) return null;

      // Always ensure the path starts with /
      return path.startsWith('http') ? path : "http://localhost:1337$path";
    } catch (e) {
      debugPrint("Error parsing image URL: $e");
      return null;
    }
  }

class _PromoSection extends StatelessWidget {
  const _PromoSection();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CmsService.getPromotions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final promos = snapshot.data as List;

        final primary = promos.firstWhere(
          (p) => p['type'] == 'primary',
          orElse: () => null,
        );

        final secondary = promos.firstWhere(
          (p) => p['type'] == 'secondary',
          orElse: () => null,
        );

        return LayoutBuilder(builder: (_, c) {
          final isMobile = c.maxWidth < 768;

          return Padding(
            padding: EdgeInsets.all(isMobile ? 24 : 75),
            child: isMobile
                ? Column(
                    children: [
                      if (primary != null)
                        PromoCard(data: primary, isPrimary: true),
                      const SizedBox(height: 20),
                      if (secondary != null)
                        PromoCard(data: secondary, isPrimary: false),
                    ],
                  )
                : Row(
                    children: [
                      if (primary != null)
                        Expanded(child: PromoCard(data: primary, isPrimary: true)),
                      const SizedBox(width: 20),
                      if (secondary != null)
                        Expanded(child: PromoCard(data: secondary, isPrimary: false)),
                    ],
                  ),
          );
        });
      },
    );
  }
}


class PromoCard extends StatelessWidget {
  final dynamic data;
  final bool isPrimary;

  const PromoCard({
    super.key,
    required this.data,
    required this.isPrimary,
  });

  String extractText(dynamic desc) {
    try {
      if (desc == null || desc is! List || desc.isEmpty) return '';

      return desc[0]['children'][0]['text'] ?? '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = data['Title'] ?? '';
    final description = extractText(data['description']);
    final buttonText = data['buttonText'] ?? '';
    final imageUrl = getImageUrl(data);


    return Container(
      height: 260,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.4), 
                  BlendMode.dstIn,
                ),
              )
            : null,
        color: Colors.grey,
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black54,
              Colors.black26,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(color: Colors.white70),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


class _Promo1 extends StatelessWidget {
  final bool isMobile;
  const _Promo1({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(
        color: _primary, 
        borderRadius: BorderRadius.circular(isMobile ? 16 : 48),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CAFE SPECIAL: ESPRESSO',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                  fontSize: isMobile ? 18 : 24, letterSpacing: -0.5, color: Colors.white)),
          SizedBox(height: isMobile ? 12 : 24),
          Text('GET 20% OFF ON ALL ESPRESSO-BASED DRINKS EVERY MORNING. LIMITED TIME ARCHITECTURAL PROMOTION.', 
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: isMobile ? 10 : 14, height: 1.6, letterSpacing: 1.0,
                  color: Colors.white.withOpacity(0.9))),
          SizedBox(height: isMobile ? 24 : 32),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Text('CLAIM DISCOUNT', textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: isMobile ? 9 : 12, letterSpacing: 2.0, color: _primary)),
          ),
        ],
      ),
    );
  }
}

class _Promo2 extends StatelessWidget {
  final bool isMobile;
  const _Promo2({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(
        color: Colors.white, 
        border: Border.all(color: _secondary.withOpacity(0.2), width: 1.5), 
        borderRadius: BorderRadius.circular(isMobile ? 16 : 48),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NEW PASTRY SELECTION',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                  fontSize: isMobile ? 18 : 24, letterSpacing: -0.5, color: _bgDark)),
          SizedBox(height: isMobile ? 12 : 24),
          Text('FRESHLY BAKED CROISSANTS AND MUFFINS AVAILABLE NOW AT THE BLUEPRINT STATION.', 
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: isMobile ? 10 : 14, height: 1.6, letterSpacing: 1.0,
                  color: _secondary.withOpacity(0.8))),
          SizedBox(height: isMobile ? 24 : 32),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
            decoration: BoxDecoration(
              border: Border.all(color: _secondary, width: 2), 
              borderRadius: BorderRadius.circular(16)),
            child: Text('VIEW PASTRIES', textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: isMobile ? 9 : 12, letterSpacing: 2.0, color: _secondary)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FEATURED BEVERAGES
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturedBeveragesSection extends StatelessWidget {
  const _FeaturedBeveragesSection();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final isMobile = c.maxWidth < _kMobile;
      final ph = isMobile ? 24.0 : 75.0; 

      return Padding(
        padding: EdgeInsets.fromLTRB(ph, isMobile ? 40 : 80, ph, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(text: TextSpan(children: [
                    TextSpan(text: 'FEATURED ',
                        style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                            fontSize: isMobile ? 20 : 30, letterSpacing: -1.0, color: _bgDark)),
                    TextSpan(text: 'BEVERAGES',
                        style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                            fontSize: isMobile ? 20 : 30, letterSpacing: -1.0, color: _primary)),
                  ])),
                  Row(children: [
                    Text('SEE ALL', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                        fontSize: isMobile ? 10 : 12, letterSpacing: isMobile ? 2.0 : 3.0, color: _secondary)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 18, color: _secondary),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            isMobile
                ? Column(children: _featuredBeverages.map((i) =>
                    Padding(padding: const EdgeInsets.only(bottom: 24),
                        child: _MenuListRow(item: i))).toList())
                : LayoutBuilder(builder: (_, cc) {
                    final gap   = 32.0;
                    final cardW = (cc.maxWidth - gap * 3) / 4;
                    return Wrap(spacing: gap, runSpacing: gap,
                        children: _featuredBeverages.map((i) => _MenuGridCard(item: i, width: cardW)).toList());
                  }),
          ],
        ),
      );
    });
  }
}

class _MenuListRow extends StatelessWidget {
  final HomeMenuItem item;
  const _MenuListRow({required this.item});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: _ImgSlot(
          width: 80, 
          height: 80, 
          asset: item.imageAsset, 
          borderRadius: BorderRadius.circular(16)
        ),
      ),
      const SizedBox(width: 16),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name.toUpperCase(),
              style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                  fontSize: 14, color: _bgDark, letterSpacing: 0)),
          const SizedBox(height: 4),
          Text(item.display,
              style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                  fontSize: 16, color: _primary)), 
        ],
      )),
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.transparent, 
          border: Border.all(color: _secondary.withOpacity(0.3), width: 1.5), 
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.shopping_cart_outlined, color: _secondary, size: 20),
      ),
    ]);
  }
}

class _MenuGridCard extends StatelessWidget {
  final HomeMenuItem item;
  final double width;
  const _MenuGridCard({required this.item, required this.width});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImgSlot(
            width: width, 
            height: width, 
            asset: item.imageAsset, 
            borderRadius: BorderRadius.circular(40) 
          ),
          const SizedBox(height: 20),
          Text(item.name.toUpperCase(),
              style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                  fontSize: 18, color: _bgDark, letterSpacing: -0.5)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: _secondary.withOpacity(0.1), style: BorderStyle.solid)), 
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(item.display, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                  fontSize: 24, color: _primary, letterSpacing: -0.5)),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _bgBeige,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shopping_cart_outlined, color: _secondary, size: 20),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REVIEW FORM
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewFormSection extends StatelessWidget {
  final int stars;
  final TextEditingController ctrl;
  final bool sent;
  final String msg;
  final ValueChanged<int> onStars;
  final VoidCallback onSubmit;
  
  const _ReviewFormSection({
    required this.stars, required this.ctrl,
    required this.sent, required this.msg,
    required this.onStars, required this.onSubmit,
  });
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final isMobile = c.maxWidth < _kMobile;
      final ph = isMobile ? 24.0 : 75.0; 

      return Container(
        margin: EdgeInsets.fromLTRB(ph, isMobile ? 40 : 80, ph, isMobile ? 40 : 80),
        padding: EdgeInsets.fromLTRB(
            isMobile ? 24 : 48, isMobile ? 32 : 48,
            isMobile ? 24 : 48, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _primary.withOpacity(0.08)),
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 30, offset: Offset(0, 15))],
        ),
        child: Column(children: [
          RichText(textAlign: TextAlign.center, text: TextSpan(children: [
            TextSpan(text: 'RATE YOUR ',
                style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 24, letterSpacing: -1.0, color: _bgDark)),
            TextSpan(text: 'EXPERIENCE',
                style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 24, letterSpacing: -1.0, color: _primary)),
          ])),
          const SizedBox(height: 12),
          const Text(
            'WE HIGHLY VALUE YOUR FEEDBACK!\nKINDLY TAKE A MOMENT\nTO RATE YOUR EXPERIENCE AND PROVIDE US WITH YOUR VALUABLE FEEDBACK.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                fontSize: 10, letterSpacing: 0.5, height: 1.8, color: _primary),
          ),
          const SizedBox(height: 24),

          Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => onStars(i + 1),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: i < stars ? _primary : _primary.withOpacity(0.2),
                      size: 40)),
              ))),
          const SizedBox(height: 24),

          TextField(
            controller: ctrl,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'TELL US ABOUT YOUR EXPERIENCE!',
              hintStyle: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                  fontSize: 12, color: _primary.withOpacity(0.3)),
              filled: true,
              fillColor: _bgBeige.withOpacity(0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _primary.withOpacity(0.1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _primary.withOpacity(0.1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _primary, width: 1.5)),
              contentPadding: const EdgeInsets.all(20),
              counterStyle: TextStyle(fontFamily: 'Urbanist', fontSize: 10,
                  color: _primary.withOpacity(0.5)),
            ),
          ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: sent ? null : onSubmit,
            child: Container(
              width: isMobile ? double.infinity : 300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: sent ? _primary.withOpacity(0.3) : _primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: sent ? [] : [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(Icons.send_rounded, color: Colors.white, size: 16),
                SizedBox(width: 10),
                Text('SEND REVIEW',
                    style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                        fontSize: 13, letterSpacing: 2.5, color: Colors.white)),
              ]),
            ),
          ),

          const SizedBox(height: 16),

          if (sent && msg.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: _secondary.withOpacity(0.1),
                border: Border.all(color: _secondary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(msg, textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                      fontSize: 12, color: _secondary)),
            ),

          const SizedBox(height: 48),
        ]),
      );
    });
  }
}