import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/bamboo_breeze_background.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/constants/cart_provider.dart';

const double _kMobile = 900;
const double _kDesktopMaxWidth = 1280;
const Color _bgBeige   = Color(0xFFEFE2C9);
const Color _bgDark    = Color(0xFF2D2A26);
const Color _primary   = Color(0xFF758C6D);
const Color _secondary = Color(0xFFA98258);

const _kHeroBanner = 'assets/images/gallery_neon_sign.png';
const _kExterior   = 'assets/images/gallery_exterior.png';
const _kNotesWall  = 'assets/images/gallery_notes_wall.png';
const _kPasta      = 'assets/images/hero_pasta.png';
const _kWaffle     = 'assets/images/hero_kitkat_waffle.png';
const _kNutella    = 'assets/images/best_nutella_frappe.png';
const _kBiscoff    = 'assets/images/best_biscoff_frappe.png';

const _filmImages = <String>[
  _kExterior, _kNotesWall, _kPasta, _kNutella, _kWaffle, _kBiscoff,
];

class _Dish {
  final String image, label, sub;
  const _Dish(this.image, this.label, this.sub);
}

const _dishes = <_Dish>[
  _Dish(_kPasta,   'SIGNATURE PASTA',  'Creamy & herb-loaded'),
  _Dish(_kWaffle,  'KITKAT WAFFLE',    'Our #1 bestseller'),
  _Dish(_kNutella, 'NUTELLA FRAPPE',   'Handcrafted drinks'),
];

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT SCREEN
// isGuest=true  → GuestNavbar (landing/guest flow)
// isGuest=false → CustomerNavbar (logged-in flow)
// ─────────────────────────────────────────────────────────────────────────────

class AboutScreen extends StatelessWidget {
  final bool isGuest;
  final VoidCallback? onLogin;
  final VoidCallback? onJoinNow;
  final VoidCallback? onLogout;

