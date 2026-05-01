import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/constants/cart_item.dart';
import 'package:frontend/core/services/customer/order_service.dart';
import 'package:frontend/core/models/order_request.dart';
import 'package:frontend/core/widgets/bamboo_background.dart';

const double _kMobile = 768;


//--------------------------CartCheckoutScreenState------------------------------------------------

class CartCheckoutScreen extends StatefulWidget {
  final List<CartItem> items;
  

  const CartCheckoutScreen({super.key, required this.items});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  //--------------------------ScrollController-----------------------------------
  final ScrollController _scrollController = ScrollController();

  // Text input fields controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<CartItem> _items = [];
  final OrderService _orderService = OrderService();
  bool _isLoading = false;

  bool _isDelivery = true;
  bool _isCash = true;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
  }

  Future<void> _createOrder() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in contact details")),
      );
      return;
    }

    setState(() => _isLoading = true);

    const double deliveryFee = 45.0;

    final subtotal = _items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    final currentDeliveryFee = _isDelivery ? deliveryFee : 0.0;
    final total = subtotal + currentDeliveryFee;

    final fullNotes = _isDelivery 
        ? "Address: ${_addressController.text}\nNotes: ${_notesController.text}" 
        : _notesController.text;

    final order = OrderRequest(
      source: "online",
      orderType: _isDelivery ? "delivery" : "pickup",
      subtotal: subtotal,
      deliveryFee: currentDeliveryFee,
      total: total,
      paymentMethod: _isCash ? "cash" : "e-wallet",
      paymentStatus: "unpaid",
      customerName: _nameController.text,
      customerPhone: _phoneController.text,
      notes: fullNotes,
      items: _items.map((item) {
        return {
          "menu_item_id": item.id,
          "name": item.name,
          "quantity": item.quantity ?? 1,
          "unit_price": item.price,
          "subtotal": item.price * item.quantity
        };
      }).toList(),
    );

    final success = await _orderService.createOrder(order);

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/success');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to place order")),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < _kMobile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const BambooBackground(),
          Column(
            children: [
              CustomerNavbar(
                activeRoute: '/cart',
                cartCount: 3,
                notifCount: 1,
                onCart: () {},
                onNotif: () {},
                onProfile: () => Navigator.pushNamed(context, '/profile'),
                onLogout: () {},
              ),
              const SizedBox(height: 15),
              _finalizeHeader(isMobile: isMobile),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.fromLTRB(45, 0, 30, 0),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 40),
                        child: isMobile 
                          ? _buildVerticalLayout(true) 
                          : _buildHorizontalLayout(),
                      ),
                      const CustomerFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout(bool isMobile) {
    return Column(
      children: [
        _orderMethod(isMobile: isMobile),
        _deliveryPickup(isMobile: isMobile),
        const SizedBox(height: 30),
        _clientDetails(isMobile: isMobile),
        _paymentMethod(isMobile: isMobile),
        _paymentChoices(isMobile: isMobile),
        _fieldNotes(isMobile: isMobile),
        _cartCheckoutSummary(isMobile: true),
      ],
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _orderMethod(),
              _deliveryPickup(),
              const SizedBox(height: 30),
              _clientDetails(),
              _paymentMethod(),
              _paymentChoices(),
              _fieldNotes(),
            ],
          ),
        ),
        Expanded(flex: 1, child: _cartCheckoutSummary()),
      ],
    );
  }
  
  // --- Reusable Input Field Helper ---
  Widget _customTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 10)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: AppColors.primary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: AppColors.primary.withOpacity(0.5)),
            filled: true,
            fillColor: AppColors.primary.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
          ),
        ),
      ],
    );
  }

