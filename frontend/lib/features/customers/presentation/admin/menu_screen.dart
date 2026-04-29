import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/constants/cart_provider.dart';

const double _kMobile = 900;
const double _kDesktopMaxWidth = 1400;
const Color _bgBeige   = Color(0xFFEFE2C9);
const Color _bgDark    = Color(0xFF2D2A26);
const Color _primary   = Color(0xFF758C6D);
const Color _secondary = Color(0xFFA98258);

// ─────────────────────────────────────────────────────────────────────────────
// MENU ITEM MODEL
// ─────────────────────────────────────────────────────────────────────────────

enum StockStatus { inStock, outOfStock, limitedStock }

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> categories;
  final StockStatus stockStatus;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categories,
    this.stockStatus = StockStatus.inStock,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK DATA  (swap _kMenuItems with an API/Firestore fetch)
// ─────────────────────────────────────────────────────────────────────────────

const List<String> _kCategories = [
  'ALL', 'BEST SELLERS', 'FOODS', 'PARTY TRAY',
  'WAFFLES', 'COFFEE', 'NON-COFFEE DRINKS', 'FRAPPES',
];

final List<MenuItem> _kMenuItems = [
  MenuItem(
    id: 'm001', name: 'KITKAT OVERLOAD',
    description: 'Crispy bubble waffle loaded with KitKat and chocolate drizzle.',
    price: 130,
    imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&q=80',
    categories: ['WAFFLES', 'BEST SELLERS'],
  ),
  MenuItem(
    id: 'm002', name: 'KITKAT OREO',
    description: 'Crispy bubble waffle topped with KitKat, Oreo, and chocolate drizzle.',
    price: 110,
    imageUrl: 'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=400&q=80',
    categories: ['WAFFLES'],
  ),
  MenuItem(
    id: 'm003', name: 'CARAMEL BISCOFF',
    description: 'Crispy bubble waffle topped with caramel sauce and Biscoff crumbs.',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1576618148400-f54bed99fcfd?w=400&q=80',
    categories: ['WAFFLES', 'BEST SELLERS'],
  ),
  MenuItem(
    id: 'm004', name: 'PEPERO',
    description: 'Crispy bubble waffle loaded with crunchy Pepero sticks and chocolate drizzle.',
    price: 100,
    imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&q=80',
    categories: ['WAFFLES'],
  ),
  MenuItem(
    id: 'm005', name: 'DOUBLE PATTY BURGER',
    description: 'Juicy double beef patties with fresh lettuce, tomato, and signature sauce in a soft bun.',
    price: 200,
    imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80',
    categories: ['FOODS', 'BEST SELLERS'],
  ),
  MenuItem(
    id: 'm006', name: 'CHICKEN SANDWICH',
    description: 'Crispy chicken fillet with fresh lettuce, tomato, and creamy sauce in a soft bun.',
    price: 95,
    imageUrl: 'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=400&q=80',
    categories: ['FOODS'],
  ),
  MenuItem(
    id: 'm007', name: 'HOT HONEY SANDWICH',
    description: 'Crispy chicken with sweet-spicy honey drizzle, served with fresh veggies in a soft bun.',
    price: 115,
    imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400&q=80',
    categories: ['FOODS', 'BEST SELLERS'],
  ),
  MenuItem(
    id: 'm008', name: 'HONEY BBQ SANDWICH',
    description: 'Crispy chicken with smoky honey BBQ powder, fresh lettuce, and tomato in a soft bun.',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1553909489-cd47e0907980?w=400&q=80',
    categories: ['FOODS'],
  ),
  MenuItem(
    id: 'm009', name: 'ICED AMERICANO',
    description: 'Bold espresso poured over ice for a clean, refreshing coffee kick.',
    price: 85,
    imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400&q=80',
    categories: ['COFFEE'],
  ),
  MenuItem(
    id: 'm010', name: 'CARAMEL LATTE',
    description: 'Smooth espresso blended with steamed milk and a drizzle of sweet caramel.',
    price: 100,
    imageUrl: 'https://images.unsplash.com/photo-1572286258217-215cf8e2320e?w=400&q=80',
    categories: ['COFFEE', 'BEST SELLERS'],
  ),
  MenuItem(
    id: 'm011', name: 'MATCHA FRAPPE',
    description: 'Premium matcha blended with milk and ice, topped with whipped cream.',
    price: 130,
    imageUrl: 'https://images.unsplash.com/photo-1594631661960-34506e595b65?w=400&q=80',
    categories: ['FRAPPES'],
  ),
  MenuItem(
    id: 'm012', name: 'STRAWBERRY FIZZ',
    description: 'Fresh strawberry syrup mixed with sparkling water and a squeeze of lemon.',
    price: 75,
    imageUrl: 'https://images.unsplash.com/photo-1497534446932-c925b458314e?w=400&q=80',
    categories: ['NON-COFFEE DRINKS'],
  ),
  MenuItem(
    id: 'm013', name: 'BIRTHDAY CAKE TRAY',
    description: 'Full party tray of assorted bite-sized cakes, perfect for celebrations.',
    price: 850,
    imageUrl: 'https://images.unsplash.com/photo-1464349095431-e9a21285b5f3?w=400&q=80',
    categories: ['PARTY TRAY'],
  ),
  MenuItem(
    id: 'm014', name: 'WAFFLE PARTY TRAY',
    description: 'A platter of assorted mini bubble waffles with dipping sauces.',
    price: 650,
    imageUrl: 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400&q=80',
    categories: ['PARTY TRAY', 'WAFFLES'],
    stockStatus: StockStatus.limitedStock,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// MENU SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<MenuItem> get _filteredItems => _kMenuItems.where((item) {
        final matchCat = _selectedCategory == 'ALL' ||
            item.categories.contains(_selectedCategory);
        final matchSearch = _searchQuery.isEmpty ||
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.description.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchCat && matchSearch;
      }).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Add to cart ──────────────────────────────────────────────────────────

  void _addToCart(MenuItem menuItem) {
    CartProvider.of(context).add(CartItem(
      id: menuItem.id,
      name: menuItem.name,
      category: menuItem.categories.first,
      price: menuItem.price,
      originalPrice: menuItem.price,
      imageUrl: menuItem.imageUrl,
    ));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${menuItem.name} ADDED TO CART',
          style: const TextStyle(
            fontFamily: 'Urbanist', fontWeight: FontWeight.w800, letterSpacing: 1,
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
    // Subscribes to cart so navbar badge updates live
    final cart = CartProvider.of(context);

    return Scaffold(
      backgroundColor: _bgBeige,
      appBar: CustomerNavbar(
        activeRoute: '/menu',
        cartCount: 0,
        notifCount: 1,
        userName: 'JANE DOE',
        userClientId: 'CLIENT #LL-00124',
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
                        constraints:
                            const BoxConstraints(maxWidth: _kDesktopMaxWidth),
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
        if (items.isEmpty) _buildEmptyState() else _buildGrid(items, crossAxisCount: 4),
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
          'L&L CAFE STRUCTURAL CATALOG',
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
        if (items.isEmpty) _buildEmptyState() else _buildGrid(items, crossAxisCount: 2),
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
        onChanged: (val) => setState(() => _searchQuery = val),
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
          prefixIcon:
              Icon(Icons.search_rounded, color: _bgDark.withOpacity(0.4), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: _bgDark.withOpacity(0.4), size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
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
    final chips = _kCategories
        .map((cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _CategoryChip(
                label: cat,
                selected: _selectedCategory == cat,
                onTap: () => setState(() => _selectedCategory = cat),
              ),
            ))
        .toList();

    if (scrollable) {
      return SingleChildScrollView(
          scrollDirection: Axis.horizontal, child: Row(children: chips));
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
            Text(
              'NO ITEMS FOUND',
              style: TextStyle(
                fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 16, letterSpacing: 2.0,
                color: _bgDark.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search or category',
              style: TextStyle(
                fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
                fontSize: 13, color: _bgDark.withOpacity(0.3),
              ),
            ),
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
              ? [
                  BoxShadow(
                      color: _secondary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist', fontWeight: FontWeight.w800,
            fontSize: 11, letterSpacing: 1.5,
            color: selected ? Colors.white : _bgDark.withOpacity(0.7),
          ),
        ),
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

  const _MenuCard(
      {required this.item, required this.onAddToCart, required this.isMobile});

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
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
        CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleAddToCart() async {
    await _bounceCtrl.forward();
    await _bounceCtrl.reverse();
    widget.onAddToCart();
  }

  Color get _stockColor {
    switch (widget.item.stockStatus) {
      case StockStatus.inStock:      return _primary;
      case StockStatus.limitedStock: return _secondary;
      case StockStatus.outOfStock:   return Colors.redAccent;
    }
  }

  String get _stockLabel {
    switch (widget.item.stockStatus) {
      case StockStatus.inStock:      return 'IN STOCK';
      case StockStatus.limitedStock: return 'LIMITED';
      case StockStatus.outOfStock:   return 'OUT OF STOCK';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOut = widget.item.stockStatus == StockStatus.outOfStock;

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
                // Stock badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _stockColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _stockLabel,
                      style: const TextStyle(
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w800,
                        fontSize: 8, letterSpacing: 1.0, color: Colors.white,
                      ),
                    ),
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
                                  : _secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              size: widget.isMobile ? 16 : 20,
                              color: isOut ? Colors.grey : _secondary,
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
// BAMBOO BACKGROUND (retained)
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
    [0.040, 13.0, 0.12, 1.53], [0.095, 7.0, 0.10, -1.84],
    [0.133, 14.0, 0.13, 1.45], [0.190, 9.0, 0.10, -0.72],
    [0.236, 9.5, 0.10, -0.71], [0.283, 13.0, 0.12, -1.53],
    [0.321, 13.0, 0.11, 1.24], [0.374, 1.9, 0.08, 0.29],
    [0.423, 2.2, 0.08, 0.35], [0.469, 2.6, 0.08, -0.34],
    [0.503, 20.0, 0.13, 2.00], [0.560, 4.1, 0.09, 1.06],
    [0.598, 17.6, 0.12, 1.82], [0.656, 8.9, 0.10, -0.98],
    [0.693, 15.5, 0.11, 1.72], [0.739, 17.9, 0.12, 1.99],
    [0.783, 18.8, 0.12, 1.81], [0.839, 8.9, 0.10, 0.66],
    [0.890, 5.2, 0.08, -1.98], [0.936, 16.6, 0.11, -1.89],
  ];

  void _drawLeaf(Canvas c, Offset o, double angle, double len, double w, Paint p) {
    c.save(); c.translate(o.dx, o.dy); c.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.4, -w, len, 0)
      ..quadraticBezierTo(len * 0.6, w, 0, 0)
      ..close();
    c.drawPath(path, p); c.restore();
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
      final x =
          ((baseX + animationValue * size.width * (op * 8)) % size.width);
      final sway =
          math.sin((animationValue * math.pi * 4) + (x * 0.01)) * 0.015;
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
      canvas.drawRect(
          Rect.fromLTWH(-w * 0.6, -w * 0.6, w * 1.2, w * 1.2), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BambooPainter old) =>
      old.animationValue != animationValue || old.isMobile != isMobile;
}