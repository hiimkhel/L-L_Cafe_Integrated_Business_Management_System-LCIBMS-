import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';

const double _kMobile = 900;
const double _kDesktopMaxWidth = 1400;

// Brand Colors
const Color _bgBeige   = Color(0xFFEFE2C9);
const Color _bgDark    = Color(0xFF2D2A26);
const Color _primary   = Color(0xFF758C6D); // Green
const Color _secondary = Color(0xFFA98258); // Gold
const Color _crimson   = Color(0xFF9B2335); // Delete button

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  String fullName;
  String email;
  String? phone; 
  final String memberSince;
  final int orderCount;
  final bool isActive;
  final String? profileImageUrl;

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
      memberSince: json['created_at'] ?? '',
      orderCount: 0, // backend doesn’t send yet
      isActive: true,
      profileImageUrl: json['profile_picture'],
    );
  }

  String get accountAge => '365 DAYS';
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
  
  const ProfileScreen({super.key, this.onLogout, required this.userId, required this.email});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel _currentUser;
  bool _isLoading = false;
  bool _allowNotifications = true;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final List<DeliveryAddress> _deliveryAddresses = [
    DeliveryAddress(label: 'PRIMARY RESIDENCE (HOME)', address: 'BRGY. TABAN-MANGUINING'),
    DeliveryAddress(label: 'DESIGN STUDIO (OFFICE)', address: 'SALARDA ST., ALIMODIAN, ILOILO'),
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = UserModel(
        id: widget.userId,
        fullName: '',
        email: widget.email,
        phone: null,
        memberSince: '',
        orderCount: 0,
        isActive: true,
        profileImageUrl: null,
      );

    _fullNameController = TextEditingController();
    _emailController    = TextEditingController();
    _phoneController    = TextEditingController();

    _fetchUserProfile();
  }


  // Backend Call for /api/customer/user endpoint
  Future<void> _fetchUserProfile() async {
    if (_currentUser.id.isEmpty) {
      print("User ID missing — skipping fetch");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3006/api/customer/${_currentUser.id}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.statusCode}");
      }

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final user = UserModel.fromJson(data['user']);

        setState(() {
          _currentUser = user;
          _emailController.text = user.email;
          _phoneController.text = user.phone ?? '';
          _deliveryAddresses.clear();
        });
      }

    } catch (e) {
      print('Error fetching profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _currentUser.email = _emailController.text;
      _currentUser.phone = _phoneController.text;
      _isLoading = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('PROFILE UPDATED SUCCESSFULLY',
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w800, letterSpacing: 1)),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DELETE ACCOUNT DIALOG LOGIC
  // ─────────────────────────────────────────────────────────────────────────
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: _crimson, size: 24),
              SizedBox(width: 8),
              Text('DELETE ACCOUNT', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 18, color: _bgDark)),
            ],
          ),
          content: const Text(
            'Are you sure you want to permanently delete your account?\n\nThere\'s no going back ☹️',
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 14, height: 1.5, color: _bgDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, color: _secondary)),
            ),
            ElevatedButton(
              onPressed: () {
                // Close the dialog
                Navigator.pop(ctx);
                
                // Clear the state and redirect to landing screen
                if (widget.onLogout != null) widget.onLogout!();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _crimson,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('DELETE PERMANENTLY', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddAddressDialog() {
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('ADD NEW DELIVERY SITE', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 18, color: _bgDark)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditableField('LABEL (e.g. HOME, OFFICE)', labelController, Icons.label_outline),
                const SizedBox(height: 16),
                _buildEditableField('COMPLETE ADDRESS', addressController, Icons.location_on_outlined),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, color: _secondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _deliveryAddresses.add(DeliveryAddress(
                      label: labelController.text.toUpperCase(),
                      address: addressController.text.toUpperCase(),
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
              child: const Text('SAVE SITE', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showEditAddressDialog(int index) {
    final addr = _deliveryAddresses[index];
    final labelController = TextEditingController(text: addr.label);
    final addressController = TextEditingController(text: addr.address);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('UPDATE DELIVERY SITE', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 18, color: _bgDark)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditableField('LABEL (e.g. HOME, OFFICE)', labelController, Icons.label_outline),
                const SizedBox(height: 16),
                _buildEditableField('COMPLETE ADDRESS', addressController, Icons.location_on_outlined),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, color: _secondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _deliveryAddresses[index] = DeliveryAddress(
                      label: labelController.text.toUpperCase(),
                      address: addressController.text.toUpperCase(),
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
              child: const Text('UPDATE SITE', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBeige,
      appBar: CustomerNavbar(
        activeRoute: '/profile',
        cartCount: 2,
        notifCount: 1,
        userName: _currentUser.fullName,
        userClientId: 'CLIENT #${_currentUser.id}',
        onLogout: () {
          if (widget.onLogout != null) widget.onLogout!();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _BambooBackground()),
          LayoutBuilder(
            builder: (context, constraints) {
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
                            vertical: isMobile ? 32 : 56,
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageTitle('ACCOUNT', 'DETAILS'),
        const SizedBox(height: 8),
        const Text(
          'MAKING GOOD FOOD FOR PEOPLE\'S HAPPINESS',
          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 3.0, color: _secondary),
        ),
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

  Widget _buildPageTitle(String normal, String highlight) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '$normal ', style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 36, letterSpacing: -1.0, color: _bgDark)),
          TextSpan(text: highlight, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 36, letterSpacing: -1.0, color: _primary)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(width: 4, height: 22, decoration: BoxDecoration(color: _secondary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Icon(icon, size: 18, color: _secondary),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2.0, color: _bgDark, fontStyle: FontStyle.italic)),
      ],
    );
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
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(top: 0, right: 0, child: Container(width: 40, height: 40, decoration: BoxDecoration(color: _bgBeige, borderRadius: BorderRadius.circular(12)))),
              Container(width: 100, height: 100, decoration: BoxDecoration(color: const Color(0xFF3A3A3A), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.person_rounded, size: 52, color: Color(0xFF888888))),
            ],
          ),
          const SizedBox(height: 20),
          Text(_currentUser.fullName, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5, color: _bgDark)),
          const SizedBox(height: 6),
          Text('CLIENT #${_currentUser.id}', style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 1.5, color: _secondary)),
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

          // ✅ UPDATED: Delete Account Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showDeleteAccountDialog, // Triggers the modal!
              icon: const Icon(Icons.delete_forever_rounded, size: 16, color: Colors.white),
              label: const Text(
                'DELETE ACCOUNT',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2.0, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _crimson,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 9, letterSpacing: 1.5, color: _bgDark.withOpacity(0.5))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5, color: _bgDark)),
      ],
    );
  }

  Widget _buildStatusItem() {
    return Column(
      children: [
        Text('STATUS', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 9, letterSpacing: 1.5, color: _bgDark.withOpacity(0.5))),
        const SizedBox(height: 2),
        Row(
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            const Text('Active', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 16, color: _primary)),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerDetailsCard({required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: _bgDark.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 8))]),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) ...[
              Row(
                children: [
                  Expanded(child: _buildReadOnlyField('FULL LEGAL NAME', '${_currentUser.fullName}'.toUpperCase())),
                  const SizedBox(width: 20),
                  Expanded(child: _buildReadOnlyField('CUSTOMER ID / EMAIL', _currentUser.email)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildEditableField('COMMUNICATION LINE', _phoneController, Icons.phone_outlined)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDarkField('ACCOUNT AGE', _currentUser.accountAge)),
                ],
              ),
            ] else ...[
              _buildReadOnlyField('FULL LEGAL NAME', '${_currentUser.fullName}'.toUpperCase()),
              const SizedBox(height: 16),
              _buildEditableFieldWithIcon('CUSTOMER ID / EMAIL', _emailController),
              const SizedBox(height: 16),
              _buildEditableFieldWithIcon('COMMUNICATION LINE', _phoneController),
              const SizedBox(height: 16),
              _buildDarkField('ACCOUNT AGE', _currentUser.accountAge),
            ],
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _isLoading ? null : _updateProfile,
              child: Container(
                width: isMobile ? double.infinity : 240,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(12)),
                child: _isLoading
                    ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
                    : Text(isMobile ? 'UPDATE YOUR PROFILE' : 'UPDATE YOUR PORTFOLIO', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2.0, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
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
          decoration: BoxDecoration(color: const Color(0xFFF8F5F0), borderRadius: BorderRadius.circular(12), border: Border.all(color: _secondary.withOpacity(0.15), width: 1)),
          child: Text(value, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 14, color: _bgDark)),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 14, color: _bgDark),
          decoration: InputDecoration(
            filled: true, fillColor: const Color(0xFFF8F5F0), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _secondary.withOpacity(0.15), width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null; //  allow empty

            // optional: basic PH number validation
            if (!RegExp(r'^\+?\d{10,13}$').hasMatch(value)) {
              return 'Invalid phone number';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEditableFieldWithIcon(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 14, color: _bgDark),
          decoration: InputDecoration(
            filled: true, fillColor: const Color(0xFFF8F5F0), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: Icon(Icons.edit_outlined, size: 16, color: _secondary.withOpacity(0.6)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _secondary.withOpacity(0.15), width: 1)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
          ),
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
          decoration: BoxDecoration(color: _bgDark, borderRadius: BorderRadius.circular(12)),
          child: Text(value, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddressesDesktop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double itemWidth = (constraints.maxWidth - 16) / 2;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _deliveryAddresses.asMap().entries.map((entry) {
                final index = entry.key;
                final address = entry.value;

                return SizedBox(
                  width: itemWidth, // ✅ forces max 2 columns
                  child: _buildAddressCard(address, index: index),
                );
              }).toList(),
            );
          },
        ),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: _bgDark.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(addr.label, style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 9, letterSpacing: 1.5, color: _secondary.withOpacity(0.8))),
                const SizedBox(height: 6),
                Text(addr.address, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5, color: _bgDark)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showEditAddressDialog(index),
            child: Container(width: 32, height: 32, decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.edit_outlined, size: 16, color: _primary)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () { setState(() { _deliveryAddresses.removeAt(index); }); },
            child: Container(width: 32, height: 32, decoration: BoxDecoration(color: _crimson.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete_outline_rounded, size: 16, color: _crimson)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewAddressButton() {
    return GestureDetector(
      onTap: _showAddAddressDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(16), border: Border.all(color: _secondary.withOpacity(0.25), width: 1.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: _secondary.withOpacity(0.8)),
            const SizedBox(width: 8),
            Text('+ NEW DELIVERY SITE', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2.0, color: _secondary.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalSettingsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: _bgDark.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: _bgBeige, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.notifications_outlined, size: 20, color: _secondary)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ALLOW NOTIFICATIONS', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5, color: _bgDark)),
                const SizedBox(height: 3),
                Text('ALERT LATEST UPDATE AND EVENT ABOUT LNL\'S CAFE', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 9, letterSpacing: 1.0, color: _bgDark.withOpacity(0.4))),
              ],
            ),
          ),
          Switch(
            value: _allowNotifications,
            onChanged: (val) => setState(() => _allowNotifications = val),
            activeColor: Colors.white, activeTrackColor: _primary, inactiveThumbColor: Colors.white, inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  TextStyle _labelStyle() => const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 9, letterSpacing: 1.5, color: _secondary);
}