Widget _finalizeHeader({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 45,
        15,
        isMobile ? 16 : 30,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Styled Back Button
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              padding: const EdgeInsets.all(4), // Give the icon some breathing room
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.primary,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Stylized Multi-color Title
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontFamily: 'Inter', // Ensure this matches your app's font
              ),
              children: const [
                TextSpan(
                  text: 'FINALIZE ',
                  style: TextStyle(color: AppColors.receiptDark),
                ),
                TextSpan(
                  text: 'ORDER',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

   Widget _orderMethod({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 60,
        15,
        isMobile ? 16 : 60,
        5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.access_time, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Text(
            'ORDER METHOD',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryPickup({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 60),
      child: Row(
        children: [
          _toggleBtn("DELIVERY", _isDelivery, () => setState(() => _isDelivery = true)),
          const SizedBox(width: 10),
          _toggleBtn("PICKUP", !_isDelivery, () => setState(() => _isDelivery = false)),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary),
          ),
          child: Text(label, style: TextStyle(color: isActive ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _clientDetails({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 60,
        0,
        isMobile ? 16 : 60,
        5,
      ),
      child:
          _isDelivery
              ? _deliveryDetails(isMobile: isMobile)
              : _pickupDetails(isMobile: isMobile),
    );
  }

  Widget _deliveryDetails({bool isMobile = false}) {
    // helper to avoid repeating the field decoration
    Widget _field({
      required String label,
      required String hint,
      required IconData icon,
      TextInputType? keyboard,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.09),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(13),
              ),
              child: TextField(
                keyboardType: keyboard,
                style: TextStyle(fontSize: 14, color: AppColors.primary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    icon,
                    size: 17,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final nameField = _field(
      label: 'FULL NAME',
      hint: 'ENTER NAME...',
      icon: Icons.person_2_outlined,
    );
    final contactField = _field(
      label: 'CONTACT NUMBER',
      hint: '09XX XXX XXXX',
      icon: Icons.call_outlined,
      keyboard: TextInputType.phone,
    );

    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_2_outlined,
                color: AppColors.secondary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'CLIENT SPECIFICATIONS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.receiptDark,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          //stacks vertically on mobile, side-by-side on desktop
          if (isMobile) ...[
            nameField,
            const SizedBox(height: 16),
            contactField,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: nameField),
                const SizedBox(width: 20),
                Expanded(child: contactField),
              ],
            ),

          const SizedBox(height: 20),
          // address field, also fix width
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DELIVERY ADDRESS',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.09),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: TextField(
                    style: TextStyle(fontSize: 14, color: AppColors.primary),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'ENTER FULL ADDRESS...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.location_pin,
                        size: 17,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pickupDetails({bool isMobile = false}) {
    // helper to avoid repeating the field decoration
    Widget _field({
      required String label,
      required String hint,
      required IconData icon,
      TextInputType? keyboard,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            //width: double.infinity,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.09),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(13),
              ),
              child: TextField(
                keyboardType: keyboard,
                style: TextStyle(fontSize: 14, color: AppColors.primary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    icon,
                    size: 17,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final nameField = _field(
      label: 'FULL NAME',
      hint: 'ENTER NAME...',
      icon: Icons.person_2_outlined,
    );
    final contactField = _field(
      label: 'CONTACT NUMBER',
      hint: '09XX XXX XXXX',
      icon: Icons.call_outlined,
      keyboard: TextInputType.phone,
    );

    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_2_outlined,
                color: AppColors.secondary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'CLIENT SPECIFICATIONS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.receiptDark,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          //stacks vertically on mobile, side-by-side on desktop
          if (isMobile) ...[
            SizedBox(width: double.infinity, child: nameField),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: contactField),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: nameField),
                const SizedBox(width: 20),
                Expanded(child: contactField),
              ],
            ),

          const SizedBox(height: 20),
          // address field, also fix width
        ],
      ),
    );
  }

  Widget _paymentMethod({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 60,
        15,
        isMobile ? 16 : 60,
        5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_rounded, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Text(
            'PAYMENT METHOD',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentChoices({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 60,
        0,
        isMobile ? 16 : 60,
        5,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCash = true),
              child: AnimatedContainer(
                padding: const EdgeInsets.only(top: 14),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 58,
                decoration: BoxDecoration(
                  color: _isCash ? AppColors.secondary : AppColors.white,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.money,
                      color: _isCash ? AppColors.white : AppColors.primary,
                      size: 15,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'CASH ON DELIVERY',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                        color: _isCash ? AppColors.white : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isCash = false),
              child: AnimatedContainer(
                padding: const EdgeInsets.only(top: 14),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 58,
                decoration: BoxDecoration(
                  color: !_isCash ? AppColors.secondary : AppColors.white,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_iphone,
                      color: _isCash ? AppColors.primary : AppColors.white,
                      size: 15,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'ONLINE PAYMENT',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                        color: _isCash ? AppColors.primary : AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldNotes({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 60,
        15,
        isMobile ? 16 : 60,
        5,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.message_sharp, size: 20, color: AppColors.secondary),
              const SizedBox(width: 12),
              Text(
                'FIELD NOTES',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 90,
            child: TextField(
              minLines: 4,
              maxLines: 4,
              style: TextStyle(fontSize: 12, color: AppColors.primary),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'ADD SPECIAL INSTRUCTIONS...',
                hintStyle: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: AppColors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartCheckoutSummary({bool isMobile = false}) {
    const double deliveryFee = 45.0;
    final double subTotal = _items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    //if pickup fee is 0
    final double appliedDeliveryFee = _isDelivery ? deliveryFee : 0.0;

    final double orderTotal = _isDelivery ? subTotal + deliveryFee : subTotal;

    return Container(
      padding: const EdgeInsets.all(25),
      margin:
          isMobile
              ? const EdgeInsets.fromLTRB(16, 8, 16, 20) // full-width on mobile
              : const EdgeInsets.fromLTRB(1, 20, 30, 20), // original desktop
      decoration: BoxDecoration(
        color: AppColors.receiptDark,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.receiptDark.withOpacity(.3),
            offset: const Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    CupertinoIcons.checkmark_shield,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'ORDER LOG',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            //the pulled ordered item should be displayed here
            ..._items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name.toUpperCase(),
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'X${item.quantity} UNITS',
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.7),
                              fontSize: 9,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₱${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_items.isEmpty)
              Text("NO ITEMS PASSED", style: TextStyle(color: Colors.white)),

            const SizedBox(height: 16),
            Divider(thickness: 1, color: AppColors.white.withOpacity(0.1)),
            const SizedBox(height: 10),

            Row(
              children: [
                Text(
                  'SUBTOTAL',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.55),
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),

                const Spacer(),

                Text(
                  '₱${subTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Text(
                  _isDelivery ? 'DELIVERY FEE' : ' ',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.55),
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),

                const Spacer(),

                Text(
                  _isDelivery
                      ? '₱${appliedDeliveryFee.toStringAsFixed(2)}'
                      : ' ',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'TOTAL COST',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),

                Text(
                  '₱${orderTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 29),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: AppColors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_android,
                    size: 18,
                    color: AppColors.white.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _isCash
                          ? 'PAYMENT METHOD: CASH ON DELIVERY'
                          : 'PAYMENT METHOD: ONLINE PAYMENT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 19),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                
                onPressed: _isLoading ? null : _createOrder,
                
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'CONFIRM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