  const AboutScreen({
    super.key,
    this.isGuest = true,
    this.onLogin,
    this.onJoinNow,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final cart = isGuest ? null : CartProvider.of(context);

    final PreferredSizeWidget navbar = isGuest
        ? GuestNavbar(
            activeRoute: '/about',
            onLogin: onLogin,
            onJoinNow: onJoinNow,
            onBrowseMenu: () => Navigator.pushReplacementNamed(context, '/menu'),
          )
        : CustomerNavbar(
            activeRoute: '/about',
            cartCount: cart?.totalCount ?? 0,
            notifCount: 0,
            isGuest: false,
            onProfile: () => Navigator.pushReplacementNamed(context, '/profile'),
            onLogout: () {
              onLogout?.call();
              Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
            },
          );

    return Scaffold(
      backgroundColor: _bgBeige,
      body: Stack(
        children: [
          const BreezeBambooBackground(),
          Column(
            children: [
              navbar,
              Expanded(
                child: LayoutBuilder(builder: (ctx, c) {
                  final isMobile = c.maxWidth < _kMobile;
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: c.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          isMobile ? const _MobileLayout() : const _DesktopLayout(),
                          const GuestFooter(),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESKTOP
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kDesktopMaxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroBanner(),
              const SizedBox(height: 64),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                RichText(
                  text: const TextSpan(children: [
                    TextSpan(text: 'OUR ', style: TextStyle(
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                        fontSize: 48, letterSpacing: -1.5, color: _bgDark)),
                    TextSpan(text: 'STORY', style: TextStyle(
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                        fontSize: 48, letterSpacing: -1.5, color: _primary)),
                  ]),
                ),
                const SizedBox(width: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('EST. 2020  •  ALIMODIAN, ILOILO',
                      style: TextStyle(fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w700, fontSize: 11,
                          letterSpacing: 2.8, color: _secondary.withOpacity(0.8))),
                ),
              ]),
              const SizedBox(height: 6),
              Container(height: 3, width: 90,
                decoration: BoxDecoration(
                    color: _secondary, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 52),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _StoryText()),
                  SizedBox(width: 56),
                  Expanded(flex: 5, child: _FilmStrip()),
                ],
              ),
              const SizedBox(height: 64),
              const _SectionLabel(text: 'FROM OUR KITCHEN'),
              const SizedBox(height: 20),
              const _DishShowcase(),
              const SizedBox(height: 64),
              const _SectionLabel(text: 'WHAT WE STAND FOR'),
              const SizedBox(height: 20),
              Row(children: const [
                Expanded(child: _ValueCard(icon: Icons.wb_sunny_outlined,
                    title: 'COMFORT', subtitle: 'A PLACE OF COMFORT TO BE YOU.')),
                SizedBox(width: 24),
                Expanded(child: _ValueCard(icon: Icons.favorite_border_rounded,
                    title: 'PASSION', subtitle: 'MADE WITH LOVE IN EVERY CUP.')),
                SizedBox(width: 24),
                Expanded(child: _ValueCard(icon: Icons.people_outline_rounded,
                    title: 'COMMUNITY', subtitle: 'A PLACE WHERE YOU MEET AND RELAX.')),
              ]),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE
// ─────────────────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HeroBanner(isMobile: true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(text: const TextSpan(children: [
                TextSpan(text: 'ALL ABOUT ', style: TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 30, letterSpacing: -1.0, color: _bgDark)),
                TextSpan(text: 'L&L', style: TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 30, letterSpacing: -1.0, color: _primary)),
              ])),
              const SizedBox(height: 5),
              Container(height: 3, width: 56,
                decoration: BoxDecoration(
                    color: _secondary, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 8),
              Text("MAKING GOOD FOOD FOR PEOPLE'S HAPPINESS",
                  style: TextStyle(fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700, fontSize: 9,
                      letterSpacing: 2.0, color: _secondary.withOpacity(0.85))),
              const SizedBox(height: 28),
              const _FilmStrip(),
              const SizedBox(height: 32),
              Row(children: [
                Container(width: 4, height: 22,
                  decoration: BoxDecoration(color: _primary,
                      borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 12),
                const Text('FOUNDATION', style: TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 15, letterSpacing: 2.0, color: _bgDark)),
              ]),
              const SizedBox(height: 18),
              const _StoryText(),
              const SizedBox(height: 32),
              const _SectionLabel(text: 'FROM OUR KITCHEN'),
              const SizedBox(height: 16),
              const _DishShowcase(isMobile: true),
              const SizedBox(height: 32),
              const _SectionLabel(text: 'WHAT WE STAND FOR'),
              const SizedBox(height: 16),
              const _ValueCard(icon: Icons.wb_sunny_outlined,
                  title: 'COMFORT', subtitle: 'A PLACE OF COMFORT TO BE YOU.'),
              const SizedBox(height: 14),
              const _ValueCard(icon: Icons.favorite_border_rounded,
                  title: 'PASSION', subtitle: 'MADE WITH LOVE IN EVERY CUP.'),
              const SizedBox(height: 14),
              const _ValueCard(icon: Icons.people_outline_rounded,
                  title: 'COMMUNITY', subtitle: 'A PLACE WHERE YOU MEET AND RELAX.'),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO BANNER
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final bool isMobile;
  const _HeroBanner({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(24),
      child: SizedBox(
        width: double.infinity,
        height: isMobile ? 240 : 380,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(_kHeroBanner, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: _bgDark)),
          Container(decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0x22000000), Color(0xDD000000)],
            ),
          )),
          Positioned(
            bottom: isMobile ? 24 : 40,
            left: isMobile ? 20 : 48,
            right: isMobile ? 20 : 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                      color: _secondary.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('ESTABLISHED 2020', style: TextStyle(
                      fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                      fontSize: 9, letterSpacing: 3.5, color: Colors.white)),
                ),
                const SizedBox(height: 10),
                Text('L&L CAFE', style: TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: isMobile ? 36 : 52,
                    letterSpacing: -1.0, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Alimodian, Iloilo — Food, coffee & community',
                    style: TextStyle(fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
          if (!isMobile) ...[
            Positioned(top: 28, right: 40,
                child: _Thumb(image: _kExterior, label: 'OUR PLACE')),
            Positioned(top: 28, right: 192,
                child: _Thumb(image: _kNotesWall, label: 'WISH BOARD')),
          ],
        ]),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String image, label;
  const _Thumb({required this.image, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 130, height: 90,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(image, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: _primary.withOpacity(0.2))),
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(
          fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
          fontSize: 8, letterSpacing: 2.0,
          color: Colors.white.withOpacity(0.6))),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STORY TEXT
// ─────────────────────────────────────────────────────────────────────────────

class _StoryText extends StatelessWidget {
  const _StoryText();