// ─────────────────────────────────────────────────────────────────────────────
// BAMBOO BACKGROUND 
// ─────────────────────────────────────────────────────────────────────────────

class _BambooBackground extends StatefulWidget {
  const _BambooBackground();
  @override
  State<_BambooBackground> createState() => _BambooBackgroundState();
}

class _BambooBackgroundState extends State<_BambooBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < _kMobile;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(painter: _BambooPainter(animationValue: _controller.value, isMobile: isMobile), size: Size.infinite);
      },
    );
  }
}

class _BambooPainter extends CustomPainter {
  final double animationValue;
  final bool isMobile;
  _BambooPainter({required this.animationValue, required this.isMobile});

  static const _bamboos = [
    [0.040, 13.0,  0.12, 1.53], [0.095, 7.0,   0.10, -1.84],
    [0.133, 14.0,  0.13, 1.45], [0.190, 9.0,   0.10, -0.72],
    [0.236, 9.5,   0.10, -0.71], [0.283, 13.0,  0.12, -1.53],
    [0.321, 13.0,  0.11, 1.24], [0.374, 1.9,   0.08, 0.29],
    [0.423, 2.2,   0.08, 0.35], [0.469, 2.6,   0.08, -0.34],
    [0.503, 20.0,  0.13, 2.00], [0.560, 4.1,   0.09, 1.06],
    [0.598, 17.6,  0.12, 1.82], [0.656, 8.9,   0.10, -0.98],
    [0.693, 15.5,  0.11, 1.72], [0.739, 17.9,  0.12, 1.99],
    [0.783, 18.8,  0.12, 1.81], [0.839, 8.9,   0.10, 0.66],
    [0.890, 5.2,   0.08, -1.98], [0.936, 16.6,  0.11, -1.89],
  ];

