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
      child: _isDelivery
          ? _deliveryDetails(isMobile: isMobile)
          : _pickupDetails(isMobile: isMobile),
    );
  }


  Widget _deliveryDetails({bool isMobile = false}) {
    // Helper used for Name and Contact
    Widget _styledField({
      required String label,
      required String hint,
      required IconData icon,
      required TextEditingController controller,
      TextInputType? keyboard,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
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
                controller: controller,
                keyboardType: keyboard,
                style: const TextStyle(fontSize: 14, color: AppColors.primary),
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
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

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
          _clientSpecsHeader(),
          const SizedBox(height: 25),
          if (isMobile) ...[
            _styledField(label: 'FULL NAME', hint: 'ENTER NAME...', icon: Icons.person_2_outlined, controller: _nameController),
            const SizedBox(height: 16),
            _styledField(label: 'CONTACT NUMBER', hint: '09XX XXX XXXX', icon: Icons.call_outlined, keyboard: TextInputType.phone, controller: _phoneController),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _styledField(label: 'FULL NAME', hint: 'ENTER NAME...', icon: Icons.person_2_outlined, controller: _nameController)),
                const SizedBox(width: 20),
                Expanded(child: _styledField(label: 'CONTACT NUMBER', hint: '09XX XXX XXXX', icon: Icons.call_outlined, keyboard: TextInputType.phone, controller: _phoneController)),
              ],
            ),
          const SizedBox(height: 20),
          _addressFieldStyled(), // Styled specifically for address
        ],
      ),
    );
  }

  Widget _pickupDetails({bool isMobile = false}) {
    // Shared styled field for pickup (Name & Contact only)
    Widget _styledField({
      required String label,
      required String hint,
      required IconData icon,
      required TextEditingController controller,
      TextInputType? keyboard,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.09),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(13),
              ),
              child: TextField(
                controller: controller,
                keyboardType: keyboard,
                style: const TextStyle(fontSize: 14, color: AppColors.primary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(fontSize: 12, color: AppColors.primary.withOpacity(0.5), fontWeight: FontWeight.w500),
                  prefixIcon: Icon(icon, size: 17, color: AppColors.primary.withOpacity(0.5)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

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
          _clientSpecsHeader(),
          const SizedBox(height: 25),
          if (isMobile) ...[
            SizedBox(width: double.infinity, child: _styledField(label: 'FULL NAME', hint: 'ENTER NAME...', icon: Icons.person_2_outlined, controller: _nameController)),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: _styledField(label: 'CONTACT NUMBER', hint: '09XX XXX XXXX', icon: Icons.call_outlined, keyboard: TextInputType.phone, controller: _phoneController)),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _styledField(label: 'FULL NAME', hint: 'ENTER NAME...', icon: Icons.person_2_outlined, controller: _nameController)),
                const SizedBox(width: 20),
                Expanded(child: _styledField(label: 'CONTACT NUMBER', hint: '09XX XXX XXXX', icon: Icons.call_outlined, keyboard: TextInputType.phone, controller: _phoneController)),
              ],
            ),
        ],
      ),
    );
  }

  // --- Sub-widgets for cleaner code ---

  Widget _clientSpecsHeader() {
    return Row(
      children: [
        const Icon(Icons.person_2_outlined, color: AppColors.secondary, size: 22),
        const SizedBox(width: 10),
        const Text(
          'CLIENT SPECIFICATIONS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.receiptDark,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _addressFieldStyled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
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
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(13),
            ),
            child: TextField(
              controller: _addressController,
              style: const TextStyle(fontSize: 14, color: AppColors.primary),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _paymentMethod({bool isMobile = false}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 60),
      leading: const Icon(Icons.payment, color: AppColors.secondary),
      title: const Text("PAYMENT METHOD", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _paymentChoices({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 60),
      child: Row(
        children: [
          _toggleBtn("CASH", _isCash, () => setState(() => _isCash = true)),
          const SizedBox(width: 10),
          _toggleBtn("E-WALLET", !_isCash, () => setState(() => _isCash = false)),
        ],
      ),
    );
  }

  Widget _fieldNotes({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 60),
      child: _customTextField(label: "SPECIAL INSTRUCTIONS", hint: "No onions, extra spicy...", icon: Icons.note, controller: _notesController, maxLines: 3),
    );
  }

  Widget _cartCheckoutSummary({bool isMobile = false}) {
    final subtotal = _items.fold<double>(0, (sum, item) => sum + (item.price * item.quantity));
    final deliveryFee = _isDelivery ? 45.0 : 0.0;
    final total = subtotal + deliveryFee;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.receiptDark, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Row(children: [Icon(Icons.receipt_long, color: Colors.white), SizedBox(width: 10), Text("ORDER SUMMARY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
          const Divider(color: Colors.white24),
          ..._items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${item.quantity}x ${item.name}", style: const TextStyle(color: Colors.white70)),
                Text("₱${(item.price * item.quantity).toStringAsFixed(2)}", style: const TextStyle(color: Colors.white)),
              ],
            ),
          )),
          const Divider(color: Colors.white24),
          _summaryRow("Subtotal", subtotal),
          _summaryRow("Delivery Fee", deliveryFee),
          const SizedBox(height: 10),
          _summaryRow("TOTAL", total, isTotal: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, padding: const EdgeInsets.symmetric(vertical: 15)),
              onPressed: _isLoading ? null : _createOrder,
              child: const Text("PLACE ORDER", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.white : Colors.white70, fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text("₱${value.toStringAsFixed(2)}", style: TextStyle(color: isTotal ? AppColors.secondary : Colors.white, fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
