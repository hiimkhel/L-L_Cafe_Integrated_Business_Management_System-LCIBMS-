import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/constants/cart_item.dart';
import 'package:frontend/core/constants/cart_provider.dart';
import 'package:frontend/core/services/customer/order_service.dart';
import 'package:frontend/core/models/order_request.dart';
import 'package:frontend/core/widgets/bamboo_breeze_background.dart'; // ← shared widget

// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────

const double _kMobile    = 768;
const Color  _kPrimary   = Color(0xFF758C6D);
const Color  _kSecondary = Color(0xFFA98258);
const Color  _kDark      = Color(0xFF2D2A26);
const Color  _kBg        = Color(0xFFEFE2C9);
const Color  _kWhite     = Colors.white;

// ─────────────────────────────────────────────────────────────────────────────
// CHECKOUT SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CartCheckoutScreen extends StatefulWidget {
  final List<CartItem> items;
  const CartCheckoutScreen({super.key, required this.items});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl   = TextEditingController();
  final _orderService = OrderService();

  late List<CartItem> _items;
  bool _isLoading  = false;
  bool _isDelivery = true;
  bool _isCash     = true;

  static const double _deliveryFee = 45.0;

  double get _subtotal => _items.fold(0, (s, i) => s + i.price * i.quantity);
  double get _fee      => _isDelivery ? _deliveryFee : 0.0;
  double get _total    => _subtotal + _fee;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Validation & order ────────────────────────────────────────────────────

  Future<void> _confirmOrder() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _snack('Please enter your full name.', error: true); return;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      _snack('Please enter your contact number.', error: true); return;
    }
    if (_isDelivery && _addressCtrl.text.trim().isEmpty) {
      _snack('Please enter a delivery address.', error: true); return;
    }
    if (_items.isEmpty) {
      _snack('Your cart is empty.', error: true); return;
    }

    setState(() => _isLoading = true);

    final order = OrderRequest(
      source:          'online',
      orderType:       _isDelivery ? 'delivery' : 'pickup',
      subtotal:        _subtotal,
      deliveryFee:     _fee,
      deliveryAddress: _isDelivery ? _addressCtrl.text.trim() : 'STORE PICKUP',
      total:           _total,
      paymentMethod:   _isCash ? 'cash' : 'e-wallet',
      paymentStatus:   'unpaid',
      customerName:    _nameCtrl.text.trim(),
      customerPhone:   _phoneCtrl.text.trim(),
      notes:           _notesCtrl.text.trim(),
      items: _items.map((i) => {
        'menu_item_id': i.id,
        'name':         i.name,
        'quantity':     i.quantity,
        'unit_price':   i.price,
        'subtotal':     i.price * i.quantity,
      }).toList(),
    );

    final ok = await _orderService.createOrder(order);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      CartProvider.of(context).clear();
      _showSuccessDialog();
    } else {
      _snack('Failed to place order. Please try again.', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Urbanist')),
      backgroundColor: error ? Colors.redAccent : _kPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => _SuccessDialog(
        name:       _nameCtrl.text.trim(),
        total:      _total,
        isDelivery: _isDelivery,
        onTrack: () {
          Navigator.of(context).pop();
          Navigator.pushReplacementNamed(context, '/orders');
        },
        onContinue: () {
          Navigator.of(context).pop();
          Navigator.pushReplacementNamed(context, '/menu');
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < _kMobile;
    final cart     = CartProvider.of(context);

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          const Positioned.fill(child: BreezeBambooBackground()), // ← updated
          Column(
            children: [
              CustomerNavbar(
                activeRoute: '/cart',
                cartCount: cart.totalCount,
                notifCount: 1,
                onCart:    () {},
                onNotif:   () {},
                onProfile: () => Navigator.pushNamed(context, '/profile'),
                onLogout:  () {},
              ),
              const SizedBox(height: 15),
              _finalizeHeader(isMobile: isMobile),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.fromLTRB(45, 0, 30, 0),
                child: Divider(height: 1, thickness: 1, color: _kPrimary.withOpacity(0.3)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (isMobile) ...[
                        const SizedBox(height: 15),
                        _orderMethod(isMobile: true),
                        const SizedBox(height: 10),
                        _deliveryPickup(isMobile: true),
                        const SizedBox(height: 15),
                        _clientDetails(isMobile: true),
                        const SizedBox(height: 20),
                        _paymentHeader(isMobile: true),
                        const SizedBox(height: 10),
                        _paymentChoices(isMobile: true),
                        const SizedBox(height: 20),
                        // FIX: field notes now has bottom padding so it doesn't
                        //      press against the footer on mobile
                        _fieldNotes(isMobile: true),
                        const SizedBox(height: 32),
                        _cartSummary(isMobile: true),
                        const SizedBox(height: 32), // ← breathing room above footer
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: Column(children: [
                              const SizedBox(height: 15),
                              _orderMethod(),
                              const SizedBox(height: 10),
                              _deliveryPickup(),
                              const SizedBox(height: 15),
                              _clientDetails(),
                              const SizedBox(height: 25),
                              _paymentHeader(),
                              const SizedBox(height: 10),
                              _paymentChoices(),
                              const SizedBox(height: 20),
                              _fieldNotes(),
                              const SizedBox(height: 48), // ← breathing room above footer
                            ])),
                            Expanded(flex: 1, child: _cartSummary()),
                          ],
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

  // ─────────────────────────────────────────────────────────────────────────
  // SECTION WIDGETS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _finalizeHeader({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 45, 15, isMobile ? 16 : 30, 0),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _kWhite,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: const Icon(Icons.chevron_left, color: _kPrimary, size: 30),
          ),
        ),
        const SizedBox(width: 12),
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            children: const [
              TextSpan(text: 'FINALIZE ', style: TextStyle(color: _kDark)),
              TextSpan(text: 'ORDER',     style: TextStyle(color: _kPrimary)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _orderMethod({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 60, 0, isMobile ? 16 : 60, 0),
      child: Row(children: [
        const Icon(Icons.access_time, color: _kPrimary, size: 20),
        const SizedBox(width: 12),
        const Text('ORDER METHOD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kDark)),
      ]),
    );
  }

  Widget _deliveryPickup({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 60, 0, isMobile ? 16 : 60, 0),
      child: Row(children: [
        _toggleBtn('DELIVERY',    _isDelivery,  () => setState(() => _isDelivery = true)),
        const SizedBox(width: 12),
        _toggleBtn('SITE PICKUP', !_isDelivery, () => setState(() => _isDelivery = false)),
      ]),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? _kPrimary : _kWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: Text(label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                  letterSpacing: 1.2, color: active ? _kWhite : _kPrimary)),
        ),
      ),
    );
  }

  Widget _clientDetails({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 60, 0, isMobile ? 16 : 60, 0),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.person_2_outlined, color: _kSecondary, size: 22),
            const SizedBox(width: 10),
            const Text('CLIENT SPECIFICATIONS',
                style: TextStyle(fontWeight: FontWeight.bold, color: _kDark, fontSize: 15)),
          ]),
          const SizedBox(height: 22),
          if (isMobile) ...[
            _inputField(label: 'FULL NAME',      hint: 'ENTER NAME...',  icon: Icons.person_2_outlined, ctrl: _nameCtrl),
            const SizedBox(height: 14),
            _inputField(label: 'CONTACT NUMBER', hint: '09XX XXX XXXX', icon: Icons.call_outlined,     ctrl: _phoneCtrl, keyboard: TextInputType.phone),
          ] else
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _inputField(label: 'FULL NAME',      hint: 'ENTER NAME...',  icon: Icons.person_2_outlined, ctrl: _nameCtrl)),
              const SizedBox(width: 20),
              Expanded(child: _inputField(label: 'CONTACT NUMBER', hint: '09XX XXX XXXX', icon: Icons.call_outlined,     ctrl: _phoneCtrl, keyboard: TextInputType.phone)),
            ]),
          if (_isDelivery) ...[
            const SizedBox(height: 14),
            _inputField(label: 'DELIVERY ADDRESS', hint: 'ENTER FULL ADDRESS...', icon: Icons.location_pin, ctrl: _addressCtrl),
          ],
        ]),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController ctrl,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: _kPrimary, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2)),
      const SizedBox(height: 8),
      SizedBox(
        height: 50,
        child: TextField(
          controller: ctrl,
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 13, color: _kDark),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 11, color: _kPrimary.withOpacity(0.45)),
            prefixIcon: Icon(icon, size: 17, color: _kPrimary.withOpacity(0.5)),
            filled: true,
            fillColor: _kPrimary.withOpacity(0.07),
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _kPrimary.withOpacity(0.5), width: 1.2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _kPrimary.withOpacity(0.15))),
          ),
        ),
      ),
    ]);
  }

  Widget _paymentHeader({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 60, 0, isMobile ? 16 : 60, 0),
      child: Row(children: [
        const Icon(Icons.credit_card_rounded, color: _kPrimary, size: 20),
        const SizedBox(width: 12),
        const Text('PAYMENT METHOD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kDark)),
      ]),
    );
  }

  Widget _paymentChoices({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 60, 0, isMobile ? 16 : 60, 0),
      child: Row(children: [
        _payBtn(
          label:  _isDelivery ? 'CASH ON DELIVERY' : 'CASH ON PICKUP',
          icon:   Icons.money,
          active: _isCash,
          onTap:  () => setState(() => _isCash = true),
        ),
        const SizedBox(width: 12),
        _payBtn(
          label:  'ONLINE PAYMENT',
          icon:   Icons.phone_iphone,
          active: !_isCash,
          onTap:  () => setState(() => _isCash = false),
        ),
      ]),
    );
  }

  Widget _payBtn({required String label, required IconData icon, required bool active, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 58,
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? _kPrimary : _kWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: active ? _kWhite : _kPrimary),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold,
                    letterSpacing: 1.2, color: active ? _kWhite : _kPrimary)),
          ]),
        ),
      ),
    );
  }

  Widget _fieldNotes({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 60, 0, isMobile ? 16 : 60, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.message_sharp, size: 20, color: _kPrimary),
          const SizedBox(width: 12),
          const Text('FIELD NOTES', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kDark)),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _notesCtrl,
          minLines: 3, maxLines: 5,
          style: const TextStyle(fontSize: 12, color: _kDark),
          decoration: InputDecoration(
            hintText: 'ADD SPECIAL INSTRUCTIONS...',
            hintStyle: TextStyle(fontSize: 11, color: _kPrimary.withOpacity(0.45)),
            filled: true,
            fillColor: _kWhite,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _kPrimary.withOpacity(0.3), width: 1.4)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _kPrimary.withOpacity(0.15))),
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ORDER SUMMARY CARD
  // ─────────────────────────────────────────────────────────────────────────

  Widget _cartSummary({bool isMobile = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: isMobile
          ? const EdgeInsets.fromLTRB(16, 8, 16, 20)
          : const EdgeInsets.fromLTRB(4, 20, 30, 20),
      decoration: BoxDecoration(
        color: _kDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
            color: _kDark.withOpacity(0.35),
            offset: const Offset(0, 6), blurRadius: 16)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(children: [
          Container(
            width: 32, height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _kPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(CupertinoIcons.checkmark_shield, size: 18, color: _kWhite),
          ),
          const SizedBox(width: 14),
          const Text('ORDER LOG',
              style: TextStyle(color: _kWhite, fontSize: 18,
                  fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ]),

        const SizedBox(height: 20),

        ..._items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name.toUpperCase(),
                  style: const TextStyle(color: _kWhite, fontSize: 11,
                      fontWeight: FontWeight.bold, letterSpacing: 0.4)),
              const SizedBox(height: 2),
              Text('×${item.quantity} UNITS',
                  style: TextStyle(color: _kWhite.withOpacity(0.55),
                      fontSize: 9, letterSpacing: 0.4)),
            ])),
            Text('₱${(item.price * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(color: _kPrimary,
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        )),

        if (_items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text('NO ITEMS IN CART',
                style: TextStyle(color: _kWhite.withOpacity(0.35), fontSize: 11)),
          ),

        const SizedBox(height: 14),
        Divider(thickness: 1, color: _kWhite.withOpacity(0.2)),
        const SizedBox(height: 12),

        _sumRow('SUBTOTAL', '₱${_subtotal.toStringAsFixed(2)}'),
        if (_isDelivery) ...[
          const SizedBox(height: 10),
          _sumRow('DELIVERY FEE', '₱${_fee.toStringAsFixed(2)}'),
        ],

        const SizedBox(height: 16),

        Row(children: [
          const Text('TOTAL COST',
              style: TextStyle(color: _kWhite, fontSize: 13,
                  fontWeight: FontWeight.bold, letterSpacing: 0.8)),
          const Spacer(),
          Text('₱${_total.toStringAsFixed(2)}',
              style: const TextStyle(color: _kPrimary, fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ]),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: _kWhite.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kWhite.withOpacity(0.2)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.payments_outlined, size: 15, color: _kWhite.withOpacity(0.7)),
            const SizedBox(width: 8),
            Text(
              _isCash
                  ? (_isDelivery ? 'CASH ON DELIVERY' : 'CASH ON PICKUP')
                  : 'ONLINE PAYMENT',
              style: TextStyle(color: _kWhite.withOpacity(0.85),
                  fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8),
            ),
          ]),
        ),

        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _confirmOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: _kWhite,
              disabledBackgroundColor: _kPrimary.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: _kWhite, strokeWidth: 2.5))
                : const Text('CONFIRM ORDER',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
          ),
        ),
      ]),
    );
  }

  Widget _sumRow(String label, String value) {
    return Row(children: [
      Text(label, style: TextStyle(color: _kWhite.withOpacity(0.6), fontSize: 10, letterSpacing: 0.5)),
      const Spacer(),
      Text(value, style: TextStyle(color: _kWhite.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w500)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUCCESS DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessDialog extends StatelessWidget {
  final String name;
  final double total;
  final bool isDelivery;
  final VoidCallback onTrack;
  final VoidCallback onContinue;

  const _SuccessDialog({
    required this.name,
    required this.total,
    required this.isDelivery,
    required this.onTrack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 16)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 8, color: _kPrimary),

              Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                child: Column(children: [

                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: _kPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: _kPrimary, size: 48),
                  ),

                  const SizedBox(height: 16),

                  const Text('ORDER CONFIRMED!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900,
                          letterSpacing: 0.5, color: _kDark)),

                  const SizedBox(height: 8),

                  Text(
                    'Thank you${name.isNotEmpty ? ', ${name.split(' ').first}' : ''}! '
                    'Your order has been placed successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, height: 1.5, color: _kDark.withOpacity(0.55)),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('ORDER TOTAL',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                letterSpacing: 1, color: _kWhite.withOpacity(0.7))),
                        Text('₱${total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _kSecondary)),
                      ]),
                      const SizedBox(height: 8),
                      Divider(color: _kWhite.withOpacity(0.15), height: 1),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('METHOD',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                letterSpacing: 1, color: _kWhite.withOpacity(0.7))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _kSecondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isDelivery ? 'DELIVERY' : 'PICKUP',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                                color: _kWhite, letterSpacing: 0.8),
                          ),
                        ),
                      ]),
                    ]),
                  ),

                  const SizedBox(height: 8),

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.shopping_cart_outlined, size: 12, color: _kPrimary.withOpacity(0.5)),
                    const SizedBox(width: 5),
                    Text('Your cart has been cleared',
                        style: TextStyle(fontSize: 10, color: _kPrimary.withOpacity(0.5))),
                  ]),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onTrack,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: _kWhite,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('TRACK MY ORDER',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  ),

                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: onContinue,
                    child: Text('Continue Shopping',
                        style: TextStyle(fontSize: 12, color: _kDark.withOpacity(0.4), fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}