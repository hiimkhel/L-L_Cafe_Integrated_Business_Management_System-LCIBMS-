import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

const double _kMobile = 768;

// ─────────────────────────────────────────────────────────────────────────────
// GUEST FOOTER  (full landing / contact footer)
// ─────────────────────────────────────────────────────────────────────────────

class GuestFooter extends StatelessWidget {
  const GuestFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      ),
      child: LayoutBuilder(builder: (_, c) {
        final isMobile = c.maxWidth < _kMobile;
        return isMobile ? _GuestFooterMobile() : _GuestFooterDesktop();
      }),
    );
  }
}

// ── Desktop ──────────────────────────────────────────────────────────────────

class _GuestFooterDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(64, 64, 64, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand block
              SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/lnl.jpg',
                          width: 56, height: 56, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text('L&L',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('CAFE',
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              color: Color(0xFF2D2A26))),
                    ]),
                    const SizedBox(height: 16),
                    Text(
                      'WHERE ARCHITECTURAL DESIGN\nMEETS CRAFTED BREWING\nPERFECTION',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.5,
                          height: 2.0,
                          color: AppColors.primary.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Link columns
              _Col(title: 'NAVIGATION', links: const ['Menu', 'Locations', 'Our Story']),
              const SizedBox(width: 64),
              _Col(title: 'SOCIAL', links: const ['Instagram', 'Facebook', 'LinkedIn']),
              const SizedBox(width: 64),
              _Col(title: 'SUPPORT', links: const ['Contact', '⚙ Staff']),
            ],
          ),

          const SizedBox(height: 48),

          // Copyright
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: AppColors.primary.withOpacity(0.1))),
            ),
            child: Text(
              '© 2026 L&L CAFE CO.',
              style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 4,
                  color: AppColors.primary.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile — matches wireframe Image 2 exactly ────────────────────────────────

class _GuestFooterMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand block — dark rounded square + CAFE text
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2D2A26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('L&L',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11)),
              ),
            ),
            const SizedBox(width: 10),
            const Text('CAFE',
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Color(0xFF2D2A26))),
          ]),

          const SizedBox(height: 10),

          // Tagline matching wireframe
          Text(
            'WHERE ARCHITECTURAL DESIGN\nMEETS CRAFTED BREWING\nPERFECTION',
            style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
                fontSize: 9,
                letterSpacing: 0.5,
                height: 1.9,
                color: AppColors.primary.withOpacity(0.7)),
          ),

          const SizedBox(height: 32),

          // Three columns matching wireframe: ABOUT | SUPPORT | CONNECT
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Col(
                  title: 'ABOUT',
                  links: const ['Menu', 'Locations', 'Our Story'],
                ),
              ),
              Expanded(
                child: _Col(
                  title: 'SUPPORT',
                  links: const ['FAQs', 'Contact'],
                ),
              ),
              Expanded(
                child: _Col(
                  title: 'CONNECT',
                  links: const ['Facebook'],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Copyright — centered
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: AppColors.primary.withOpacity(0.1))),
            ),
            child: Center(
              child: Text(
                '© 2026 L&L CAFE CO.',
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 2.5,
                    color: AppColors.primary.withOpacity(0.55)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER FOOTER  (slim — logged-in screens)
// ─────────────────────────────────────────────────────────────────────────────

class CustomerFooter extends StatelessWidget {
  const CustomerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        border: Border(
            top: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 28),
      child: LayoutBuilder(builder: (_, c) {
        final isMobile = c.maxWidth < _kMobile;
        return isMobile
            ? Column(children: [
                const Text('L&L CAFE',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: -0.5,
                        color: Color(0xFF2D2A26))),
                const SizedBox(height: 4),
                Text('ARCHITECTING THE PERFECT BREW',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 8,
                        letterSpacing: 2,
                        color: AppColors.primary.withOpacity(0.6))),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 20,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: ['Privacy Policy', 'Terms of Service', 'Support']
                      .map((l) => Text(l.toUpperCase(),
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 2,
                              color: AppColors.primary)))
                      .toList(),
                ),
                const SizedBox(height: 10),
                Text('© 2026 L&L CAFE. ALL RIGHTS RESERVED',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 8,
                        color: AppColors.primary.withOpacity(0.45))),
              ])
            : Row(children: [
                // Logo + CAFE
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D2A26),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: const Center(
                      child: Text('L&L',
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('CAFE',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Color(0xFF2D2A26))),
                ]),
                const Spacer(),
                Wrap(
                  spacing: 36,
                  children: ['Privacy Policy', 'Terms of Service', 'Support']
                      .map((l) => Text(l.toUpperCase(),
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 3,
                              color: AppColors.primary)))
                      .toList(),
                ),
              ]);
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED
// ─────────────────────────────────────────────────────────────────────────────

class _Col extends StatelessWidget {
  final String title;
  final List<String> links;
  const _Col({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1,
                color: AppColors.secondary)),
        const SizedBox(height: 16),
        ...links.map((l) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Text(l.toUpperCase(),
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      color: AppColors.primary)),
            )),
      ],
    );
  }
}