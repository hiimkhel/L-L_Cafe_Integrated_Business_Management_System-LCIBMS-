import 'package:http/http.dart' as http;
import 'dart:core';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/services/customer/profile_service.dart';
import 'package:frontend/core/constants/cart_provider.dart';
import 'package:frontend/core/widgets/bamboo_background.dart';

const double _kMobile = 900;
const double _kDesktopMaxWidth = 1400;

const Color _bgBeige   = Color(0xFFEFE2C9);
const Color _bgDark    = Color(0xFF2D2A26);
const Color _primary   = Color(0xFF758C6D);
const Color _secondary = Color(0xFFA98258);
const Color _crimson   = Color(0xFF9B2335);

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  String fullName;
  String email;
  String? phone;
  final DateTime memberSince;
  final int orderCount;
  final bool isActive;
  final String? profileImageUrl;
  final List<DeliveryAddress> addresses = [];

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.memberSince,
    required this.orderCount,
    required this.isActive,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      memberSince: DateTime.parse(json['created_at']),
      orderCount: 0,
      isActive: true,
      profileImageUrl: json['profile_picture'],
    );
  }

  String get accountAge {
    final now  = DateTime.now();
    final diff = now.difference(memberSince);
    if (diff.inDays < 1)   return 'NEW ACCOUNT';
    if (diff.inDays < 30)  return '${diff.inDays} DAYS';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} MONTHS';
    return '${(diff.inDays / 365).floor()} YEARS';
  }
}

