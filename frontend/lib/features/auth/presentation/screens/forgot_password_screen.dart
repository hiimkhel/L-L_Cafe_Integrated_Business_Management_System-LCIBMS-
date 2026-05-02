import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:frontend/core/widgets/bamboo_background.dart';

const double _kMobile  = 700;
const Color _bgBeige   = Color(0xFFEFE2C9);
const Color _bgDark    = Color(0xFF2D2A26);
const Color _primary   = Color(0xFF758C6D);
const Color _secondary = Color(0xFFA98258);

// ─────────────────────────────────────────────────────────────────────────────
// FORGOT PASSWORD SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

  bool _isLoading = false;
  bool _sent      = false;
  String _error   = '';

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _sendResetLink() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    setState(() { _error = ''; _isLoading = true; });

    try {
      await firebase_auth.FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);
      setState(() => _sent = true);
    } on firebase_auth.FirebaseAuthException catch (e) {
      setState(() =>
        _error = e.message ?? 'Something went wrong. Please try again.');
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _backToLogin() => Navigator.pop(context);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBeige,
      body: Stack(
        children: [
          const BambooBackground(),
          LayoutBuilder(builder: (context, c) {
            final isMobile = c.maxWidth < _kMobile;
            return isMobile ? _buildMobile() : _buildDesktop();
          }),
        ],
      ),
    );
  }

  // ── Desktop: small centered card ─────────────────────────────────────────

  Widget _buildDesktop() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Container(
          width: 340,
          padding: const EdgeInsets.fromLTRB(32, 36, 32, 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 40, offset: Offset(0, 16)),
            ],
          ),
          child: _buildContent(isMobile: false),
        ),
      ),
    );
  }

  // ── Mobile: slightly wider centered card on beige ─────────────────────────

  Widget _buildMobile() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 30, offset: Offset(0, 10)),
            ],
          ),
          child: _buildContent(isMobile: true),
        ),
      ),
    );
  }

  // ── Shared card content ───────────────────────────────────────────────────

  Widget _buildContent({required bool isMobile}) {
    if (_sent) return _buildSuccessContent();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon badge
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: _secondary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
              color: _secondary.withOpacity(0.35),
              blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: const Icon(Icons.sync_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 20),

        // Title
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(children: [
            TextSpan(text: 'ACCOUNT ',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 22, color: _bgDark)),
            TextSpan(text: 'RECOVERY',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 22, color: _primary)),
          ]),
        ),
        const SizedBox(height: 6),
        Text('ARCHITECTING YOUR PATH BACK',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
            fontSize: 9, letterSpacing: 2.0, color: _secondary.withOpacity(0.7))),
        const SizedBox(height: 28),

        // Email field
        Align(
          alignment: Alignment.centerLeft,
          child: Text('REGISTERED EMAIL',
            style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
              fontSize: 9, letterSpacing: 1.5, color: _bgDark)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
            fontSize: 12, color: _bgDark),
          decoration: InputDecoration(
            hintText: 'ENTER SIGNAL ADDRESS...',
            hintStyle: TextStyle(fontFamily: 'Urbanist', fontSize: 11,
              color: _bgDark.withOpacity(0.28)),
            filled: true,
            fillColor: const Color(0xFFFAF7F3),
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
        ),
        const SizedBox(height: 14),

        // Hint box (mobile wireframe shows info note)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _bgBeige,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "ENTER THE EMAIL YOU USED TO REGISTER. WE'LL SEND YOU A SECURE LINK TO RESET YOUR PASSWORD.",
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
              fontSize: 9, letterSpacing: 0.8, height: 1.8,
              color: _secondary.withOpacity(0.8)),
          ),
        ),

        // Error
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Text(_error, style: const TextStyle(fontFamily: 'Urbanist',
              fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],

        const SizedBox(height: 24),

        // Send button
        GestureDetector(
          onTap: _isLoading ? null : _sendResetLink,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _isLoading ? _primary.withOpacity(0.6) : _primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: const Color(0xFF2D2A26).withOpacity(0.4),
                  offset: const Offset(3, 3)),
              ],
            ),
            child: _isLoading
              ? const Center(child: SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
              : const Text('SEND RESET LINK', textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 13, letterSpacing: 2.5, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 20),

        // Back to login
        GestureDetector(
          onTap: _backToLogin,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.arrow_back_rounded, size: 14, color: _secondary.withOpacity(0.7)),
            const SizedBox(width: 6),
            Text('BACK TO LOGIN TERMINAL',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                fontSize: 10, letterSpacing: 1.0, color: _secondary.withOpacity(0.7))),
          ]),
        ),
      ],
    );
  }

  // ── Success state ─────────────────────────────────────────────────────────

  Widget _buildSuccessContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_outlined, color: _primary, size: 32),
        ),
        const SizedBox(height: 20),
        const Text('RESET LINK SENT',
          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
            fontSize: 20, color: _bgDark)),
        const SizedBox(height: 10),
        Text(
          'A password reset link has been transmitted to your signal address. Check your inbox and follow the instructions.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w500,
            fontSize: 12, height: 1.7, color: _bgDark.withOpacity(0.6)),
        ),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: _backToLogin,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: const Color(0xFF2D2A26).withOpacity(0.4),
                offset: const Offset(3, 3))],
            ),
            child: const Text('BACK TO LOGIN TERMINAL', textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 12, letterSpacing: 2.0, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
