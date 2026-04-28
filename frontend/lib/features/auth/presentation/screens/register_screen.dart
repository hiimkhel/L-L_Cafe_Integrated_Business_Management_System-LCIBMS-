import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/core/models/user.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';

const double _kMobile  = 700;
const Color _bgBeige   = Color(0xFFEFE2C9);
const Color _bgDark    = Color(0xFF2D2A26);
const Color _primary   = Color(0xFF758C6D);
const Color _secondary = Color(0xFFA98258);

class RegisterScreen extends StatefulWidget {
  final Function(User) onRegister;
  const RegisterScreen({super.key, required this.onRegister});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl     = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _authService  = AuthService();

  String error       = '';
  bool isLoading     = false;
  bool _obscurePass  = true;
  bool _obscureConf  = true;
  bool _agreedTerms  = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _usernameCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _register() async {
    final name     = _nameCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();
    final confirm  = _confirmCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => error = 'All fields are required');
      return;
    }
    if (password != confirm) {
      setState(() => error = 'Passwords do not match');
      return;
    }
    if (!_agreedTerms) {
      setState(() => error = 'Please agree to the Terms and Conditions');
      return;
    }

    setState(() { error = ''; isLoading = true; });
    try {
      final user = await _authService.register(name, email, password);
      widget.onRegister(user);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _googleRegister() async {
    setState(() { error = ''; isLoading = true; });
    try {
      final user = await _authService.signInWithGoogle();
      widget.onRegister(user);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _facebookRegister() async {
    setState(() { error = ''; isLoading = true; });
    try {
      final user = await _authService.signInWithFacebook();
      widget.onRegister(user);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _goLogin() {
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => LoginScreen(onLogin: widget.onRegister)));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBeige,
      body: Stack(
        children: [
          const Positioned.fill(child: _BambooBackground()),
          LayoutBuilder(builder: (context, c) {
            final isMobile = c.maxWidth < _kMobile;
            return isMobile ? _buildMobile() : _buildDesktop();
          }),
        ],
      ),
    );
  }

  // ── Desktop: centered white card ──────────────────────────────────────────

  Widget _buildDesktop() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Container(
          width: 480,
          padding: const EdgeInsets.fromLTRB(36, 36, 36, 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 40, offset: Offset(0, 16)),
            ],
          ),
          child: Column(
            children: [
              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset('assets/images/lnl.jpg',
                  width: 56, height: 56, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Text('L&L',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11))),
                  )),
              ),
              const SizedBox(height: 16),
              const Text('REGISTRATION',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                  fontSize: 24, letterSpacing: -0.5, color: _bgDark)),
              const SizedBox(height: 6),
              Text('CREATE YOUR ACCOUNT TO START ORDERING',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                  fontSize: 9, letterSpacing: 2.0, color: _secondary.withOpacity(0.7))),
              const SizedBox(height: 28),

              // 2-column grid of fields
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _buildFieldCol('FULL NAME', _nameCtrl, 'ENTER FULL NAME...')),
                const SizedBox(width: 16),
                Expanded(child: _buildFieldCol('USERNAME', _usernameCtrl, 'CHOOSE USERNAME...')),
              ]),
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _buildFieldCol('EMAIL ADDRESS', _emailCtrl, 'EMAIL@DOMAIN.COM',
                  keyboardType: TextInputType.emailAddress)),
                const SizedBox(width: 16),
                Expanded(child: _buildFieldCol('PHONE NUMBER', _phoneCtrl, '+63 000-0000',
                  keyboardType: TextInputType.phone)),
              ]),
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _buildFieldCol('PASSWORD', _passCtrl, '••••••••',
                  obscure: _obscurePass,
                  onToggleObscure: () => setState(() => _obscurePass = !_obscurePass))),
                const SizedBox(width: 16),
                Expanded(child: _buildFieldCol('CONFIRM PASSWORD', _confirmCtrl, '••••••••',
                  obscure: _obscureConf,
                  onToggleObscure: () => setState(() => _obscureConf = !_obscureConf))),
              ]),
              const SizedBox(height: 20),

              _buildTermsRow(),
              const SizedBox(height: 20),

              if (error.isNotEmpty) ...[
                _buildError(),
                const SizedBox(height: 14),
              ],

              _buildPrimaryButton(
                label: 'REGISTER NOW',
                icon: Icons.storefront_outlined,
                onTap: isLoading ? null : _register,
                isLoading: isLoading,
              ),
              const SizedBox(height: 20),

              // Back to login
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('ALREADY HAVE AN ACCOUNT?  ',
                  style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                    fontSize: 11, color: _secondary.withOpacity(0.7))),
                GestureDetector(
                  onTap: _goLogin,
                  child: const Text('BACK TO LOGIN',
                    style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                      fontSize: 11, letterSpacing: 1.0, color: _secondary)),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mobile: green header + white body, fields stacked ────────────────────

  Widget _buildMobile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Green header block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
            color: _primary,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset('assets/images/lnl.jpg',
                    width: 64, height: 64, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18)),
                      child: const Center(child: Text('L&L',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14))),
                    )),
                ),
                const SizedBox(height: 16),
                const Text('JOIN US',
                  style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 26, color: Colors.white, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text('CREATE YOUR ACCOUNT',
                  style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                    fontSize: 11, letterSpacing: 2.5, color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),

          // White body
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldCol('FULL NAME', _nameCtrl, 'ENTER FULL NAME...'),
                const SizedBox(height: 16),
                _buildFieldCol('USERNAME', _usernameCtrl, 'CHOOSE USERNAME...'),
                const SizedBox(height: 16),
                _buildFieldCol('EMAIL ADDRESS', _emailCtrl, 'EMAIL@DOMAIN.COM',
                  keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildFieldCol('PHONE NUMBER', _phoneCtrl, '+63 000-0000',
                  keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildFieldCol('PASSWORD', _passCtrl, '••••••••',
                  obscure: _obscurePass,
                  onToggleObscure: () => setState(() => _obscurePass = !_obscurePass)),
                const SizedBox(height: 16),
                _buildFieldCol('CONFIRM PASSWORD', _confirmCtrl, '••••••••',
                  obscure: _obscureConf,
                  onToggleObscure: () => setState(() => _obscureConf = !_obscureConf)),
                const SizedBox(height: 20),

                _buildTermsRow(),
                const SizedBox(height: 20),

                if (error.isNotEmpty) ...[
                  _buildError(),
                  const SizedBox(height: 14),
                ],

                _buildPrimaryButton(
                  label: 'REGISTER NOW',
                  icon: Icons.storefront_outlined,
                  onTap: isLoading ? null : _register,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 24),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('ALREADY HAVE AN ACCOUNT?  ',
                    style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                      fontSize: 11, color: _secondary.withOpacity(0.7))),
                  GestureDetector(
                    onTap: _goLogin,
                    child: const Text('BACK TO LOGIN',
                      style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                        fontSize: 11, letterSpacing: 1.0, color: _secondary)),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _buildFieldCol(
    String label,
    TextEditingController ctrl,
    String hint, {
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
          fontSize: 9, letterSpacing: 1.5, color: _bgDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
            fontSize: 12, color: _bgDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontFamily: 'Urbanist', fontSize: 11,
              color: _bgDark.withOpacity(0.28)),
            filled: true,
            fillColor: const Color(0xFFFAF7F3),
            suffixIcon: onToggleObscure != null
              ? GestureDetector(
                  onTap: onToggleObscure,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 16, color: _secondary.withOpacity(0.5)),
                  ),
                )
              : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _secondary.withOpacity(0.2), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsRow() {
    return GestureDetector(
      onTap: () => setState(() => _agreedTerms = !_agreedTerms),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _bgBeige,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _agreedTerms ? _primary.withOpacity(0.4) : _secondary.withOpacity(0.2)),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 18, height: 18,
            decoration: BoxDecoration(
              color: _agreedTerms ? _primary : Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: _agreedTerms ? _primary : _secondary.withOpacity(0.4)),
            ),
            child: _agreedTerms
              ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('I AGREE TO THE TERMS AND CONDITIONS OF L&L CAFE.',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                fontSize: 10, letterSpacing: 0.5, color: _secondary)),
          ),
        ]),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Text(error, style: const TextStyle(fontFamily: 'Urbanist', fontSize: 11,
        color: Colors.redAccent, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: onTap == null ? _primary.withOpacity(0.6) : _primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: const Color(0xFF2D2A26).withOpacity(0.4),
              offset: const Offset(3, 3)),
          ],
        ),
        child: isLoading
          ? const Center(child: SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 13, letterSpacing: 2.5, color: Colors.white)),
            ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BAMBOO BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────