class DeliveryAddress {
  final String label;
  final String address;
  DeliveryAddress({required this.label, required this.address});
}

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String email;
  final VoidCallback? onLogout;

  const ProfileScreen({
    super.key,
    this.onLogout,
    required this.userId,
    required this.email,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel _currentUser;
  bool _isLoading = false;
  bool _allowNotifications = true;

  final _formKey = GlobalKey<FormState>();

  // ✅ All three controllers are now editable and wired to update
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final List<DeliveryAddress> _deliveryAddresses = [];

  @override
  void initState() {
    super.initState();
    _currentUser = UserModel(
      id: widget.userId,
      fullName: '',
      email: widget.email,
      phone: null,
      memberSince: DateTime.now(),
      orderCount: 0,
      isActive: true,
    );
    _fullNameController = TextEditingController();
    _emailController    = TextEditingController();
    _phoneController    = TextEditingController();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ── Fetch ──────────────────────────────────────────────────────────────────
  Future<void> _fetchUserProfile() async {
    if (_currentUser.id.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3006/api/customer/${_currentUser.id}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final user = UserModel.fromJson(data['user']);
        if (data['addresses'] != null) {
          for (var a in data['addresses']) {
            user.addresses.add(DeliveryAddress(
              label:   a['label']        ?? 'NO LABEL',
              address: a['full_address'] ?? '',
            ));
          }
        }
        setState(() {
          _currentUser            = user;
          _fullNameController.text = user.fullName;
          _emailController.text   = user.email;
          _phoneController.text   = user.phone ?? '';
          _deliveryAddresses
            ..clear()
            ..addAll(user.addresses);
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Update ─────────────────────────────────────────────────────────────────
  Future<void> _updateProfile() async {
    // ✅ Validate before submitting
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final result = await ProfileService.updateProfile(
        fullName: _fullNameController.text.trim(),
        phone:    _phoneController.text.trim(),
      );
      setState(() {
        _currentUser.fullName = result['user']['full_name'] ?? _fullNameController.text;
        _currentUser.phone    = result['user']['phone']     ?? _phoneController.text;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('PROFILE UPDATED SUCCESSFULLY',
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w800, letterSpacing: 1)),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Update failed: $e'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: const [
          Icon(Icons.warning_amber_rounded, color: _crimson, size: 24),
          SizedBox(width: 8),
          Text('DELETE ACCOUNT',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 18, color: _bgDark)),
        ]),
        content: const Text(
          'Are you sure you want to permanently delete your account?\n\nThere\'s no going back ☹️',
          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 14, height: 1.5, color: _bgDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, color: _secondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.onLogout != null) widget.onLogout!();
              Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _crimson,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('DELETE PERMANENTLY',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ✅ Fixed: address fields use their own plain validators, not phone validators
  void _showAddAddressDialog() {
    final labelCtrl   = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey     = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ADD NEW DELIVERY SITE',
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 18, color: _bgDark)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Plain required-field validators — no phone regex
              _addressFormField(
                label: 'LABEL (e.g. HOME, OFFICE)',
                controller: labelCtrl,
                icon: Icons.label_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Label is required' : null,
              ),
              const SizedBox(height: 16),
              _addressFormField(
                label: 'COMPLETE ADDRESS',
                controller: addressCtrl,
                icon: Icons.location_on_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, color: _secondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _deliveryAddresses.add(DeliveryAddress(
                    label:   labelCtrl.text.trim().toUpperCase(),
                    address: addressCtrl.text.trim().toUpperCase(),
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('SAVE SITE',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditAddressDialog(int index) {
    final addr        = _deliveryAddresses[index];
    final labelCtrl   = TextEditingController(text: addr.label);
    final addressCtrl = TextEditingController(text: addr.address);
    final formKey     = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('UPDATE DELIVERY SITE',
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 18, color: _bgDark)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _addressFormField(
                label: 'LABEL (e.g. HOME, OFFICE)',
                controller: labelCtrl,
                icon: Icons.label_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Label is required' : null,
              ),
              const SizedBox(height: 16),
              _addressFormField(
                label: 'COMPLETE ADDRESS',
                controller: addressCtrl,
                icon: Icons.location_on_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, color: _secondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _deliveryAddresses[index] = DeliveryAddress(
                    label:   labelCtrl.text.trim().toUpperCase(),
                    address: addressCtrl.text.trim().toUpperCase(),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('UPDATE SITE',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);
    return Scaffold(
      backgroundColor: _bgBeige,
      appBar: CustomerNavbar(
        activeRoute: '/profile',
        cartCount: cart.totalCount,
        notifCount: 1,
        userName: _currentUser.fullName,
        userClientId: 'CLIENT #${_currentUser.id}',
        onLogout: () {
          if (widget.onLogout != null) widget.onLogout!();
          Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
        },
      ),
      body: Stack(
        children: [
          const BambooBackground(),
          LayoutBuilder(builder: (context, constraints) {
            final isMobile = constraints.maxWidth < _kMobile;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _kDesktopMaxWidth),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : 64,
                          vertical:   isMobile ? 32 : 56,
                        ),
                        child: isMobile
                            ? _buildMobileLayout()
                            : _buildDesktopLayout(),
                      ),
                    ),
                  ),
                  const CustomerFooter(),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Layouts ────────────────────────────────────────────────────────────────

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageTitle('ACCOUNT', 'DETAILS'),
        const SizedBox(height: 8),
        const Text("MAKING GOOD FOOD FOR PEOPLE'S HAPPINESS",
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                fontSize: 11, letterSpacing: 3.0, color: _secondary)),
        const SizedBox(height: 48),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 280, child: _buildProfileCard(isMobile: false)),
            const SizedBox(width: 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(Icons.settings_outlined, 'CUSTOMER DETAILS'),
                  const SizedBox(height: 20),
                  _buildCustomerDetailsCard(isMobile: false),
                  const SizedBox(height: 40),
                  _buildSectionHeader(Icons.location_on_outlined, 'SAVED DELIVERY SITES'),
                  const SizedBox(height: 20),
                  _buildDeliveryAddressesDesktop(),
                  const SizedBox(height: 40),
                  _buildSectionHeader(Icons.shield_outlined, 'ADDITIONAL SETTINGS'),
                  const SizedBox(height: 20),
                  _buildAdditionalSettingsCard(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageTitle('ACCOUNT', 'INFORMATION'),
        const SizedBox(height: 32),
        _buildProfileCard(isMobile: true),
        const SizedBox(height: 32),
        _buildSectionHeader(Icons.settings_outlined, 'PERSONAL DETAILS'),
        const SizedBox(height: 16),
        _buildCustomerDetailsCard(isMobile: true),
        const SizedBox(height: 32),
        _buildSectionHeader(Icons.location_on_outlined, 'SAVED DELIVERY SITES'),
        const SizedBox(height: 16),
        _buildDeliveryAddressesMobile(),
        const SizedBox(height: 32),
        _buildSectionHeader(Icons.shield_outlined, 'ADDITIONAL SETTINGS'),
        const SizedBox(height: 16),
        _buildAdditionalSettingsCard(),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Section widgets ────────────────────────────────────────────────────────

  Widget _buildPageTitle(String normal, String highlight) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(text: '$normal ',
            style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 36, letterSpacing: -1.0, color: _bgDark)),
        TextSpan(text: highlight,
            style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 36, letterSpacing: -1.0, color: _primary)),
      ]),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(children: [
      Container(width: 4, height: 22,
          decoration: BoxDecoration(color: _secondary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 12),
      Icon(icon, size: 18, color: _secondary),
      const SizedBox(width: 10),
      Text(title,
          style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
              fontSize: 14, letterSpacing: 2.0, color: _bgDark, fontStyle: FontStyle.italic)),
    ]);
  }

  Widget _buildProfileCard({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: _bgDark.withOpacity(0.08), blurRadius: 40, offset: const Offset(0, 12))],
      ),
      child: Column(children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Positioned(top: 0, right: 0,
                child: Container(width: 40, height: 40,
                    decoration: BoxDecoration(color: _bgBeige, borderRadius: BorderRadius.circular(12)))),
            Container(width: 100, height: 100,
                decoration: BoxDecoration(color: const Color(0xFF3A3A3A), borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.person_rounded, size: 52, color: Color(0xFF888888))),
          ],
        ),
        const SizedBox(height: 20),
        Text(_currentUser.fullName, textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 20, letterSpacing: -0.5, color: _bgDark)),
        const SizedBox(height: 6),
        Text('CLIENT #${_currentUser.id}',
            style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                fontSize: 10, letterSpacing: 1.5, color: _secondary)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem('ORDERS', _currentUser.orderCount.toString()),
            const SizedBox(width: 40),
            _buildStatusItem(),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showDeleteAccountDialog,
            icon: const Icon(Icons.delete_forever_rounded, size: 16, color: Colors.white),
            label: const Text('DELETE ACCOUNT',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 12, letterSpacing: 2.0, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _crimson,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(children: [
      Text(label,
          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
              fontSize: 9, letterSpacing: 1.5, color: _bgDark.withOpacity(0.5))),
      const SizedBox(height: 2),
      Text(value,
          style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
              fontSize: 22, letterSpacing: -0.5, color: _bgDark)),
    ]);
  }

  Widget _buildStatusItem() {
    return Column(children: [
      Text('STATUS',
          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
              fontSize: 9, letterSpacing: 1.5, color: _bgDark.withOpacity(0.5))),
      const SizedBox(height: 2),
      Row(children: [
        Container(width: 8, height: 8,
            decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        const Text('Active',
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 16, color: _primary)),
      ]),
    ]);
  }

  // ── Customer details card ─────────────────────────────────────────────────
  // ✅ Full name is now editable on BOTH mobile and desktop

  Widget _buildCustomerDetailsCard({required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _bgDark.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 8))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) ...[
              Row(children: [
                // ✅ Full name editable on desktop
                Expanded(child: _profileFormField(
                  label: 'FULL LEGAL NAME',
                  controller: _fullNameController,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name cannot be empty' : null,
                )),
                const SizedBox(width: 20),
                // Email is read-only (can't change email here)
                Expanded(child: _buildReadOnlyField('EMAIL', _currentUser.email)),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                // ✅ Phone with corrected validator
                Expanded(child: _profileFormField(
                  label: 'CONTACT NUMBER',
                  controller: _phoneController,
                  keyboard: TextInputType.phone,
                  validator: _validatePhone,
                )),
                const SizedBox(width: 20),
                Expanded(child: _buildDarkField('ACCOUNT AGE', _currentUser.accountAge)),
              ]),
            ] else ...[
              // ✅ Full name editable on mobile too
              _profileFormField(
                label: 'FULL LEGAL NAME',
                controller: _fullNameController,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              _buildReadOnlyField('EMAIL', _currentUser.email),
              const SizedBox(height: 16),
              _profileFormField(
                label: 'CONTACT NUMBER',
                controller: _phoneController,
                keyboard: TextInputType.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),
              _buildDarkField('ACCOUNT AGE', _currentUser.accountAge),
            ],
            const SizedBox(height: 28),
            // ✅ Update button triggers validation + API call
            SizedBox(
              width: isMobile ? double.infinity : 240,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  disabledBackgroundColor: _primary.withOpacity(0.5),
                ),
                child: _isLoading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        isMobile ? 'UPDATE YOUR PROFILE' : 'UPDATE YOUR PORTFOLIO',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                            fontSize: 12, letterSpacing: 2.0, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Phone validator ────────────────────────────────────────────────────────
  // ✅ Fixed: allows empty (optional), accepts 09XXXXXXXXX and +639XXXXXXXXX

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final cleaned = value.trim().replaceAll(' ', '').replaceAll('-', '');
    // Accepts: 09XXXXXXXXX (11 digits) or +639XXXXXXXXX (13 chars)
    final valid = RegExp(r'^(09\d{9}|\+639\d{9})$').hasMatch(cleaned);
    if (!valid) return 'Enter a valid PH number (e.g. 09123456789)';
    return null;
  }

  // ── Field builders ─────────────────────────────────────────────────────────

  /// Editable field inside the main profile Form — uses the form's validator
  Widget _profileFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
              fontSize: 14, color: _bgDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F5F0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: Icon(Icons.edit_outlined, size: 16, color: _secondary.withOpacity(0.6)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _secondary.withOpacity(0.15), width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
          ),
          validator: validator,
        ),
      ],
    );
  }

  /// Editable field used inside address dialogs — has its own validator param
  Widget _addressFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
              fontSize: 14, color: _bgDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F5F0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: Icon(icon, size: 18, color: _secondary.withOpacity(0.6)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _secondary.withOpacity(0.15), width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F5F0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _secondary.withOpacity(0.15), width: 1),
          ),
          child: Text(value,
              style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                  fontSize: 14, color: _bgDark)),
        ),
      ],
    );
  }

  Widget _buildDarkField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: _bgDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value,
              style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                  fontSize: 14, letterSpacing: 1.5, color: Colors.white)),
        ),
      ],
    );
  }

  // ── Delivery addresses ─────────────────────────────────────────────────────

  Widget _buildDeliveryAddressesDesktop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 16) / 2;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _deliveryAddresses.asMap().entries.map((e) =>
              SizedBox(width: itemWidth, child: _buildAddressCard(e.value, index: e.key))
            ).toList(),
          );
        }),
        const SizedBox(height: 16),
        _buildAddNewAddressButton(),
      ],
    );
  }

  Widget _buildDeliveryAddressesMobile() {
    return Column(
      children: [
        for (int i = 0; i < _deliveryAddresses.length; i++) ...[
          _buildAddressCard(_deliveryAddresses[i], index: i),
          const SizedBox(height: 12),
        ],
        _buildAddNewAddressButton(),
      ],
    );
  }

  Widget _buildAddressCard(DeliveryAddress addr, {required int index}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _bgDark.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(addr.label,
                  style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                      fontSize: 9, letterSpacing: 1.5, color: _secondary.withOpacity(0.8))),
              const SizedBox(height: 6),
              Text(addr.address,
                  style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                      fontSize: 13, letterSpacing: 0.5, color: _bgDark)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _showEditAddressDialog(index),
          child: Container(width: 32, height: 32,
              decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.edit_outlined, size: 16, color: _primary)),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() => _deliveryAddresses.removeAt(index)),
          child: Container(width: 32, height: 32,
              decoration: BoxDecoration(color: _crimson.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_outline_rounded, size: 16, color: _crimson)),
        ),
      ]),
    );
  }

  Widget _buildAddNewAddressButton() {
    return GestureDetector(
      onTap: _showAddAddressDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _secondary.withOpacity(0.25), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: _secondary.withOpacity(0.8)),
            const SizedBox(width: 8),
            Text('+ NEW DELIVERY SITE',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 11, letterSpacing: 2.0, color: _secondary.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalSettingsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _bgDark.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Container(width: 44, height: 44,
            decoration: BoxDecoration(color: _bgBeige, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.notifications_outlined, size: 20, color: _secondary)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ALLOW NOTIFICATIONS',
                  style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                      fontSize: 13, letterSpacing: 0.5, color: _bgDark)),
              const SizedBox(height: 3),
              Text("ALERT LATEST UPDATE AND EVENT ABOUT LNL'S CAFE",
                  style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                      fontSize: 9, letterSpacing: 1.0, color: _bgDark.withOpacity(0.4))),
            ],
          ),
        ),
        Switch(
          value: _allowNotifications,
          onChanged: (val) => setState(() => _allowNotifications = val),
          activeColor: Colors.white,
          activeTrackColor: _primary,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ]),
    );
  }

  TextStyle _labelStyle() => const TextStyle(
      fontFamily: 'Urbanist',
      fontWeight: FontWeight.w700,
      fontSize: 9,
      letterSpacing: 1.5,
      color: _secondary);
}