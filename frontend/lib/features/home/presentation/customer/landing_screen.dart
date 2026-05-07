import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/presentation/screens/register_screen.dart';
import 'package:frontend/features/customers/presentation/admin/menu_screen.dart';
import 'package:frontend/core/models/user.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/bamboo_background.dart';

const double _kMobile = 768;
const double _kDesktopMaxWidth = 1280;

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────

class LandingMenuItem {
  final String id, name, price, badge;
  final String? imageAsset;
  const LandingMenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.badge = 'BEST SELLER',
    this.imageAsset,
  });
}

class LandingReview {
  final String id, reviewer, initials, timeAgo, headline;
  final int stars;
  final bool isVerified;
  const LandingReview({
    required this.id,
    required this.reviewer,
    required this.initials,
    required this.timeAgo,
    required this.headline,
    required this.stars,
    this.isVerified = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA  — asset paths match EXACTLY what is in assets/images/
// ─────────────────────────────────────────────────────────────────────────────

// Hero collage: left card = pasta dish, right card = kitkat waffle
// These match your actual files: hero_pasta.png + hero_kitkat_waffle.png
const _heroImageAssets = <String>[
  'assets/images/hero_pasta.png',
  'assets/images/hero_nutella_frappe.png',
];

// Gallery carousel: exterior → notes wall → neon sign
const _gallerySlots = <String>[
  'assets/images/gallery_exterior.png',
  'assets/images/gallery_notes_wall.png',
  'assets/images/gallery_neon_sign.png',
];

// Best sellers (last 4 images you sent — images 10-13)
const _bestSellers = <LandingMenuItem>[
  LandingMenuItem(
    id: 'ms-1',
    name: 'Nutella Frappe',
    price: '₱120.00',
    imageAsset: 'assets/images/best_nutella_frappe.png',
  ),
  LandingMenuItem(
    id: 'ms-2',
    name: 'Red Velvet Frappe',
    price: '₱150.00',
    imageAsset: 'assets/images/best_redvelvet_frappe.png',
  ),
  LandingMenuItem(
    id: 'ms-3',
    name: "S'mores Waffle",
    price: '₱110.00',
    imageAsset: 'assets/images/best_waffle.png',
  ),
  LandingMenuItem(
    id: 'ms-4',
    name: 'Biscoff Frappe',
    price: '₱180.00',
    imageAsset: 'assets/images/best_biscoff_frappe.png',
  ),
];

// Seasonal favorites (images 6-9)
const _seasonal = <LandingMenuItem>[
  LandingMenuItem(
    id: 'sf-1',
    name: 'Hot Garlic Butter Chicken',
    price: '₱180.00',
    badge: 'SEASONAL',
    imageAsset: 'assets/images/seasonal_garlic_wings.png',
  ),
  LandingMenuItem(
    id: 'sf-2',
    name: 'Korean BBQ Wings',
    price: '₱180.00',
    badge: 'SEASONAL',
    imageAsset: 'assets/images/seasonal_korean_bbq.png',
  ),
  LandingMenuItem(
    id: 'sf-3',
    name: 'Dick Waffle',
    price: '₱180.00',
    badge: 'SEASONAL',
    imageAsset: 'assets/images/seasonal_dick_waffle.png',
  ),
  LandingMenuItem(
    id: 'sf-4',
    name: 'Habanero Mango',
    price: '₱180.00',
    badge: 'SEASONAL',
    imageAsset: 'assets/images/seasonal_habanero_mango.png',
  ),
];

const _reviews = <LandingReview>[
  LandingReview(
    id: 'r-1',
    reviewer: 'Maria Santos',
    initials: 'M',
    stars: 5,
    timeAgo: '9 months ago',
    headline: 'Quality, design, shipping 10/10',
  ),
  LandingReview(
    id: 'r-2',
    reviewer: 'Jose Reyes',
    initials: 'J',
    stars: 5,
    timeAgo: '9 months ago',
    headline: '10/10',
  ),
  LandingReview(
    id: 'r-3',
    reviewer: 'Ana de Leon',
    initials: 'A',
    stars: 5,
    timeAgo: '10 months ago',
    headline: 'Quality coffee perfect for any kind of event, highly recommended',
    isVerified: true,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class LandingScreen extends StatelessWidget {
  final Function(User) onLogin;
  final Function(User) onRegister;

  const LandingScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    void goLogin() => Navigator.push(
        context, MaterialPageRoute(builder: (_) => LoginScreen(onLogin: onLogin)));

    void goRegister() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RegisterScreen(onRegister: onRegister)));

    void goGuestMenu() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (menuContext) => MenuScreen(
            isGuest: true,
            onLoginRequired: () {
              Navigator.of(menuContext).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => LoginScreen(
                    onLogin: onLogin,
                    popToRootOnSuccess: true,
                  ),
                ),
              );
            },
          ),
        ));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GuestNavbar(
        activeRoute: '/home',
        onLogin: goLogin,
        onJoinNow: goRegister,
        onBrowseMenu: goGuestMenu,
      ),
      body: Stack(
        children: [
          const BambooBackground(),
          SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _kDesktopMaxWidth),
                    child: Column(children: [
                      _HeroSection(onBrowse: goGuestMenu),
                      _HighlightsBar(),
                      _GalleryCarousel(slots: _gallerySlots),
                      _WhyUsSection(),
                      _MenuGrid(
                        title: 'BEST SELLERS',
                        cta: 'SEE ALL',
                        items: _bestSellers,
                        onCtaTap: goGuestMenu,
                      ),
                      _MenuGrid(
                        title: 'SEASONAL FAVORITES',
                        cta: 'REGISTER TO ORDER',
                        items: _seasonal,
                        onCtaTap: goRegister,
                      ),
                      _ReviewsSection(reviews: _reviews),
                      _Newsletter(),
                    ]),
                  ),
                ),
                const GuestFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final VoidCallback onBrowse;
  const _HeroSection({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final isMobile = c.maxWidth < _kMobile;
      final ph = isMobile ? 20.0 : 75.0;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(ph, isMobile ? 32 : 64, ph, isMobile ? 32 : 72),
        child: isMobile
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _HeroText(onBrowse: onBrowse, isMobile: true),
                const SizedBox(height: 48),
                const _HeroCollage(isMobile: true),
              ])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 435,
                    child: _HeroText(onBrowse: onBrowse, isMobile: false),
                  ),
                  const Spacer(),
                  const _HeroCollage(isMobile: false),
                ],
              ),
      );
    });
  }
}

