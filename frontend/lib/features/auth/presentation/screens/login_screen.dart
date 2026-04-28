import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/core/models/user.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

const double _kMobile = 700;
const Color _bgBeige  = Color(0xFFEFE2C9);
const Color _bgDark   = Color(0xFF2D2A26);
const Color _primary  = Color(0xFF758C6D);  // green
const Color _secondary = Color(0xFFA98258); // gold/brown

// ─────────────────────────────────────────────────────────────────────────────
// LOGIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  final Function(User) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService  = AuthService();

  String error     = '';
  bool isLoading   = false;
  bool _obscure    = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _login() async {
    setState(() { error = ''; isLoading = true; });
    try {
      final user = await _authService.login(
        _emailCtrl.text.trim(), _passwordCtrl.text.trim());
      widget.onLogin(user);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() { error = ''; isLoading = true; });
    try {
      final user = await _authService.signInWithGoogle();
      widget.onLogin(user);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _facebookLogin() async {
    setState(() { error = ''; isLoading = true; });
    try {
      final user = await _authService.signInWithFacebook();
      widget.onLogin(user);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _goForgotPassword() {
    Navigator.push(context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
  }

  void _goRegister() {
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => RegisterScreen(onRegister: widget.onLogin)));
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

  // ── Desktop: centered card on beige ──────────────────────────────────────

  Widget _buildDesktop() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(32, 36, 32, 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 40, offset: Offset(0, 16)),
            ],
          ),
          child: _buildFormContent(isMobile: false),
        ),
      ),
    );
  }

  // ── Mobile: green header + white body ────────────────────────────────────

  Widget _buildMobile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Green header block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
            decoration: const BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/lnl.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('L&L', style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('WELCOME BACK',
                  style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 26, color: Colors.white, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text('LOGIN TO YOUR ACCOUNT',
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
            child: _buildFormContent(isMobile: true),
          ),
        ],
      ),
    );
  }

  // ── Shared form content ───────────────────────────────────────────────────

  Widget _buildFormContent({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo + Title (desktop only)
        if (!isMobile) ...[
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/lnl.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Text('L&L', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('LOGIN',
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
              fontSize: 26, letterSpacing: -0.5, color: _bgDark)),
          const SizedBox(height: 6),
          Text("MAKING GOOD FOOD FOR PEOPLE'S HAPPINESS",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
              fontSize: 9, letterSpacing: 2.0, color: _secondary.withOpacity(0.8))),
          const SizedBox(height: 28),
        ],

        // Email field
        _buildLabel('EMAIL / USERNAME'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _emailCtrl,
          hint: 'ENTER YOUR DETAILS...',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // Password field
        _buildLabel('PASSWORD'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _passwordCtrl,
          hint: '••••••••',
          obscure: _obscure,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscure = !_obscure),
            child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 18, color: _secondary.withOpacity(0.6)),
          ),
        ),
        const SizedBox(height: 8),

        // Forgot password
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: _goForgotPassword,
            child: const Text('FORGOT PASSWORD?',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                fontSize: 10, letterSpacing: 1.0, color: _secondary)),
          ),
        ),
        const SizedBox(height: 20),

        // Error
        if (error.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Text(error,
              style: const TextStyle(fontFamily: 'Urbanist', fontSize: 11,
                color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 16),
        ],

        // Login button
        _buildPrimaryButton(
          label: isMobile ? 'LOGIN' : 'INITIALIZE LOGIN',
          onTap: isLoading ? null : _login,
          isLoading: isLoading,
        ),
        const SizedBox(height: 24),

        // OR divider
        _buildDivider('OR CONTINUE WITH'),
        const SizedBox(height: 20),

        // Social buttons
        Row(
          children: [
            Expanded(child: _buildSocialBtn(
              label: 'GOOGLE',
              icon: _GoogleIcon(),
              onTap: isLoading ? null : _googleLogin,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildSocialBtn(
              label: 'FACEBOOK',
              icon: const Icon(Icons.facebook_rounded, color: Color(0xFF1877F2), size: 20),
              onTap: isLoading ? null : _facebookLogin,
            )),
          ],
        ),
        const SizedBox(height: 28),

        // Register link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isMobile ? 'NEW HERE?  ' : 'NEW USER?  ',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                fontSize: 11, color: _secondary.withOpacity(0.7))),
            GestureDetector(
              onTap: _goRegister,
              child: Text(isMobile ? 'CREATE ACCOUNT' : 'REGISTER ACCOUNT',
                style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                  fontSize: 11, letterSpacing: 1.0, color: _secondary)),
            ),
          ],
        ),
      ],
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
        style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
          fontSize: 9, letterSpacing: 1.5, color: _bgDark)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
        fontSize: 12, color: _bgDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Urbanist', fontSize: 12,
          color: _bgDark.withOpacity(0.28)),
        filled: true,
        fillColor: const Color(0xFFFAF7F3),
        suffixIcon: suffixIcon != null
          ? Padding(padding: const EdgeInsets.only(right: 12), child: suffixIcon) : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _secondary.withOpacity(0.2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
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
          : Text(label, textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 13, letterSpacing: 2.5, color: Colors.white)),
      ),
    );
  }

  Widget _buildDivider(String label) {
    return Row(children: [
      Expanded(child: Divider(color: _secondary.withOpacity(0.2))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(label, style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
          fontSize: 9, letterSpacing: 1.5, color: _secondary.withOpacity(0.6))),
      ),
      Expanded(child: Divider(color: _secondary.withOpacity(0.2))),
    ]);
  }

  Widget _buildSocialBtn({
    required String label,
    required Widget icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _secondary.withOpacity(0.2), width: 1),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
              fontSize: 11, letterSpacing: 1.0, color: _bgDark)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GOOGLE ICON (colored G)
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20, height: 20,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFF34A853),
      const Color(0xFFFBBC05),
      const Color(0xFFEA4335),
    ];
    final sweeps = [90.0, 90.0, 90.0, 90.0];
    double start = -90.0;
    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r - 1.75),
        start * math.pi / 180,
        sweeps[i] * math.pi / 180,
        false,
        paint,
      );
      start += sweeps[i];
    }
    // White inner circle to make ring
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(c, r - 4, whitePaint);
  }

  @override
  bool shouldRepaint(_) => false;
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