import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/constants/cart_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/services/customer/cms_service.dart';
import 'package:frontend/core/widgets/bamboo_background.dart';


const double _kMobile = 768;
const double _kDesktopMaxWidth = 1280;

// Brand Colors
const Color _bgBeige = Color(0xFFEFE2C9);
const Color _bgDark = Color(0xFF2D2A26);
const Color _primary = Color(0xFF758C6D); // Green
const Color _secondary = Color(0xFFA98258); // Gold

// ─────────────────────────────────────────────────────────────────────────────
// MODELS & DATA
// ─────────────────────────────────────────────────────────────────────────────

class HomeMenuItem {
  final int id;
  final String name;
  final double price;
  final String? imageAsset;
  const HomeMenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageAsset,
  });
  String get display => '₱${price.toStringAsFixed(2)}';
}

const _featuredBeverages = <HomeMenuItem>[
  HomeMenuItem(
    id: 100, 
    name: 'Nutella Frappe', 
    price: 120.00, 
    imageAsset: null,
    ),
  HomeMenuItem(
    id: 101, 
    name: 'Red Velvet Frappe', 
    price: 150.00, 
    imageAsset: null,
    ),
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
  int _stars = 4;
  final _ctrl = TextEditingController();
  bool _sent = false;
  String _msg = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _logout(BuildContext ctx) {

    if (widget.onLogout != null) {
      widget.onLogout!();
    }
    Navigator.of(ctx).pushNamedAndRemoveUntil('/', (route) => false);
  }

   Future<void> submitReview(int stars, String reviewText) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Debug: print ALL stored keys------------------------------------------------------------------------
      print("ALL PREFS KEYS: ${prefs.getKeys()}");
      print("user_id value: ${prefs.getInt('user_id')}");
      print("token value: ${prefs.getString('token')}");

      final userId =
          prefs.getInt('user_id') ??
          int.tryParse(
            prefs.getString('user_id_str') ?? '',
          ); //--------------------------------------------

      print("USER ID: $userId");
      print("STARS: $stars");
      print("TEXT: $reviewText");

      if (userId == null) {
        setState(() => _msg = "Not logged in.");
        return;
      }

      print("SENDING REVIEW REQUEST...");

      final response = await http.post(
        Uri.parse('http://localhost:3006/api/reviews/add-review'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'review_text': reviewText,
          'rating': stars,
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      //------------------------------------------------------------------not working validation----------------------------------------------
      if (response.statusCode == 200 || response.statusCode == 201) {
        _ctrl.clear();
        setState(() {
          _sent = true;
          _stars = 4;
          _msg =
              stars >= 4
                  ? '✨ Great! Thank you for the positive feedback!'
                  : '🙏 Thank you! We\'ll work on improving your experience.';
        });
      } else {
        setState(() {
          _msg = data['message'] ?? "Failed: ${response.body}";
        });
      }
    } catch (e) {
      print("ERROR TYPE: ${e.runtimeType}");
      print("FULL ERROR: $e");
      setState(() => _msg = "Error: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);
    return Scaffold(
      backgroundColor: _bgBeige,
      appBar: CustomerNavbar(
        activeRoute: '/home',
        cartCount: cart.totalCount,
        notifCount: 1,
        onLogout: () => _logout(context),
        onCart: () => Navigator.pushNamed(context, '/cart'),
        onNotif: () { ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Notifications clicked")),
  );},
        onProfile: () {},
      ),
      body: Stack(
        children: [
          // Moving Bamboo Background
          const BambooBackground(),

          SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _kDesktopMaxWidth,
                    ),
                    child: Column(
                      children: [
                        const _MainHero(),
                        const _PromoSection(),
                        const _FeaturedBeveragesSection(),
                        _ReviewFormSection(
                          stars: _stars,
                          ctrl: _ctrl,
                          sent: _sent,
                          msg: _msg,
                          onStars:
                              (s) => setState(() {
                                _stars = s;
                                _sent = false;
                                _msg = '';
                              }),
                          onSubmit: () async {
                            final text = _ctrl.text.trim();

                            if (_stars == 0) {
                              setState(
                                () => _msg = "Please select rating stars.",
                              );
                              return;
                            }

                            if (text.isEmpty) {
                              setState(
                                () => _msg = "Please write a review first.",
                              );
                              return;
                            }

                            //------------------------------------------------validation---------------------------------------------------
                            if (_stars >= 4) {
                              setState(
                                () =>
                                    _msg =
                                        "✨ Great! Thank you for the positive feedback!",
                              );
                            } else {
                              setState(
                                () =>
                                    _msg =
                                        "🙏 Thank you! We'll work on improving your experience.",
                              );
                            }

                            await submitReview(_stars, text);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const CustomerFooter(),
              ],
            ),
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
      child:
          asset != null
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                          ),
                      itemCount: 16,
                      itemBuilder:
                          (context, index) => Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: _secondary, width: 0.5),
                            ),
                          ),
                    ),
                  ),
                  Icon(
                    Icons.image_outlined,
                    color: _primary.withOpacity(0.3),
                    size: 36,
                  ),
                ],
              ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// HERO SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _MainHero extends StatelessWidget {
  
  const _MainHero();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
                'MAKING GOOD FOOD FOR PEOPLE\'S HAPPINESS.',
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
                      BoxShadow(
                        color: _bgDark,
                        blurRadius: 0,
                        offset: Offset(4, 4),
                      ),
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
      },
    );
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
            GestureDetector(
  onTap: () {
    final route = isPrimary ? '/contact' : '/menu';
    Navigator.pushNamed(context, route);
  },
  child: Container(
    width: 160,
    padding: const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 16,
    ),
    decoration: BoxDecoration(
      color: isPrimary ? Colors.white : AppColors.primary,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isPrimary ? _primary : Colors.white,
        width: 1.5,
      ),
    ),
    child: Text(
      buttonText,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Urbanist',
        fontWeight: FontWeight.w900,
        fontSize: 12,
        letterSpacing: 1.5,
        color: isPrimary ? _primary : Colors.white,
      ),
    ),
  ),
)
          ],
        ),
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
    return LayoutBuilder(
      builder: (_, c) {
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
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'FEATURED ',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w900,
                              fontSize: isMobile ? 20 : 30,
                              letterSpacing: -1.0,
                              color: _bgDark,
                            ),
                          ),
                          TextSpan(
                            text: 'BEVERAGES',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w900,
                              fontSize: isMobile ? 20 : 30,
                              letterSpacing: -1.0,
                              color: _primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'SEE ALL',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w900,
                            fontSize: isMobile ? 10 : 12,
                            letterSpacing: isMobile ? 2.0 : 3.0,
                            color: _secondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: _secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              isMobile
                  ? Column(
                    children:
                        _featuredBeverages
                            .map(
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: _MenuListRow(item: i),
                              ),
                            )
                            .toList(),
                  )
                  : LayoutBuilder(
                    builder: (_, cc) {
                      final gap = 32.0;
                      final cardW = (cc.maxWidth - gap * 3) / 4;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children:
                            _featuredBeverages
                                .map(
                                  (i) => _MenuGridCard(item: i, width: cardW),
                                )
                                .toList(),
                      );
                    },
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuListRow extends StatelessWidget {
  final HomeMenuItem item;
  const _MenuListRow({required this.item});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _ImgSlot(
            width: 80,
            height: 80,
            asset: item.imageAsset,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: _bgDark,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.display,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: _primary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: _secondary.withOpacity(0.3), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: _secondary,
            size: 20,
          ),
        ),
      ],
    );
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
            borderRadius: BorderRadius.circular(40),
          ),
          const SizedBox(height: 20),
          Text(
            item.name.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: _bgDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: _secondary.withOpacity(0.1),
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.display,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: _primary,
                    letterSpacing: -0.5,
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _bgBeige,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: _secondary,
                    size: 20,
                  ),
                ),
              ],
            ),
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
    required this.stars,
    required this.ctrl,
    required this.sent,
    required this.msg,
    required this.onStars,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final isMobile = c.maxWidth < _kMobile;
        final ph = isMobile ? 24.0 : 75.0;

        return Container(
          margin: EdgeInsets.fromLTRB(
            ph,
            isMobile ? 40 : 80,
            ph,
            isMobile ? 40 : 80,
          ),
          padding: EdgeInsets.fromLTRB(
            isMobile ? 24 : 48,
            isMobile ? 32 : 48,
            isMobile ? 24 : 48,
            0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _primary.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 30,
                offset: Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'RATE YOUR ',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: -1.0,
                        color: _bgDark,
                      ),
                    ),
                    TextSpan(
                      text: 'EXPERIENCE',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: -1.0,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'WE HIGHLY VALUE YOUR FEEDBACK!\nKINDLY TAKE A MOMENT\nTO RATE YOUR EXPERIENCE AND PROVIDE US WITH YOUR VALUABLE FEEDBACK.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  letterSpacing: 0.5,
                  height: 1.8,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => onStars(i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: i < stars ? _primary : _primary.withOpacity(0.2),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: ctrl,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'TELL US ABOUT YOUR EXPERIENCE!',
                  hintStyle: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _primary.withOpacity(0.3),
                  ),
                  filled: true,
                  fillColor: _bgBeige.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: _primary.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: _primary.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(20),
                  counterStyle: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 10,
                    color: _primary.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: sent ? null : onSubmit,
                //onTap: onSubmit,
                child: Container(
                  width: isMobile ? double.infinity : 300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: sent ? _primary.withOpacity(0.3) : _primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow:
                        sent
                            ? []
                            : [
                              BoxShadow(
                                color: _primary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.send_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 10),
                      Text(
                        'SEND REVIEW',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (msg.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _secondary.withOpacity(0.1),
                    border: Border.all(color: _secondary.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: _secondary,
                    ),
                  ),
                ),

              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }
}