class _HeroText extends StatelessWidget {
  final VoidCallback onBrowse;
  final bool isMobile;
  const _HeroText({required this.onBrowse, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.45),
              border: Border.all(color: AppColors.primary.withOpacity(0.35)),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text('ESTABLISHED 2020',
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 4.5,
                    color: Color(0xFFEFE2C9))),
          ),
          const SizedBox(height: 28),
        ],
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: 'L&L ',
              style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 52 : 98,
                  color: const Color(0xFF2D2A26)),
            ),
            TextSpan(
              text: 'CAFE',
              style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 52 : 98,
                  color: AppColors.secondary),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        Text("Making good food for people's happiness",
            style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w400,
                fontSize: isMobile ? 15 : 26,
                height: 1.3,
                color: AppColors.primary)),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: onBrowse,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 28 : 40, vertical: isMobile ? 14 : 22),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Color(0xFF2D2A26), offset: Offset(4, 4))
              ],
            ),
            child: Text('BROWSE MENU',
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w900,
                    fontSize: isMobile ? 11 : 13,
                    letterSpacing: 1.2,
                    color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO COLLAGE  — semi-transparent green highlight tabs + real food images
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCollage extends StatelessWidget {
  final bool isMobile;
  const _HeroCollage({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return LayoutBuilder(builder: (_, c) {
        final w = (c.maxWidth - 16) / 2;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCard(w: w, h: w * 1.3, isTabRight: true,  asset: _heroImageAssets[0]),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: _HeroCard(w: w, h: w * 1.3, isTabRight: false, asset: _heroImageAssets[1]),
            ),
          ],
        );
      });
    }
    return SizedBox(
      width: 480,
      height: 440,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(
          left: 0, top: 0,
          child: _HeroCard(w: 230, h: 360, isTabRight: true,  asset: _heroImageAssets[0]),
        ),
        Positioned(
          right: 0, top: 80,
          child: _HeroCard(w: 230, h: 360, isTabRight: false, asset: _heroImageAssets[1]),
        ),
      ]),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final double w, h;
  final bool isTabRight;
  final String asset;

  const _HeroCard({
    required this.w,
    required this.h,
    required this.isTabRight,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    final tabWidth = w * 0.20;
    final imgWidth = w - tabWidth;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 12))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Row(
          children: [
            // ── Left green accent tab (semi-transparent) ──
            if (!isTabRight)
              Container(
                width: tabWidth,
                height: h,
                color: AppColors.secondary.withOpacity(0.72),
              ),

            // ── Photo area with subtle green tint ──
            SizedBox(
              width: imgWidth,
              height: h,
              child: Stack(fit: StackFit.expand, children: [
                Image.asset(
                  asset,
                  fit: BoxFit.cover,
                  // Graceful fallback if path is wrong during dev
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_outlined,
                              color: AppColors.primary.withOpacity(0.3), size: 36),
                          const SizedBox(height: 6),
                          Text(asset.split('/').last,
                              style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.primary.withOpacity(0.4))),
                        ],
                      ),
                    ),
                  ),
                ),
                // Very subtle warm green tint so photo doesn't look raw
                Container(color: AppColors.secondary.withOpacity(0.08)),
              ]),
            ),

            // ── Right green accent tab (semi-transparent) ──
            if (isTabRight)
              Container(
                width: tabWidth,
                height: h,
                color: AppColors.secondary.withOpacity(0.72),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HIGHLIGHTS BAR
// ─────────────────────────────────────────────────────────────────────────────

class _HighlightsBar extends StatelessWidget {
  static const _items = ['Open Daily', 'Free Wifi', 'Made with Love', 'Cozy Atmosphere'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final isMobile = c.maxWidth < _kMobile;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 75),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: isMobile ? 8 : 14,
          runSpacing: 4,
          children: _items.asMap().entries.map((e) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (e.key > 0) ...[
                Container(
                    width: isMobile ? 5 : 7,
                    height: isMobile ? 5 : 7,
                    decoration: BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle)),
                SizedBox(width: isMobile ? 6 : 12),
              ],
              Text(e.value,
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: isMobile ? 11 : 15,
                      color: AppColors.primary)),
            ],
          )).toList(),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GALLERY CAROUSEL  — real cafe photos
