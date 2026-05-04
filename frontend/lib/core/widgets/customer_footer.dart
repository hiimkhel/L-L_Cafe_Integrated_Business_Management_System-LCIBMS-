import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
        return isMobile ? const _GuestFooterMobile() : const _GuestFooterDesktop();
      }),
    );
  }
}

// ── Desktop ──────────────────────────────────────────────────────────────────

class _GuestFooterDesktop extends StatelessWidget {
  const _GuestFooterDesktop();

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
              // ── Brand block ─────────────────────────────────────────────
              SizedBox(
                width: 240,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      // ✅ Actual logo image
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('L&L CAFE',
                              style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: Color(0xFF2D2A26))),
                          Text('ESTABLISHED 2020',
                              style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                  letterSpacing: 2,
                                  color: AppColors.primary.withOpacity(0.5))),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Text(
                      'Making good food for people\'s happiness.\nCrafted with love in every cup and plate.',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          letterSpacing: 0.3,
                          height: 1.9,
                          color: AppColors.primary.withOpacity(0.65)),
                    ),
                    const SizedBox(height: 20),
                    // ✅ Facebook only
                    _SocialChip(
                      label: 'Follow us on Facebook',
                      icon: Icons.facebook_rounded,
                      url: 'https://www.facebook.com/LLcafeilo',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Link columns ─────────────────────────────────────────────
              const _FooterCol(
                title: 'EXPLORE',
                links: [
                  _FooterLink('Menu',       null),
                  _FooterLink('About Us',   null),
                  _FooterLink('Contact',    null),
                ],
              ),
              const SizedBox(width: 64),
              const _FooterCol(
                title: 'VISIT US',
                links: [
                  _FooterLink('Open Daily',        null),
                  _FooterLink('Free Wifi',          null),
                  _FooterLink('Cozy Atmosphere',    null),
                  _FooterLink('Made with Love',     null),
                ],
              ),
            ],
          ),

          const SizedBox(height: 48),

          // ── Copyright ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                Text(
                  '© 2026 L&L CAFE. ALL RIGHTS RESERVED.',
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 2,
                      color: AppColors.primary.withOpacity(0.5)),
                ),
                const Spacer(),
                Text(
                  'MAKING GOOD FOOD FOR PEOPLE\'S HAPPINESS',
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                      letterSpacing: 3,
                      color: AppColors.secondary.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile ────────────────────────────────────────────────────────────────────

class _GuestFooterMobile extends StatelessWidget {
  const _GuestFooterMobile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Actual logo image
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/lnl.jpg',
                width: 44, height: 44, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
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
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('L&L CAFE',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFF2D2A26))),
                Text('ESTABLISHED 2020',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                        fontSize: 8,
                        letterSpacing: 1.5,
                        color: AppColors.primary.withOpacity(0.5))),
              ],
            ),
          ]),

          const SizedBox(height: 12),

          Text(
            'Making good food for people\'s happiness.',
            style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w500,
                fontSize: 11,
                height: 1.7,
                color: AppColors.primary.withOpacity(0.65)),
          ),

          const SizedBox(height: 16),

          // ✅ Facebook chip
          _SocialChip(
            label: 'Follow us on Facebook',
            icon: Icons.facebook_rounded,
            url: 'https://www.facebook.com/LLcafeilo',
          ),

          const SizedBox(height: 32),

          // Link columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(child: _FooterCol(
                title: 'EXPLORE',
                links: [
                  _FooterLink('Menu',     null),
                  _FooterLink('About Us', null),
                  _FooterLink('Contact',  null),
                ],
              )),
              Expanded(child: _FooterCol(
                title: 'VISIT US',
                links: [
                  _FooterLink('Open Daily',     null),
                  _FooterLink('Free Wifi',       null),
                  _FooterLink('Made with Love',  null),
                ],
              )),
            ],
          ),

          const SizedBox(height: 24),

          // Copyright
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.1))),
            ),
            child: Center(
              child: Text(
                '© 2026 L&L CAFE. ALL RIGHTS RESERVED.',
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                    letterSpacing: 1.5,
                    color: AppColors.primary.withOpacity(0.45)),
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
        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      ),
      child: LayoutBuilder(builder: (_, c) {
        final isMobile = c.maxWidth < _kMobile;
        return isMobile
            ? _buildMobile(context)
            : _buildDesktop(context);
      }),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ Actual logo image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/lnl.jpg',
              width: 40, height: 40, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF2D2A26),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: const Center(
                  child: Text('L&L',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 10)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('L&L CAFE',
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: Color(0xFF2D2A26))),
              Text('MAKING GOOD FOOD FOR PEOPLE\'S \nHAPPINESS',
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                      fontSize: 8,
                      letterSpacing: 1.5,
                      color: AppColors.primary.withOpacity(0.5))),
            ],
          ),

          const Spacer(),

          // Center: copyright
          Text(
            '© 2026 L&L CAFE. ALL RIGHTS RESERVED.',
            style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
                fontSize: 9,
                letterSpacing: 1.5,
                color: AppColors.primary.withOpacity(0.4)),
          ),

          const Spacer(),

          // Right: Facebook only
          _SocialChip(
            label: 'Facebook',
            icon: Icons.facebook_rounded,
            url: 'https://www.facebook.com/LLcafeilo',
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          // Logo + name
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/lnl.jpg',
                width: 36, height: 36, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2A26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('L&L',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 9)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('L&L CAFE',
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Color(0xFF2D2A26))),
          ]),
          const SizedBox(height: 12),
          _SocialChip(
            label: 'Follow us on Facebook',
            icon: Icons.facebook_rounded,
            url: 'https://www.facebook.com/LLcafeilo',
          ),
          const SizedBox(height: 12),
          Text(
            '© 2026 L&L CAFE. ALL RIGHTS RESERVED.',
            style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 8,
                letterSpacing: 1,
                color: AppColors.primary.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Clickable Facebook chip that opens the URL
class _SocialChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String url;
  final bool compact;

  const _SocialChip({
    required this.label,
    required this.icon,
    required this.url,
    this.compact = false,
  });

  Future<void> _launch() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launch,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
          vertical: compact ? 7 : 9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1877F2).withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1877F2).withOpacity(0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: compact ? 16 : 18, color: const Color(0xFF1877F2)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
                fontSize: compact ? 10 : 11,
                color: const Color(0xFF1877F2)),
          ),
        ]),
      ),
    );
  }
}

class _FooterLink {
  final String label;
  final String? url;
  const _FooterLink(this.label, this.url);
}

class _FooterCol extends StatelessWidget {
  final String title;
  final List<_FooterLink> links;
  const _FooterCol({required this.title, required this.links});

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
                letterSpacing: 1.5,
                color: AppColors.secondary)),
        const SizedBox(height: 14),
        ...links.map((l) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: l.url != null
                  ? GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse(l.url!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: _linkText(l.label),
                    )
                  : _linkText(l.label),
            )),
      ],
    );
  }

  Widget _linkText(String label) => Text(
        label.toUpperCase(),
        style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
            fontSize: 10,
            color: AppColors.primary.withOpacity(0.7)),
      );
}