  static const _paragraphs = [
    'Long before L&L Cafe became the cozy space it is today, it began as something much simpler — a small bakery and batchoyan in the early 2000s, quietly serving the community in front of Alimodian National Comprehensive High School.',
    'In 2007, L&L found a new home on Cabaluna Street. Though the location changed, its purpose remained the same: to serve food made with care and to welcome every customer like family.',
    'By 2017, the cafe began to embrace a new identity, becoming known for its butter toast — a simple yet beloved offering that marked the beginning of its quiet transformation.',
    'Then came the pandemic, a moment that challenged many small businesses. But for L&L, it became a turning point. With courage and vision, the owners chose not just to continue — but to reinvent.',
    'Today, L&L Cafe stands not just as a business, but as a story — one shaped by resilience, passion, and the people who have been part of its journey.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _paragraphs.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(p, textAlign: TextAlign.justify,
            style: TextStyle(fontFamily: 'Urbanist',
                fontWeight: FontWeight.w500, fontSize: 13, height: 1.85,
                color: _bgDark.withOpacity(0.75))),
      )).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DISH SHOWCASE
// ─────────────────────────────────────────────────────────────────────────────

class _DishShowcase extends StatelessWidget {
  final bool isMobile;
  const _DishShowcase({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(children: _dishes.map((d) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _DishCard(dish: d, isMobile: true),
      )).toList());
    }
    return Row(children: _dishes.asMap().entries.map((e) => Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: e.key < _dishes.length - 1 ? 20 : 0),
        child: _DishCard(dish: e.value),
      ),
    )).toList());
  }
}

class _DishCard extends StatelessWidget {
  final _Dish dish;
  final bool isMobile;
  const _DishCard({required this.dish, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: isMobile ? 16 / 9 : 4 / 5,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(dish.image, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: _primary.withOpacity(0.1),
                child: Center(child: Icon(Icons.image_outlined,
                    color: _primary.withOpacity(0.3), size: 36)),
              )),
          Container(decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter, end: Alignment.topCenter,
              colors: [Color(0xEE000000), Colors.transparent],
            ),
          )),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(dish.label, style: const TextStyle(
                      fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                      fontSize: 13, letterSpacing: 0.5, color: Colors.white)),
                  Text(dish.sub, style: TextStyle(
                      fontFamily: 'Urbanist', fontWeight: FontWeight.w500,
                      fontSize: 11, color: Colors.white.withOpacity(0.65))),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILM STRIP
// ─────────────────────────────────────────────────────────────────────────────

class _FilmStrip extends StatelessWidget {
  const _FilmStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _bgDark.withOpacity(0.35),
            blurRadius: 28, offset: const Offset(0, 10))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        const _FilmHoles(),
        Container(
          color: const Color(0xFF1A1A1A),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Center(child: Text('L&L CAFE  •  ALIMODIAN, ILOILO',
              style: TextStyle(fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700, fontSize: 8, letterSpacing: 3.5,
                  color: _secondary.withOpacity(0.7)))),
        ),
        _buildRow(_filmImages.sublist(0, 3)),
        _buildRow(_filmImages.sublist(3, 6), isLast: true),
        const _FilmHoles(),
      ]),
    );
  }

  Widget _buildRow(List<String> paths, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, isLast ? 3 : 6, 8, isLast ? 6 : 3),
      child: Row(children: paths.map((path) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(path, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: _bgDark.withOpacity(0.6),
                    child: Center(child: Icon(Icons.image_outlined,
                        color: Colors.white.withOpacity(0.2), size: 20)),
                  )),
            ),
          ),
        ),
      )).toList()),
    );
  }
}

class _FilmHoles extends StatelessWidget {
  const _FilmHoles();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22, color: _bgDark,
      child: Row(children: List.generate(16, (i) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          child: Container(decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(2))),
        ),
      ))),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 4, height: 22,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [_primary, Color(0xFF3D5A45)]),
          borderRadius: BorderRadius.circular(2),
        )),
      const SizedBox(width: 12),
      Text(text, style: const TextStyle(fontFamily: 'Urbanist',
          fontWeight: FontWeight.w900, fontSize: 14,
          letterSpacing: 2.0, color: _bgDark)),
    ]);
  }
}

class _ValueCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _ValueCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _bgDark.withOpacity(0.07),
            blurRadius: 24, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 48, height: 48,
          decoration: BoxDecoration(color: _secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: _secondary, size: 24)),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontFamily: 'Urbanist',
            fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5,
            fontStyle: FontStyle.italic, color: _bgDark)),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600, fontSize: 10, letterSpacing: 1.5,
            color: _bgDark.withOpacity(0.45))),
      ]),
    );
  }
}