import 'dart:math' as math;
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
  final DateTime memberSince;
  final int orderCount;
  final bool isActive;
  final String? profileImageUrl;
   // Store the current user's addresses

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
      orderCount: 0, // backend doesn’t send yet
      isActive: true,
      profileImageUrl: json['profile_picture'],
    );
  }


  // Calculate account age logic
  String get accountAge {
    final now = DateTime.now();
    final diff = now.difference(memberSince);

    if (diff.inDays < 1) {
      return 'NEW ACCOUNT';
    } else if (diff.inDays < 30) {
      return '${diff.inDays} DAYS';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months MONTHS';
    } else {
      final years = (diff.inDays / 365).floor();
      return '$years YEARS';
    }
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
  ];

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

        if (data['addresses'] != null) {
          for (var a in data['addresses']) {
            user.addresses.add(
              DeliveryAddress(
                label: a['label'] ?? 'NO LABEL',
                address: a['full_address'] ?? '',
              ),
            );
          }
        }

        setState(() {
          _currentUser = user;
          _fullNameController.text = user.fullName;
          _emailController.text = user.email;
          _phoneController.text = user.phone ?? '';
          
            _deliveryAddresses
              ..clear()
              ..addAll(user.addresses); 
        });
      }

    } catch (e) {
      print('Error fetching profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Call services for updating profile
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ProfileService.updateProfile(
        fullName: _fullNameController.text,
        phone: _phoneController.text,
      );

      setState(() {
        _currentUser.fullName = result['user']['full_name'];
        _currentUser.phone = result['user']['phone'];
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'PROFILE UPDATED SUCCESSFULLY',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          backgroundColor: _primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Update failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
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
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
      body: Stack(
        children: [
          const BambooBackground(),
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

          // Delete Account Button
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
                  Expanded(child: _buildEditableFieldWithIcon('FULL LEGAL NAME', _fullNameController)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildReadOnlyField('EMAIL', _currentUser.email)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildEditableFieldWithIcon('CONTACT NUMBER', _phoneController)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDarkField('ACCOUNT AGE', _currentUser.accountAge)),
                ],
              ),
            ] else ...[
              _buildReadOnlyField('FULL LEGAL NAME', '${_currentUser.fullName}'.toUpperCase()),
              const SizedBox(height: 16),
              _buildReadOnlyField('EMAIL', _currentUser.email),
              const SizedBox(height: 16),
              _buildEditableFieldWithIcon('CONTACT NUMBER', _phoneController),
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