class _BambooBackground extends StatefulWidget {
  const _BambooBackground();
  @override
  State<_BambooBackground> createState() => _BambooBackgroundState();
}

class _BambooBackgroundState extends State<_BambooBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < _kMobile;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _BambooPainter(animationValue: _ctrl.value, isMobile: isMobile),
        size: Size.infinite,
      ),
    );
  }
}

class _BambooPainter extends CustomPainter {
  final double animationValue;
  final bool isMobile;
  _BambooPainter({required this.animationValue, required this.isMobile});

  static const _bamboos = [
    [0.040, 13.0, 0.12, 1.53], [0.095, 7.0, 0.10, -1.84],
    [0.133, 14.0, 0.13, 1.45], [0.190, 9.0, 0.10, -0.72],
    [0.236, 9.5, 0.10, -0.71], [0.283, 13.0, 0.12, -1.53],
    [0.321, 13.0, 0.11, 1.24], [0.374, 1.9, 0.08, 0.29],
    [0.503, 20.0, 0.13, 2.00], [0.560, 4.1, 0.09, 1.06],
    [0.598, 17.6, 0.12, 1.82], [0.693, 15.5, 0.11, 1.72],
    [0.783, 18.8, 0.12, 1.81], [0.890, 5.2, 0.08, -1.98],
  ];

