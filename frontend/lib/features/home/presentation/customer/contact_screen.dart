import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl, LaunchMode;
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/widgets/bamboo_breeze_background.dart';
import 'package:frontend/core/constants/cart_provider.dart';

const double _kMobile = 900;
const double _kDesktopMaxWidth = 1280;

const double _kLat = 10.8228406;
const double _kLng = 122.4315635;
const String _kAddress = 'RCFJ+4JP, Cabaluna Street, Alimodian, 5028 Iloilo';
const String _kPhone   = '+63 998 308 7848';
const String _kEmail   = 'kitquintano777@gmail.com';

const Color _bgBeige   = Color(0xFFEFE2C9);
const Color _bgDark    = Color(0xFF2D2A26);
const Color _primary   = Color(0xFF758C6D);
const Color _secondary = Color(0xFFA98258);

// ─────────────────────────────────────────────────────────────────────────────
// CONTACT SCREEN
// isGuest=true  → GuestNavbar  (landing/guest flow)
// isGuest=false → CustomerNavbar (logged-in flow)
// ─────────────────────────────────────────────────────────────────────────────

class ContactScreen extends StatefulWidget {
  final bool isGuest;
  final VoidCallback? onLogin;
  final VoidCallback? onJoinNow;
  final VoidCallback? onLogout;