// ─────────────────────────────────────────────────────────────────────────────

class _GalleryCarousel extends StatefulWidget {
  final List<String> slots;
  const _GalleryCarousel({required this.slots});

  @override
  State<_GalleryCarousel> createState() => _GalleryCarouselState();
}

class _GalleryCarouselState extends State<_GalleryCarousel> {
  final _ctrl = PageController();
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_current + 1) % widget.slots.length;
      _ctrl.animateToPage(next,
          duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _go(int i) => _ctrl.animateToPage(i,
      duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final isMobile = c.maxWidth < _kMobile;
      final imgH = isMobile ? 240.0 : 520.0;

      return Padding(
        padding: EdgeInsets.only(top: isMobile ? 28 : 64),
        child: Column(children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 75),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                const TextSpan(
                    text: 'Experience the Heart of ',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                        color: Color(0xFF2D2A26))),
                TextSpan(
                    text: 'L&L Cafe',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                        color: AppColors.secondary)),
              ]),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: imgH,
            child: Stack(children: [
              PageView.builder(
                controller: _ctrl,
                itemCount: widget.slots.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 75),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(fit: StackFit.expand, children: [
                        Image.asset(
                          widget.slots[i],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      color: AppColors.primary.withOpacity(0.3),
                                      size: 48),
                                  const SizedBox(height: 8),
                                  Text(widget.slots[i].split('/').last,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.primary.withOpacity(0.4))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // White border frame overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.5), width: 5),
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
              Positioned(
                left: isMobile ? 4 : 48,
                top: imgH / 2 - 22,
                child: _ChevronBtn(
                    icon: Icons.chevron_left,
                    onTap: () => _go((_current - 1 + widget.slots.length) %
                        widget.slots.length)),
              ),
              Positioned(
                right: isMobile ? 4 : 48,
                top: imgH / 2 - 22,
                child: _ChevronBtn(
                    icon: Icons.chevron_right,
                    onTap: () => _go((_current + 1) % widget.slots.length)),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 120),
            child: Text(
                'From handcrafted beverages to freshly prepared meals, every corner of L&L Cafe is designed to bring comfort, flavor, and connection.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: isMobile ? 13 : 18,
                    height: 1.5,
                    color: AppColors.primary)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.slots.length, (i) {
              final on = i == _current;
              return GestureDetector(
                onTap: () => _go(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: on ? 30 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: on
                          ? AppColors.secondary
                          : AppColors.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(100)),
                ),
              );
            }),
          ),
        ]),
      );
    });
  }
}

