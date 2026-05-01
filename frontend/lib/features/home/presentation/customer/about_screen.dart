import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/bamboo_background.dart';
import 'package:frontend/core/widgets/customer_footer.dart';

const double _kMobile = 900;
const double _kDesktopMaxWidth = 1280;
const Color _bgBeige = Color(0xFFEFE2C9);
const Color _bgDark  = Color(0xFF2D2A26);
const Color _primary = Color(0xFF758C6D);
const Color _secondary = Color(0xFFA98258);

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class AboutScreen extends StatelessWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onJoinNow;

  const AboutScreen({super.key, this.onLogin, this.onJoinNow});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBeige,
      body: Stack(
        children: [
          const BambooBackground(),
          Column(
            children: [
              GuestNavbar(
                activeRoute: '/about',
                onLogin: onLogin,
                onJoinNow: onJoinNow,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < _kMobile;
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: constraints.maxHeight),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            isMobile
                                ? _MobileLayout()
                                : _DesktopLayout(),
                            const GuestFooter(),
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
// DESKTOP LAYOUT
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
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
              // ── Page Title ──────────────────────────────────────────────
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'OUR ',
                      style: TextStyle(
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                        fontSize: 48, letterSpacing: -1.5, color: _bgDark,
                      ),
                    ),
                    TextSpan(
                      text: 'STORY',
                      style: TextStyle(
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                        fontSize: 48, letterSpacing: -1.5, color: _primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "MAKING GOOD FOOD FOR PEOPLE'S HAPPINESS",
                style: TextStyle(
                  fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                  fontSize: 11, letterSpacing: 3.0, color: _secondary,
                ),
              ),
              const SizedBox(height: 56),

              // ── Subtitle ────────────────────────────────────────────────
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'FROM ',
                        style: TextStyle(
                          fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                          fontSize: 28, letterSpacing: -0.5, color: _bgDark,
                        ),
                      ),
                      TextSpan(
                        text: 'HUMBLE BEGINNINGS',
                        style: TextStyle(
                          fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                          fontSize: 28, letterSpacing: -0.5, color: _primary,
                        ),
                      ),
                      TextSpan(
                        text: ' TO A ',
                        style: TextStyle(
                          fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                          fontSize: 28, letterSpacing: -0.5, color: _bgDark,
                        ),
                      ),
                      TextSpan(
                        text: 'NEW\nBREWED CHAPTER',
                        style: TextStyle(
                          fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                          fontSize: 28, letterSpacing: -0.5, color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // ── Story + Film strip ───────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: story text
                  Expanded(
                    flex: 5,
                    child: _StoryText(),
                  ),
                  const SizedBox(width: 56),
                  // Right: film strip collage
                  Expanded(
                    flex: 5,
                    child: _FilmStrip(),
                  ),
                ],
              ),
              const SizedBox(height: 64),

              // ── Value Cards ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: _ValueCard(
                    icon: Icons.wb_sunny_outlined,
                    title: 'COMFORT',
                    subtitle: 'A PLACE OF COMFORT TO BE YOU.',
                  )),
                  const SizedBox(width: 24),
                  Expanded(child: _ValueCard(
                    icon: Icons.favorite_border_rounded,
                    title: 'PASSION',
                    subtitle: 'MADE WITH LOVE IN EVERY CUP.',
                  )),
                  const SizedBox(width: 24),
                  Expanded(child: _ValueCard(
                    icon: Icons.people_outline_rounded,
                    title: 'COMMUNITY',
                    subtitle: 'A PLACE WHERE YOU MEET AND RELAX.',
                  )),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE LAYOUT
// ─────────────────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page Title ────────────────────────────────────────────────
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'ALL ABOUT ',
                  style: TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 32, letterSpacing: -1.0, color: _bgDark,
                  ),
                ),
                TextSpan(
                  text: 'L&L',
                  style: TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 32, letterSpacing: -1.0, color: _primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "MAKING GOOD FOOD FOR PEOPLE'S HAPPINESS",
            style: TextStyle(
              fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
              fontSize: 10, letterSpacing: 2.0, color: _secondary,
            ),
          ),
          const SizedBox(height: 28),

          // ── Film strip full width ──────────────────────────────────────
          _FilmStrip(),
          const SizedBox(height: 36),

          // ── Foundation section header ──────────────────────────────────
          Row(
            children: [
              Container(
                width: 4, height: 22,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'FOUNDATION',
                style: TextStyle(
                  fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                  fontSize: 16, letterSpacing: 2.0, color: _bgDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Story text ────────────────────────────────────────────────
          _StoryText(),
          const SizedBox(height: 40),

          // ── Value Cards stacked ───────────────────────────────────────
          _ValueCard(
            icon: Icons.wb_sunny_outlined,
            title: 'COMFORT',
            subtitle: 'A PLACE OF COMFORT TO BE YOU.',
          ),
          const SizedBox(height: 16),
          _ValueCard(
            icon: Icons.favorite_border_rounded,
            title: 'PASSION',
            subtitle: 'MADE WITH LOVE IN EVERY CUP.',
          ),
          const SizedBox(height: 16),
          _ValueCard(
            icon: Icons.people_outline_rounded,
            title: 'COMMUNITY',
            subtitle: 'A PLACE WHERE YOU MEET AND RELAX.',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STORY TEXT
// ─────────────────────────────────────────────────────────────────────────────

class _StoryText extends StatelessWidget {
  static const _paragraphs = [
    'Long before L&L Cafe became the cozy space it is today, it began as something much simpler—a small bakery and batchoyan in the early 2000s, quietly serving the community in front of Alimodian National Comprehensive High School. In those early mornings, the aroma of freshly baked bread filled the air, and warm bowls of batchoy brought comfort to students, workers, and neighbors alike. It wasn\'t just a place to eat—it was part of people\'s daily lives.',
    'In 2007, L&L found a new home on Cabaluna Street. Though the location changed, its purpose remained the same: to serve food made with care and to welcome every customer like family. Over time, as tastes evolved, so did L&L. By 2017, the cafe began to embrace a new identity, becoming known for its butter toast—a simple yet beloved offering that marked the beginning of its quiet transformation.',
    'Then came the pandemic, a moment that challenged many small businesses. But for L&L, it became a turning point. With courage and vision, the owners chose not just to continue—but to reinvent. The familiar space was carefully renovated and reborn as the cafe you see today, blending its rich history with a new, modern experience.',
    'What started as a humble bakery has grown into a place where coffee is shared, meals are enjoyed, and moments are created. Yet through every change, one thing has remained constant: L&L\'s commitment to serving its community with heart.',
    'Today, L&L Cafe stands not just as a business, but as a story—one shaped by resilience, passion, and the people who have been part of its journey.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _paragraphs.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          p,
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500,
            fontSize: 13,
            height: 1.85,
            color: _bgDark.withOpacity(0.75),
          ),
        ),
      )).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILM STRIP COLLAGE
// ─────────────────────────────────────────────────────────────────────────────

class _FilmStrip extends StatelessWidget {
  static const _images = [
    'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=300&q=80',
    'https://images.unsplash.com/photo-1497534446932-c925b458314e?w=300&q=80',
    'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=300&q=80',
    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300&q=80',
    'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=300&q=80',
    'https://images.unsplash.com/photo-1576618148400-f54bed99fcfd?w=300&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _bgDark.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Top film holes row
          _FilmHoles(),
          // Image grid — 2 rows × 3 cols
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Row(
                  children: _images.sublist(0, 3).map((url) =>
                    Expanded(child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: _bgDark.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    )),
                  ).toList(),
                ),
                Row(
                  children: _images.sublist(3, 6).map((url) =>
                    Expanded(child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: _bgDark.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    )),
                  ).toList(),
                ),
              ],
            ),
          ),
          // Bottom film holes row
          _FilmHoles(),
        ],
      ),
    );
  }
}

class _FilmHoles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      color: _bgDark,
      child: Row(
        children: List.generate(14, (i) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        )),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VALUE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ValueCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _bgDark.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon in beige rounded square
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: _secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _secondary, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
              fontSize: 16, letterSpacing: 0.5,
              fontStyle: FontStyle.italic,
              color: _bgDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
              fontSize: 10, letterSpacing: 1.5,
              color: _bgDark.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}
