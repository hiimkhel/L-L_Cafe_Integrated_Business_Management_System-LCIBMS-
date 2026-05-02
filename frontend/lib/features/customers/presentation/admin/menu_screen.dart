import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/constants/cart_provider.dart';
import 'package:frontend/core/services/customer/menu_service.dart';
import 'package:frontend/core/models/menu_item.dart';

const double _kMobile = 900;
const double _kDesktopMaxWidth = 1400;
const Color _bgBeige   = Color(0xFFEFE2C9);
const Color _bgDark    = Color(0xFF2D2A26);
const Color _primary   = Color(0xFF758C6D);
const Color _secondary = Color(0xFFA98258);

enum StockStatus { inStock, outOfStock, limitedStock }

const List<Map<String, String>> _kCategories = [
  {'label': 'ALL',              'value': ''},
  {'label': 'FOODS',            'value': '1'},
  {'label': 'PARTY TRAY',       'value': '2'},
  {'label': 'WAFFLES',          'value': '3'},
  {'label': 'COFFEE',           'value': '4'},
  {'label': 'NON-COFFEE DRINKS','value': '5'},
  {'label': 'FRAPPES',          'value': '6'},
];

// ─────────────────────────────────────────────────────────────────────────────
// MENU SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class MenuScreen extends StatefulWidget {
  /// Pass true when the user is not logged in so the add-to-cart button
  /// redirects to login instead of adding items.
  final bool isGuest;

  /// Called when a guest taps add-to-cart — show the login screen here.
  final VoidCallback? onLoginRequired;

  const MenuScreen({
    super.key,
    this.isGuest = false,
    this.onLoginRequired,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedLabel      = 'ALL';
  String _activeCategoryValue = '';
  List<MenuItem> _allRemoteItems = [];
  Timer? _debounce;
  bool _isLoading = true;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final items = await MenuService.fetchMenu(
        category: _activeCategoryValue,
        search: _searchQuery,
      );
      setState(() {
        _allRemoteItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('COULD NOT REFRESH MENU')),
      );
    }
  }

  List<MenuItem> get _filteredItems {
    return _allRemoteItems.where((item) {
      final matchSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchSearch;
    }).toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _loadMenu);
  }

  // ── Add to cart ──────────────────────────────────────────────────────────

  void _addToCart(MenuItem menuItem) {
    // ✅ Guest taps add-to-cart → redirect to login instead
    if (widget.isGuest) {
      widget.onLoginRequired?.call();
      return;
    }

    CartProvider.of(context).add(CartItem(
      id: menuItem.id.toString(),
      name: menuItem.name,
      category: 'Menu Item',
      price: menuItem.price,
      originalPrice: menuItem.price,
      quantity: 1,
      imageUrl: menuItem.imageUrl,
    ));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${menuItem.name} ADDED TO CART',
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () => Navigator.pushReplacementNamed(context, '/orders'),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cart = widget.isGuest ? null : CartProvider.of(context);

    return Scaffold(
      backgroundColor: _bgBeige,
      appBar: CustomerNavbar(
        activeRoute: '/menu',
        cartCount: cart?.totalCount ?? 0,
        notifCount: widget.isGuest ? 0 : 1,
        userName: widget.isGuest ? null : 'JANE DOE',
        userClientId: widget.isGuest ? null : 'CLIENT #LL-00124',
        // ✅ Pass guest state so the navbar cart button also redirects to login
        isGuest: widget.isGuest,
        onLoginRequired: widget.onLoginRequired,
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
                            vertical: isMobile ? 32 : 48,
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

  // ── Desktop Layout ───────────────────────────────────────────────────────

  Widget _buildDesktopLayout() {
    final items = _filteredItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageTitle(),
                  const SizedBox(height: 8),
                  const Text(
                    "MAKING GOOD FOOD FOR PEOPLE'S HAPPINESS",
                    style: TextStyle(
                      fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                      fontSize: 11, letterSpacing: 3.0, color: _secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            SizedBox(width: 360, child: _buildSearchBar()),
          ],
        ),
        const SizedBox(height: 36),
        _buildCategoryFilter(scrollable: false),
        const SizedBox(height: 36),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 100),
              child: CircularProgressIndicator(color: _primary),
            ),
          )
        else if (items.isEmpty)
          _buildEmptyState()
        else
          _buildGrid(items, crossAxisCount: 4),
      ],
    );
  }

  // ── Mobile Layout ────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    final items = _filteredItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageTitle(),
        const SizedBox(height: 6),
        const Text(
          'L&L CAFE MENU',
          style: TextStyle(
            fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
            fontSize: 10, letterSpacing: 2.5, color: _secondary,
          ),
        ),
        const SizedBox(height: 20),
        _buildSearchBar(),
        const SizedBox(height: 20),
        _buildCategoryFilter(scrollable: true),
        const SizedBox(height: 20),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 100),
              child: CircularProgressIndicator(color: _primary),
            ),
          )
        else if (items.isEmpty)
          _buildEmptyState()
        else
          _buildGrid(items, crossAxisCount: 2),
      ],
    );
  }

  // ── Shared Widgets ───────────────────────────────────────────────────────

  Widget _buildPageTitle() {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'THE ',
            style: TextStyle(
              fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
              fontSize: 40, letterSpacing: -1.5, color: _bgDark,
            ),
          ),
          TextSpan(
            text: 'MENU',
            style: TextStyle(
              fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
              fontSize: 40, letterSpacing: -1.5, color: _primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
              color: _bgDark.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() => _searchQuery = val);
          _onSearchChanged(val);
        },
        onSubmitted: (val) {
          setState(() => _searchQuery = val);
          _loadMenu();
        },
        style: const TextStyle(
          fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
          fontSize: 14, color: _bgDark,
        ),
        decoration: InputDecoration(
          hintText: 'SEARCH...',
          hintStyle: TextStyle(
            fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
            fontSize: 13, color: _bgDark.withOpacity(0.35), letterSpacing: 1.5,
          ),
          prefixIcon: Icon(Icons.search_rounded,
              color: _bgDark.withOpacity(0.4), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: _bgDark.withOpacity(0.4), size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _loadMenu();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter({required bool scrollable}) {
    final chips = _kCategories.map((cat) {
      final label = cat['label']!;
      final value = cat['value']!;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: _CategoryChip(
          label: label,
          selected: _selectedLabel == label,
          onTap: () {
            if (_selectedLabel == label) return;
            setState(() {
              _selectedLabel = label;
              _activeCategoryValue = value;
            });
            _loadMenu();
          },
        ),
      );
    }).toList();

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      );
    }
    return Wrap(spacing: 10, runSpacing: 10, children: chips);
  }

  Widget _buildGrid(List<MenuItem> items, {required int crossAxisCount}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: crossAxisCount == 4 ? 24 : 16,
        crossAxisSpacing: crossAxisCount == 4 ? 24 : 12,
        childAspectRatio: crossAxisCount == 4 ? 0.72 : 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _MenuCard(
        item: items[i],
        isMobile: crossAxisCount == 2,
        isGuest: widget.isGuest,
        onAddToCart: () => _addToCart(items[i]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: _secondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('NO ITEMS FOUND',
                style: TextStyle(
                  fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                  fontSize: 16, letterSpacing: 2.0,
                  color: _bgDark.withOpacity(0.4),
                )),
            const SizedBox(height: 8),
            Text('Try a different search or category',
                style: TextStyle(
                  fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                  fontSize: 13, color: _bgDark.withOpacity(0.3),
                )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _secondary : Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: selected ? _secondary : _secondary.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: selected
              ? [BoxShadow(
                  color: _secondary.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4))]
              : [],
        ),
        child: Text(label,
            style: TextStyle(
              fontFamily: 'Urbanist', fontWeight: FontWeight.w800,
              fontSize: 11, letterSpacing: 1.5,
              color: selected ? Colors.white : _bgDark.withOpacity(0.7),
            )),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MENU CARD
// ─────────────────────────────────────────────────────────────────────────────

class _MenuCard extends StatefulWidget {
  final MenuItem item;
  final VoidCallback onAddToCart;
  final bool isMobile;
  final bool isGuest;

  const _MenuCard({
    required this.item,
    required this.onAddToCart,
    required this.isMobile,
    required this.isGuest,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 140));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleAddToCart() async {
    // Skip bounce animation for guests — they'll be redirected
    if (!widget.isGuest) {
      await _bounceCtrl.forward();
      await _bounceCtrl.reverse();
    }
    widget.onAddToCart();
  }

  Color get _stockColor =>
      widget.item.isAvailable ? _primary : Colors.redAccent;

  String get _stockLabel =>
      widget.item.isAvailable ? 'IN STOCK' : 'OUT OF STOCK';

  @override
  Widget build(BuildContext context) {
    final isOut = !widget.item.isAvailable;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _bgDark.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.item.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: _bgBeige,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                          color: _primary,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: _bgBeige,
                    child: const Center(
                        child: Icon(Icons.broken_image_rounded,
                            color: _secondary, size: 32)),
                  ),
                ),
                if (isOut) Container(color: Colors.black.withOpacity(0.4)),
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _stockColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_stockLabel,
                        style: const TextStyle(
                          fontFamily: 'Urbanist', fontWeight: FontWeight.w800,
                          fontSize: 8, letterSpacing: 1.0, color: Colors.white,
                        )),
                  ),
                ),
              ],
            ),
          ),

          // Info
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                      fontSize: widget.isMobile ? 12 : 14,
                      letterSpacing: 0.2, color: _bgDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      widget.item.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w500,
                        fontSize: widget.isMobile ? 9 : 10,
                        height: 1.5, color: _bgDark.withOpacity(0.55),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '₱${widget.item.price.toInt()}.00',
                        style: TextStyle(
                          fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                          fontSize: widget.isMobile ? 14 : 16,
                          color: _bgDark, letterSpacing: -0.5,
                        ),
                      ),
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: GestureDetector(
                          onTap: isOut ? null : _handleAddToCart,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: widget.isMobile ? 34 : 42,
                            height: widget.isMobile ? 34 : 42,
                            decoration: BoxDecoration(
                              color: isOut
                                  ? Colors.grey.shade200
                                  // ✅ Guests see a slightly different tint
                                  // on the button to hint login is needed,
                                  // but the button still shows — it just
                                  // redirects to login on tap.
                                  : _secondary.withOpacity(
                                      widget.isGuest ? 0.08 : 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              // ✅ Show lock icon for guests so it's clear
                              widget.isGuest && !isOut
                                  ? Icons.lock_outline_rounded
                                  : Icons.shopping_cart_outlined,
                              size: widget.isMobile ? 16 : 20,
                              color: isOut
                                  ? Colors.grey
                                  : widget.isGuest
                                      ? _secondary.withOpacity(0.5)
                                      : _secondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 30))
      ..repeat();
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
      builder: (_, __) => CustomPaint(
        painter: _BambooPainter(
            animationValue: _controller.value, isMobile: isMobile),
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
    [0.040, 13.0, 0.12, 1.53],  [0.095, 7.0,  0.10, -1.84],
    [0.133, 14.0, 0.13, 1.45],  [0.190, 9.0,  0.10, -0.72],
    [0.236, 9.5,  0.10, -0.71], [0.283, 13.0, 0.12, -1.53],
    [0.321, 13.0, 0.11, 1.24],  [0.374, 1.9,  0.08, 0.29],
    [0.423, 2.2,  0.08, 0.35],  [0.469, 2.6,  0.08, -0.34],
    [0.503, 20.0, 0.13, 2.00],  [0.560, 4.1,  0.09, 1.06],
    [0.598, 17.6, 0.12, 1.82],  [0.656, 8.9,  0.10, -0.98],
    [0.693, 15.5, 0.11, 1.72],  [0.739, 17.9, 0.12, 1.99],
    [0.783, 18.8, 0.12, 1.81],  [0.839, 8.9,  0.10, 0.66],
    [0.890, 5.2,  0.08, -1.98], [0.936, 16.6, 0.11, -1.89],
  ];

  void _drawLeaf(Canvas c, Offset o, double angle, double len, double w, Paint p) {
    c.save(); c.translate(o.dx, o.dy); c.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.4, -w, len, 0)
      ..quadraticBezierTo(len * 0.6, w, 0, 0)
      ..close();
    c.drawPath(path, p);
    c.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _primary;
    int index = 0;
    for (final b in _bamboos) {
      index++;
      if (isMobile && index % 3 != 0) continue;
      final baseX = size.width * (b[0] as double);
      final w = b[1] as double;
      final deg = b[3] as double;
      final h = size.height;
      final double baseOp = b[2] as double;
      final op = isMobile ? baseOp * 0.4 : baseOp;
      final x = ((baseX + animationValue * size.width * (op * 8)) % size.width);
      final sway = math.sin((animationValue * math.pi * 4) + (x * 0.01)) * 0.015;
      final rad = (deg * math.pi / 180) + sway;
      paint.color = _primary.withOpacity(op);
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