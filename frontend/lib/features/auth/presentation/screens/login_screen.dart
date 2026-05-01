import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/core/models/user.dart';
import 'package:frontend/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:frontend/features/auth/presentation/screens/register_screen.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/widgets/bamboo_background.dart';


const double _kMobile  = 700;
const Color _bgBeige   = Color(0xFFEFE2C9);
const Color _bgDark    = Color(0xFF2D2A26);
const Color _primary   = Color(0xFF758C6D);
const Color _secondary = Color(0xFFA98258);

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

  String error   = '';
  bool isLoading = false;
  bool _obscure  = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

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

  void _goForgotPassword() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));

  void _goRegister() => Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => RegisterScreen(onRegister: widget.onLogin)));

  // ✅ Back to landing — pop since landing pushed us here
  void _goBack() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBeige,
      body: Stack(
        children: [
          const BambooBackground(),
          LayoutBuilder(builder: (context, c) {
            final isMobile = c.maxWidth < _kMobile;
            return isMobile ? _buildMobile(context) : _buildDesktop();
          }),
        ],
      ),
    );
  }

  // ── Desktop ───────────────────────────────────────────────────────────────

  Widget _buildDesktop() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 40, offset: Offset(0, 16)),
            ],
          ),
          child: Column(
            children: [
              // ── Back button ──────────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _goBack,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: _secondary),
                      SizedBox(width: 4),
                      Text('BACK',
                        style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                          fontSize: 10, letterSpacing: 1.5, color: _secondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFormContent(isMobile: false),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mobile ────────────────────────────────────────────────────────────────

  Widget _buildMobile(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    const headerH = 252.0;
    final bodyMinH = screenH - headerH;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Green header ─────────────────────────────────────────────────
          Container(
            color: _primary,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Back button ────────────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: _goBack,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.arrow_back_ios_new_rounded,
                            size: 13, color: Colors.white70),
                        SizedBox(width: 4),
                        Text('BACK',
                          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                            fontSize: 10, letterSpacing: 1.5, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/lnl.jpg',
                    width: 64, height: 64, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
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

          // ── White body ───────────────────────────────────────────────────
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: bodyMinH),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: _buildFormContent(isMobile: true),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared form content ───────────────────────────────────────────────────

  Widget _buildFormContent({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isMobile) ...[
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(16)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/images/lnl.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                      child: Text('L&L', style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)))),
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

        _buildLabel('EMAIL / USERNAME'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _emailCtrl,
          hint: 'ENTER YOUR DETAILS...',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

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
        const SizedBox(height: 10),

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

        _buildPrimaryButton(
          label: isMobile ? 'LOGIN' : 'INITIALIZE LOGIN',
          onTap: isLoading ? null : _login,
          isLoading: isLoading,
        ),
        const SizedBox(height: 20),

        _buildDivider('OR CONTINUE WITH'),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _buildSocialBtn(
                label: 'GOOGLE', icon: _GoogleIcon(),
                onTap: isLoading ? null : _googleLogin)),
            const SizedBox(width: 12),
            Expanded(child: _buildSocialBtn(
                label: 'FACEBOOK',
                icon: const Icon(Icons.facebook_rounded, color: Color(0xFF1877F2), size: 20),
                onTap: isLoading ? null : _facebookLogin)),
          ],
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('NEW HERE?  ',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                    fontSize: 11, color: _secondary.withOpacity(0.7))),
            GestureDetector(
              onTap: _goRegister,
              child: const Text('CREATE ACCOUNT',
                  style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                      fontSize: 11, letterSpacing: 1.0, color: _secondary)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                fontSize: 9, letterSpacing: 1.5, color: _bgDark)),
      );

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
            ? Padding(padding: const EdgeInsets.only(right: 12), child: suffixIcon)
            : null,
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

  Widget _buildDivider(String label) => Row(children: [
        Expanded(child: Divider(color: _secondary.withOpacity(0.2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                  fontSize: 9, letterSpacing: 1.5, color: _secondary.withOpacity(0.6))),
        ),
        Expanded(child: Divider(color: _secondary.withOpacity(0.2))),
      ]);

  Widget _buildSocialBtn({
    required String label, required Widget icon, VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _secondary.withOpacity(0.2), width: 1),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon, const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700, fontSize: 11,
                letterSpacing: 1.0, color: _bgDark)),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 20, height: 20, child: CustomPaint(painter: _GooglePainter()));
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    const colors = [Color(0xFF4285F4), Color(0xFF34A853), Color(0xFFFBBC05), Color(0xFFEA4335)];
    double start = -90.0;
    for (int i = 0; i < 4; i++) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r - 1.75),
        start * math.pi / 180, 90 * math.pi / 180, false,
        Paint()..color = colors[i]..strokeWidth = 3.5
          ..style = PaintingStyle.stroke..strokeCap = StrokeCap.butt);
      start += 90;
    }
    canvas.drawCircle(c, r - 4, Paint()..color = Colors.white);
  }
  @override
  bool shouldRepaint(_) => false;
}