class _ChevronBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ChevronBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WHY US SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _WhyUsSection extends StatelessWidget {
  static const _cards = [
    _WD('01', 'Sweet & Savory Delights',
        'From indulgent waffles and buttery toast to savory burgers, fries, and pasta. We have something for every taste.'),
    _WD('02', 'Affordable Quality',
        'We believe great food and drinks should be accessible, offering premium experience at reasonable prices.'),
    _WD('03', 'Perfect for Sharing',
        'Our party-size trays let you bring L&L Cafe to any gathering — share our bestsellers with friends and family.'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final isMobile = c.maxWidth < _kMobile;
      final ph = isMobile ? 20.0 : 75.0;
      return Padding(
        padding: EdgeInsets.fromLTRB(ph, isMobile ? 32 : 80, ph, 0),
        child: isMobile
            ? Column(
                children: _cards
                    .map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _WhyCard(data: w)))
                    .toList())
            : LayoutBuilder(builder: (_, cc) {
                final cardW = (cc.maxWidth - 40) / 3;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _cards.asMap().entries.map((e) => Row(children: [
                    if (e.key > 0) const SizedBox(width: 20),
                    SizedBox(width: cardW, child: _WhyCard(data: e.value)),
                  ])).toList(),
                );
              }),
      );
    });
  }
}

class _WD {
  final String number, title, body;
  const _WD(this.number, this.title, this.body);
}

class _WhyCard extends StatelessWidget {
  final _WD data;
  const _WhyCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.06)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 15, offset: Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: AppColors.secondary, borderRadius: BorderRadius.circular(12)),
            child: Center(
                child: Text(data.number,
                    style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Colors.white))),
          ),
          const SizedBox(height: 20),
          Text(data.title.toUpperCase(),
              style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: Color(0xFF2D2A26))),
          const SizedBox(height: 8),
          Text(data.body,
              style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.3,
                  height: 1.7,
                  color: AppColors.primary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MENU GRID
// ─────────────────────────────────────────────────────────────────────────────

class _MenuGrid extends StatelessWidget {
  final String title, cta;
  final List<LandingMenuItem> items;
  final VoidCallback? onCtaTap;

  const _MenuGrid({
    required this.title,
    required this.cta,
    required this.items,
    this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final isMobile = c.maxWidth < _kMobile;
      final ph = isMobile ? 20.0 : 75.0;
      final words = title.split(' ');
      final firstWord = words.first;
      final rest = words.skip(1).join(' ');

      return Padding(
        padding: EdgeInsets.fromLTRB(ph, isMobile ? 32 : 72, ph, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: AppColors.primary.withOpacity(0.15)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: '$firstWord ',
                        style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            letterSpacing: -1,
                            color: Color(0xFF2D2A26))),
                    TextSpan(
                        text: rest,
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            letterSpacing: -1,
                            color: AppColors.secondary)),
                  ])),
                  GestureDetector(
                    onTap: onCtaTap,
                    child: Row(children: [
                      Text(cta,
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 2.5,
                              color: AppColors.primary)),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(builder: (_, cc) {
              final cols = cc.maxWidth > 600 ? 4 : 2;
              const gap = 16.0;
              final cardW = (cc.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: items.map((i) => _MenuTile(item: i, width: cardW)).toList());
            }),
          ],
        ),
      );
    });
  }
}

class _MenuTile extends StatelessWidget {
  final LandingMenuItem item;
  final double width;
  const _MenuTile({required this.item, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: item.imageAsset != null
                  ? Image.asset(
                      item.imageAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withOpacity(0.08),
                        child: Center(
                          child: Icon(Icons.add_photo_alternate_outlined,
                              color: AppColors.primary.withOpacity(0.22), size: 28),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.primary.withOpacity(0.08),
                      child: Center(
                        child: Icon(Icons.add_photo_alternate_outlined,
                            color: AppColors.primary.withOpacity(0.22), size: 28),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Text(item.badge,
              style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w900,
                  fontSize: 8,
                  letterSpacing: 3.5,
                  color: AppColors.primary.withOpacity(0.55))),
          const SizedBox(height: 4),
          Text(item.name.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: Color(0xFF2D2A26))),
          const SizedBox(height: 6),
          Text(item.price,
              style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  fontSize: 20,
                  color: AppColors.secondary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REVIEWS
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewsSection extends StatefulWidget {
  final List<LandingReview> reviews;
  const _ReviewsSection({required this.reviews});

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  final _ctrl = PageController();
  int _current = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final isMobile = c.maxWidth < _kMobile;
      final ph = isMobile ? 20.0 : 75.0;
      return Padding(
        padding: EdgeInsets.fromLTRB(ph, isMobile ? 32 : 72, ph, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: AppColors.primary.withOpacity(0.12)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                      text: TextSpan(children: [
                    const TextSpan(
                        text: 'CUSTOMER ',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            letterSpacing: -1,
                            color: Color(0xFF2D2A26))),
                    TextSpan(
                        text: 'REVIEWS',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            letterSpacing: -1,
                            color: AppColors.secondary)),
                  ])),
                  if (!isMobile)
                    Row(children: [
                      _Arr(
                          left: true,
                          disabled: _current == 0,
                          onTap: () {
                            setState(() => _current = math.max(0, _current - 1));
                            _ctrl.animateToPage(_current,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut);
                          }),
                      const SizedBox(width: 10),
                      _Arr(
                          left: false,
                          disabled: _current == widget.reviews.length - 1,
                          onTap: () {
                            setState(() => _current =
                                math.min(widget.reviews.length - 1, _current + 1));
                            _ctrl.animateToPage(_current,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut);
                          }),
                    ]),
                ],
              ),
            ),
            const SizedBox(height: 24),
            isMobile
                ? SizedBox(
                    height: 230,
                    child: PageView.builder(
                      controller: _ctrl,
                      itemCount: widget.reviews.length,
                      onPageChanged: (i) => setState(() => _current = i),
                      itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _RevCard(r: widget.reviews[i])),
                    ),
                  )
                : LayoutBuilder(builder: (_, cc) {
                    final cols = cc.maxWidth > 700 ? 3 : 1;
                    const gap = 20.0;
                    final cardW = (cc.maxWidth - gap * (cols - 1)) / cols;
                    return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: widget.reviews
                            .map((r) => _RevCard(r: r, width: cardW))
                            .toList());
                  }),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.reviews.length, (i) {
                final on = i == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: on ? 30 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: on
                          ? AppColors.secondary
                          : AppColors.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(100)),
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}

