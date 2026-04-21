import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

const double _kMobile = 768;

// ─────────────────────────────────────────────────────────────────────────────
// GUEST FOOTER  (full landing footer)
// Left: Logo + CAFE + tagline
// Right: Navigation | Social | Support columns
// Bottom: © 2026 L&L CAFE CO.
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
                        child: Image.asset('assets/images/lnl.jpg',
                            width: 56, height: 56, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Center(child: Text('L&L',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
                            )),
                      ),
                      const SizedBox(width: 12),
                      const Text('CAFE',
                          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                              fontSize: 22, color: Color(0xFF2D2A26))),
                    ]),
                    const SizedBox(height: 16),
                    Text('MAKING GOOD FOOD FOR\nPEOPLE\'S HAPPINESS',
                        style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                            fontSize: 11, letterSpacing: 1, height: 2.2, color: AppColors.primary)),
                  ],
                ),
              ),
              const Spacer(),

              // Link columns
              _Col(title: 'NAVIGATION', links: const ['Menu', 'Locations', 'Story']),
              const SizedBox(width: 64),
              _Col(title: 'SOCIAL', links: const ['Instagram', 'Facebook', 'Twitter']),
              const SizedBox(width: 64),
              _Col(title: 'SUPPORT', links: const ['FAQ', 'Contact']),
            ],
          ),

          const SizedBox(height: 48),

          // Copyright
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.1))),
            ),
            child: Text('© 2026 L&L CAFE CO.',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 10, letterSpacing: 4, color: AppColors.primary.withOpacity(0.6))),
          ),
        ],
      ),
    );
  }
}

class _GuestFooterMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/lnl.jpg',
                  width: 44, height: 44, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: Text('L&L', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10))))),
            ),
            const SizedBox(width: 10),
            const Text('CAFE', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2D2A26))),
          ]),
          const SizedBox(height: 12),
          Text('MAKING GOOD FOOD FOR PEOPLE\'S HAPPINESS',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                  fontSize: 9, letterSpacing: 1.5, height: 2, color: AppColors.primary)),

          const SizedBox(height: 28),

          // Link columns row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Col(title: 'ABOUT', links: const ['Home', 'Our Story', 'Locations']),
              const SizedBox(width: 32),
              _Col(title: 'SUPPORT', links: const ['FAQ', 'Contact']),
              const SizedBox(width: 32),
              _Col(title: 'CONNECT', links: const ['Instagram', 'Facebook']),
            ],
          ),

          const SizedBox(height: 24),

          // Copyright
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.1))),
            ),
            child: Text('© 2026 L&L CAFE CO.',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                    fontSize: 9, letterSpacing: 2.5, color: AppColors.primary.withOpacity(0.55))),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER FOOTER  (slim — logged-in)
// Logo CAFE | Privacy Policy · Terms of Service · Architectural Support
// Mobile: stacked centered
// ─────────────────────────────────────────────────────────────────────────────

class CustomerFooter extends StatelessWidget {
  const CustomerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 28),
      child: LayoutBuilder(builder: (_, c) {
        final isMobile = c.maxWidth < _kMobile;
        return isMobile
            ? Column(children: [
                Text('L&L CAFE',
                    style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                        fontSize: 14, letterSpacing: -0.5, color: Color(0xFF2D2A26))),
                const SizedBox(height: 4),
                Text('ARCHITECTING THE PERFECT BREW',
                    style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                        fontSize: 8, letterSpacing: 2, color: AppColors.primary.withOpacity(0.6))),
                const SizedBox(height: 14),
                Wrap(spacing: 20, runSpacing: 6, alignment: WrapAlignment.center,
                    children: ['Privacy Policy', 'Terms of Service', 'Support']
                        .map((l) => Text(l.toUpperCase(),
                            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                                fontSize: 9, letterSpacing: 2, color: AppColors.primary)))
                        .toList()),
                const SizedBox(height: 10),
                Text('© 2026 L&L CAFE. ALL RIGHTS RESERVED',
                    style: TextStyle(fontFamily: 'Urbanist', fontSize: 8,
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
                    child: const Center(child: Text('L&L',
                        style: TextStyle(fontFamily: 'Urbanist', color: Colors.white,
                            fontWeight: FontWeight.w900, fontSize: 11))),
                  ),
                  const SizedBox(width: 10),
                  const Text('CAFE',
                      style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                          fontSize: 18, color: Color(0xFF2D2A26))),
                ]),
                const Spacer(),
                Wrap(spacing: 36, children: [
                  'Privacy Policy', 'Terms of Service', 'Architectural Support'
                ].map((l) => Text(l.toUpperCase(),
                    style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                        fontSize: 10, letterSpacing: 3, color: AppColors.primary)))
                    .toList()),
              ]);
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE
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
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 10, letterSpacing: 1, color: AppColors.secondary)),
        const SizedBox(height: 16),
        ...links.map((l) => Padding(
          padding: const EdgeInsets.only(bottom: 13),
          child: Text(l.toUpperCase(),
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                  fontSize: 10, color: AppColors.primary)),
        )),
      ],
    );
  }
}