  const ContactScreen({
    super.key,
    this.isGuest = true,
    this.onLogin,
    this.onJoinNow,
    this.onLogout,
  });

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _sending = false;
  bool _sent    = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _sending = false; _sent = true; });
    _nameCtrl.clear(); _emailCtrl.clear();
    _subjectCtrl.clear(); _messageCtrl.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('MESSAGE SENT SUCCESSFULLY',
            style: TextStyle(fontFamily: 'Urbanist',
                fontWeight: FontWeight.w800, letterSpacing: 1)),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _sent = false);
  }

  Future<void> _openMap() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=$_kLat,$_kLng'
      '&query_place_id=ChIJQZMxVADv_zMR2em3UCpL8tM',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      final fallback = Uri.parse('https://maps.google.com/?q=$_kLat,$_kLng');
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.isGuest ? null : CartProvider.of(context);

    final PreferredSizeWidget navbar = widget.isGuest
        ? GuestNavbar(
            activeRoute: '/contact',
            onLogin: widget.onLogin,
            onJoinNow: widget.onJoinNow,
            onBrowseMenu: () => Navigator.pushReplacementNamed(context, '/menu'),
          )
        : CustomerNavbar(
            activeRoute: '/contact',
            cartCount: cart?.totalCount ?? 0,
            notifCount: 0,
            isGuest: false,
            onProfile: () => Navigator.pushReplacementNamed(context, '/profile'),
            onLogout: () {
              widget.onLogout?.call();
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < _kMobile;
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: _kDesktopMaxWidth),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 20 : 64,
                                    vertical:   isMobile ? 32 : 48,
                                  ),
                                  child: isMobile
                                      ? _buildMobileLayout()
                                      : _buildDesktopLayout(),
                                ),
                              ),
                            ),
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

  // ── Desktop ───────────────────────────────────────────────────────────────

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageTitle(),
        const SizedBox(height: 8),
        const Text(
          "MAKING GOOD FOOD FOR PEOPLE'S HAPPINESS",
          style: TextStyle(
            fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
            fontSize: 11, letterSpacing: 3.0, color: _secondary,
          ),
        ),
        const SizedBox(height: 52),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildSectionHeader('CONTACT FORM'),
                const SizedBox(height: 20),
                _buildContactForm(isMobile: false),
              ]),
            ),
            const SizedBox(width: 64),
            Expanded(
              flex: 5,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildSectionHeader('L&L LOCATION'),
                const SizedBox(height: 20),
                _buildLocationCard(),
                const SizedBox(height: 20),
                _buildMapCard(),
                const SizedBox(height: 20),
                _buildHoursCard(),
              ]),
            ),
          ],
        ),
      ],
    );
  }

  // ── Mobile ────────────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageTitle(),
        const SizedBox(height: 6),
        const Text(
          "MAKING GOOD FOOD FOR PEOPLE'S HAPPINESS",
          style: TextStyle(
            fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
            fontSize: 10, letterSpacing: 2.5, color: _secondary,
          ),
        ),
        const SizedBox(height: 36),
        _buildSectionHeader('CONTACT FORM'),
        const SizedBox(height: 16),
        _buildContactForm(isMobile: true),
        const SizedBox(height: 36),
        _buildSectionHeader('L&L LOCATION'),
        const SizedBox(height: 16),
        _buildLocationCard(),
        const SizedBox(height: 16),
        _buildMapCard(),
        const SizedBox(height: 16),
        _buildHoursCard(),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────

  Widget _buildPageTitle() {
    return RichText(
      text: const TextSpan(children: [
        TextSpan(
          text: 'L&L ',
          style: TextStyle(
            fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
            fontSize: 42, letterSpacing: -1.5, color: _bgDark,
          ),
        ),
        TextSpan(
          text: 'COMMUNICATIONS',
          style: TextStyle(
            fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
            fontSize: 42, letterSpacing: -1.5, color: _primary,
          ),
        ),
      ]),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(children: [
      Container(
        width: 4, height: 22,
        decoration: BoxDecoration(
            color: _secondary, borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 12),
      Text(title,
          style: const TextStyle(
            fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
            fontSize: 15, letterSpacing: 2.0, color: _bgDark,
            fontStyle: FontStyle.italic,
          )),
    ]);
  }

  // ── Contact Form ──────────────────────────────────────────────────────────

  Widget _buildContactForm({required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: _bgDark.withOpacity(0.07),
              blurRadius: 30, offset: const Offset(0, 8)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'HAVE QUESTIONS, FEEDBACK, OR WANT TO BOOK A GROUP ORDER?\n'
            'FILL OUT THE FORM BELOW AND WE\'LL GET BACK TO YOU AS SOON AS POSSIBLE!',
            style: TextStyle(
              fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
              fontSize: 10, letterSpacing: 1.2, height: 2.0, color: _secondary,
            ),
          ),
          const SizedBox(height: 24),
          if (!isMobile)
            Row(children: [
              Expanded(child: _buildField('NAME', _nameCtrl, 'Full Name...')),
              const SizedBox(width: 16),
              Expanded(child: _buildField('EMAIL ADDRESS', _emailCtrl,
                  'email@domain.com', isEmail: true)),
            ])
          else ...[
            _buildField('NAME', _nameCtrl, 'Full Name...'),
            const SizedBox(height: 16),
            _buildField('EMAIL ADDRESS', _emailCtrl,
                'email@domain.com', isEmail: true),
          ],
          const SizedBox(height: 16),
          _buildField('SUBJECT', _subjectCtrl, ''),
          const SizedBox(height: 16),
          _buildField('MESSAGE SPECIFICATION', _messageCtrl,
              'Describe your request...', maxLines: 5),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _sending ? null : _sendMessage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: _sent ? _primary.withOpacity(0.7) : _primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: _sending
                  ? const Center(child: SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5)))
                  : Text(
                      _sent ? 'MESSAGE SENT ✓' : 'SEND MESSAGE',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                        fontSize: 13, letterSpacing: 2.5, color: Colors.white,
                      ),
                    ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint,
      {bool isEmail = false, int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
            fontFamily: 'Urbanist', fontWeight: FontWeight.w800,
            fontSize: 9, letterSpacing: 1.5, color: _secondary,
          )),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: const TextStyle(
          fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
          fontSize: 13, color: _bgDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'Urbanist', fontSize: 12,
              color: _bgDark.withOpacity(0.3)),
          filled: true,
          fillColor: const Color(0xFFF8F5F0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _secondary.withOpacity(0.15), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'This field is required';
          if (isEmail && !v.contains('@')) return 'Enter a valid email';
          return null;
        },
      ),
    ]);
  }

  // ── Location Card ─────────────────────────────────────────────────────────

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _bgDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _bgDark.withOpacity(0.25),
            blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        _buildLocationRow(Icons.location_on_outlined, 'MAIN BRANCH', _kAddress),
        const SizedBox(height: 16),
        Divider(color: Colors.white.withOpacity(0.08), height: 1),
        const SizedBox(height: 16),
        _buildLocationRow(Icons.phone_outlined, 'CONTACT LINE', _kPhone),
        const SizedBox(height: 16),
        Divider(color: Colors.white.withOpacity(0.08), height: 1),
        const SizedBox(height: 16),
        _buildLocationRow(Icons.email_outlined, 'EMAIL ADDRESS', _kEmail),
      ]),
    );
  }

  Widget _buildLocationRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: _primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _primary, size: 18),
      ),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                fontSize: 9, letterSpacing: 1.5,
                color: Colors.white.withOpacity(0.4))),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontFamily: 'Urbanist',
                fontWeight: FontWeight.w800, fontSize: 13,
                color: Colors.white, letterSpacing: 0.3)),
      ])),
    ]);
  }

  // ── Map Card ──────────────────────────────────────────────────────────────

  Widget _buildMapCard() {
    return GestureDetector(
      onTap: _openMap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: _bgBeige.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _secondary.withOpacity(0.2), width: 1),
          boxShadow: [BoxShadow(color: _bgDark.withOpacity(0.06),
              blurRadius: 20, offset: const Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          Image.network(
            _buildStaticMapUrl(),
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return _mapPlaceholder();
            },
            errorBuilder: (_, __, ___) => _mapPlaceholder(),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
              ),
            ),
          ),
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _primary, shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.3), blurRadius: 8)],
                ),
                child: const Icon(Icons.location_on, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 4),
              Container(width: 2, height: 8, color: _primary),
            ]),
          ),
          Positioned(
            bottom: 12, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.open_in_new_rounded, size: 12, color: _primary),
                  const SizedBox(width: 6),
                  Text('INTERACTIVE SITE MAP',
                      style: TextStyle(fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w900, fontSize: 9,
                          letterSpacing: 1.5, color: _secondary)),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  String _buildStaticMapUrl() {
    const zoom = 16;
    final latRad = _kLat * math.pi / 180;
    final n = math.pow(2, zoom);
    final xTile = ((_kLng + 180) / 360 * n).floor();
    final yTile = ((1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) /
            math.pi) /
        2 *
        n).floor();
    return 'https://tile.openstreetmap.org/$zoom/$xTile/$yTile.png';
  }

  Widget _mapPlaceholder() {
    return Container(
      color: _bgBeige,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.location_on_outlined, size: 40,
            color: _secondary.withOpacity(0.4)),
        const SizedBox(height: 8),
        Text('INTERACTIVE SITE MAP',
            style: TextStyle(fontFamily: 'Urbanist',
                fontWeight: FontWeight.w800, fontSize: 10,
                letterSpacing: 2.0, color: _secondary.withOpacity(0.6))),
      ]),
    );
  }

  // ── Hours Card ────────────────────────────────────────────────────────────

  Widget _buildHoursCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _bgDark.withOpacity(0.06),
            blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.access_time_rounded, size: 20, color: _secondary),
          const SizedBox(width: 10),
          const Text('OPERATIONAL HOURS',
              style: TextStyle(fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w900, fontSize: 14,
                  letterSpacing: 1.5, color: _bgDark)),
        ]),
        const SizedBox(height: 20),
        _buildHoursRow('MONDAY – SUNDAY', '08:00 – 22:00'),
      ]),
    );
  }

  Widget _buildHoursRow(String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day,
            style: const TextStyle(fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700, fontSize: 11,
                letterSpacing: 1.0, color: _secondary)),
        Text(hours,
            style: const TextStyle(fontFamily: 'Urbanist',
                fontWeight: FontWeight.w900, fontSize: 13,
                letterSpacing: 0.5, color: _bgDark)),
      ],
    );
  }
}