  void _drawLeaf(Canvas c, Offset o, double angle, double len, double w, Paint p) {
    c.save(); c.translate(o.dx, o.dy); c.rotate(angle);
    final path = Path()..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.4, -w, len, 0)
      ..quadraticBezierTo(len * 0.6, w, 0, 0)..close();
    c.drawPath(path, p); c.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    int index = 0;
    for (final b in _bamboos) {
      index++;
      if (isMobile && index % 3 != 0) continue;
      final baseX = size.width * (b[0] as double);
      final w = b[1] as double;
      final deg = b[3] as double;
      final h = size.height;
      final double baseOp = b[2] as double;
      final op = isMobile ? baseOp * 0.35 : baseOp * 0.8;
      final x = ((baseX + animationValue * size.width * (op * 10)) % size.width);
      final sway = math.sin((animationValue * math.pi * 4) + (x * 0.01)) * 0.015;
      final rad = (deg * math.pi / 180) + sway;
      paint.color = const Color(0xFF758C6D).withOpacity(op);
      canvas.save();
      canvas.translate(x + w / 2, h / 2);
      canvas.rotate(rad);
      canvas.drawRect(Rect.fromLTWH(-w / 2, -h / 2 - 20, w, h + 40), paint);
      int segments = (h / (w * 10 + 60)).ceil().clamp(3, 10);
      double segH = (h + 40) / segments;
      for (int i = 1; i < segments; i++) {
        double jY = (-h / 2 - 20) + (i * segH);
        canvas.drawRect(Rect.fromLTWH(-w / 2 - 1.5, jY - 1, w + 3, 2.5), paint);
        if ((index + i) % 4 != 0) {
          bool isLeft = (index + i) % 2 == 0;
          double ll = w * 2.5 + 20.0, lw = ll * 0.25;
          _drawLeaf(canvas, Offset(isLeft ? -w / 2 : w / 2, jY),
            isLeft ? math.pi * 0.8 : math.pi * 0.2, ll, lw, paint);
          if (i % 2 == 0) {
            _drawLeaf(canvas, Offset(isLeft ? -w / 2 : w / 2, jY),
              isLeft ? math.pi * 1.1 : -math.pi * 0.1, ll * 0.8, lw * 0.8, paint);
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
  bool shouldRepaint(covariant _BambooPainter old) =>
    old.animationValue != animationValue || old.isMobile != isMobile;
}