class _Arr extends StatelessWidget {
  final bool left, disabled;
  final VoidCallback? onTap;
  const _Arr({required this.left, this.disabled = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: disabled ? Colors.white.withOpacity(0.4) : Colors.white,
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x12000000), blurRadius: 5, offset: Offset(0, 3))
          ],
        ),
        child: Icon(
            left ? Icons.chevron_left : Icons.chevron_right,
            color: disabled ? AppColors.primary.withOpacity(0.3) : AppColors.primary,
            size: 20),
      ),
    );
  }
}

class _RevCard extends StatelessWidget {
  final LandingReview r;
  final double? width;
  const _RevCard({required this.r, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              children: List.generate(
                  5,
                  (i) => Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Icon(i < r.stars ? Icons.star : Icons.star_border,
                          color: AppColors.primary, size: 16)))),
          const SizedBox(height: 6),
          Text(r.timeAgo.toUpperCase(),
              style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                  letterSpacing: 0.9,
                  color: AppColors.primary.withOpacity(0.55))),
          const SizedBox(height: 6),
          Text(r.headline,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF2D2A26))),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: AppColors.primary.withOpacity(0.1)))),
            child: Row(children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                    child: Text(r.initials,
                        style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: Colors.white))),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.reviewer.toUpperCase(),
                      style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Color(0xFF2D2A26))),
                  if (r.isVerified)
                    Row(children: [
                      Icon(Icons.verified, color: AppColors.secondary, size: 11),
                      const SizedBox(width: 3),
                      Text('VERIFIED',
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w700,
                              fontSize: 8,
                              color: AppColors.secondary)),
                    ]),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEWSLETTER
// ─────────────────────────────────────────────────────────────────────────────

class _Newsletter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final isMobile = c.maxWidth < _kMobile;
      final ph = isMobile ? 20.0 : 75.0;
      return Container(
        margin: EdgeInsets.fromLTRB(ph, isMobile ? 32 : 72, ph, isMobile ? 32 : 72),
        padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 64, vertical: isMobile ? 40 : 64),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: AppColors.secondary.withOpacity(0.25),
                blurRadius: 40,
                offset: const Offset(0, 20))
          ],
        ),
        child: Column(children: [
          Text('STAY IN THE LOOP',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  fontSize: isMobile ? 28 : 40,
                  letterSpacing: -1.5,
                  color: Colors.white)),
          const SizedBox(height: 10),
          Text(
              'SUBSCRIBE TO GET NOTIFIED ABOUT SECRET MENU ITEMS AND COFFEE WORKSHOPS.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 10 : 12,
                  letterSpacing: 1.5,
                  height: 1.8,
                  color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 28),
          Row(children: [
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(14)),
                child: const TextField(
                  style: TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'ENTER EMAIL ADDRESS',
                    hintStyle: TextStyle(
                        color: Color(0x99FFFFFF),
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 1),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1A000000), blurRadius: 10)
                  ]),
              child: Center(
                  child: Text('JOIN NOW',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 3,
                          color: AppColors.secondary))),
            ),
          ]),
        ]),
      );
    });
  }
}