  void _drawLeaf(Canvas canvas, Offset offset, double angle, double length, double width, Paint paint) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle);
    final path = Path()..moveTo(0, 0)..quadraticBezierTo(length * 0.4, -width, length, 0)..quadraticBezierTo(length * 0.6, width, 0, 0)..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _primary;
    int index = 0;
    for (final b in _bamboos) {
      index++;
      if (isMobile && index % 3 != 0) continue;
      final baseX  = size.width * (b[0] as double);
      final w      = b[1] as double;
      final deg    = b[3] as double;
      final h      = size.height;
      final double baseOp = b[2] as double;
      final op = isMobile ? baseOp * 0.4 : baseOp;
      final movementX = animationValue * size.width * (op * 8);
      final x = (baseX + movementX) % size.width;
      final sway = math.sin((animationValue * math.pi * 4) + (x * 0.01)) * 0.015;
      final rad = (deg * math.pi / 180) + sway;

      paint.color = _primary.withOpacity(op);

      canvas.save();
      canvas.translate(x + w / 2, h / 2);
      canvas.rotate(rad);
      
      canvas.drawRect(Rect.fromLTWH(-w / 2, -h / 2 - 20, w, h + 40), paint);
      int segments = (h / (w * 10 + 60)).ceil().clamp(3, 10);
      double segmentHeight = (h + 40) / segments;
      for (int i = 1; i < segments; i++) {
        double jointY = (-h / 2 - 20) + (i * segmentHeight);
        canvas.drawRect(Rect.fromLTWH(-w / 2 - 1.5, jointY - 1, w + 3, 2.5), paint);
        if ((index + i) % 4 != 0) { 
          bool isLeft = (index + i) % 2 == 0;
          double leafLength = w * 2.5 + 20.0;
          double leafWidth = leafLength * 0.25;
          double angle = isLeft ? math.pi * 0.8 : math.pi * 0.2;
          _drawLeaf(canvas, Offset(isLeft ? -w / 2 : w / 2, jointY), angle, leafLength, leafWidth, paint);
          if (i % 2 == 0) {
             double secondaryAngle = isLeft ? math.pi * 1.1 : -math.pi * 0.1;
             _drawLeaf(canvas, Offset(isLeft ? -w / 2 : w / 2, jointY), secondaryAngle, leafLength * 0.8, leafWidth * 0.8, paint);
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
  bool shouldRepaint(covariant _BambooPainter oldDelegate) => oldDelegate.animationValue != animationValue || oldDelegate.isMobile != isMobile;
}