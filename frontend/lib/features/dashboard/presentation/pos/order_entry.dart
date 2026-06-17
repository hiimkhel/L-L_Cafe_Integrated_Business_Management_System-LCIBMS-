import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/features/checkout/admin/presentation/checkout_screen.dart';
import 'package:frontend/features/dashboard/presentation/pos/online_orders_screen.dart';
import 'package:frontend/core/models/menu_item.dart';
import 'package:frontend/core/services/menu_service.dart';
import 'package:frontend/features/orders/presentation/pos/screens/order_history_screen.dart';
import 'package:frontend/features/orders/presentation/pos/screens/order_queue_screen.dart';
import 'package:frontend/core/models/menu_category.dart';
import 'package:frontend/core/utils/order_num_utils.dart';
import 'package:frontend/core/services/pos/order_service.dart';

class POSOrderScreen extends StatefulWidget {
  const POSOrderScreen({super.key});

  @override
  State<POSOrderScreen> createState() => _POSOrderScreenState();
}

class _POSOrderScreenState extends State<POSOrderScreen> {
  List<MenuItem> menuItems = [];
  List<MenuCategory> categories = [];
  int _nextOrderId = 1;
  Timer? _countTimer;

  List<Map<String, dynamic>> orderItems = [];

  bool isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _orderType = 'DINE IN';

  int _pendingOnlineCount = 0;
  bool _loadingCount = false;

  @override
  void initState() {
    super.initState();
    loadMenu();
    _fetchPendingOnlineCount();
    _countTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchPendingOnlineCount();
    });
  }

  Future<void> loadMenu() async {
    try {
      final results = await Future.wait([
        MenuService.fetchMenu(),
        MenuService.fetchCategories(),
        MenuService.fetchNextOrderNumber(),
      ]);

      final items = results[0] as List<MenuItem>;
      final cats = results[1] as List<MenuCategory>;

      setState(() {
        menuItems = items;
        categories = cats;
        isLoading = false;
        _nextOrderId = results[2] as int;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error loading menu: $e");
    }
  }

  Future<void> _fetchPendingOnlineCount() async {
    setState(() => _loadingCount = true);
    try {
      final count = await OrderService().getPendingCount();
      if (!mounted) return;
      setState(() {
        _pendingOnlineCount = count;
        _loadingCount = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingCount = false);
    }
  }

  String getCategoryName(int id) {
    return categories
        .firstWhere(
          (c) => c.id == id,
          orElse: () => MenuCategory(id: 0, name: "Unknown"),
        )
        .name;
  }

  double getSubtotal() {
    double subtotal = 0;
    for (var item in orderItems) {
      subtotal += item['price'] * item['qty'];
    }
    return subtotal;
  }

  double getTotal() => getSubtotal();

  @override
  void dispose() {
    _countTimer?.cancel();
    super.dispose();
  }

  // ── Breakpoint helpers ───────────────────────────────────────────────────────
  bool _isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < 900;

  int _gridCrossAxisCount(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // The menu panel is ~2/3 of the screen
    final panelW = w * 2 / 3;
    if (panelW < 500) return 2;
    if (panelW < 700) return 3;
    return 4;
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final compact = _isCompact(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _orderHeader(compact),
          Expanded(
            child: compact
                ? _compactLayout()
                : Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _searchBar(),
                            _categoriesRow(),
                            const SizedBox(height: 10),
                            Expanded(child: _itemButtons()),
                          ],
                        ),
                      ),
                      Expanded(flex: 1, child: _finalizeOrderSection()),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// On narrow screens the cart slides up as a bottom sheet trigger
  Widget _compactLayout() {
    return Stack(
      children: [
        Column(
          children: [
            _searchBar(),
            _categoriesRow(),
            const SizedBox(height: 10),
            Expanded(child: _itemButtons()),
            // Compact cart summary bar
            _compactCartBar(),
          ],
        ),
      ],
    );
  }

  Widget _compactCartBar() {
    final total = getTotal();
    final count = orderItems.fold<int>(0, (sum, e) => sum + (e['qty'] as int));

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (_, scrollController) => Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: _finalizeOrderSection(scrollController: scrollController),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.receiptDark.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'VIEW ORDER',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Text(
              '₱${total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Order Header ─────────────────────────────────────────────────────────────
  Widget _orderHeader(bool compact) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 24,
        vertical: compact ? 12 : 17,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.primary)),
      ),
      child: Row(
        children: [
          // Brand text — hide tagline on very compact headers
          Flexible(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: compact ? 16 : 21,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: "L&L CAFE ",
                    style: TextStyle(color: AppColors.secondary),
                  ),
                  TextSpan(
                    text: "MAIN COUNTER",
                    style: TextStyle(color: AppColors.primary),
                  ),
                  if (!compact)
                    TextSpan(
                      text: "\nMAKING GOOD FOOD FOR PEOPLE'S HAPPINESS",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        letterSpacing: .9,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Spacer(),

          // Header action buttons — collapse labels on compact
          _headerBtns(
            icon: Icon(Icons.queue, color: AppColors.primary, size: 13),
            label: compact ? 'QUEUE' : 'ORDER QUEUE',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => OrderQueueScreen()));
            },
          ),
          const SizedBox(width: 8),
          _headerBtns(
            icon: Icon(Icons.description_outlined,
                color: AppColors.primary, size: 13),
            label: 'REGISTRY',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => OrderHistoryScreen()));
            },
          ),
          const SizedBox(width: 8),
          _headerBtns(
            icon: Icon(Icons.laptop_mac_outlined,
                color: AppColors.primary, size: 13),
            label: compact ? 'ONLINE' : 'ONLINE ORDERS',
            badgeCount: _pendingOnlineCount,
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const OnlineOrdersScreen(),
              );
            },
          ),

          const SizedBox(width: 14),
          Container(width: 1.5, height: 32, color: AppColors.tertiary),
          const SizedBox(width: 14),

          // Avatar + role
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(17),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child:
                  Image.asset("assets/images/lnl.jpg", fit: BoxFit.cover),
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "L&L CASHIER",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.receiptDark,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "SHIFT ACTIVE",
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Header Button ─────────────────────────────────────────────────────────────
  Widget _headerBtns({
    Icon? icon,
    required String label,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon, const SizedBox(width: 4)],
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (badgeCount != null && badgeCount > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                constraints:
                    const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeCount > 99 ? "99+" : badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────────
  Widget _searchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 22, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'SEARCH ORDERS',
                hintStyle: TextStyle(
                  color: AppColors.receiptDark.withOpacity(.7),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Categories Row ────────────────────────────────────────────────────────────
  Widget _categoriesRow() {
    return SizedBox(
      height: 48,
      child: ScrollConfiguration(
        behavior: const _NoGlowScrollBehavior(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            final label = i == 0 ? "All" : categories[i - 1].name;
            final isSelected = label == _selectedCategory;

            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Item Grid ─────────────────────────────────────────────────────────────────
  Widget _itemButtons() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredItems = menuItems.where((item) {
      final matchesCategory = _selectedCategory == 'All'
          ? true
          : categories
                  .firstWhere((c) => c.id == item.categoryId)
                  .name ==
              _selectedCategory;
      final matchesSearch =
          item.name.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = _gridCrossAxisCount(context);
        // Tighten child ratio on narrow panels so images don't overflow
        final ratio = crossCount <= 2 ? 0.85 : 1.0;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: ratio,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) =>
              _itemCard(filteredItems[index], constraints),
        );
      },
    );
  }

  // ── Item Card ─────────────────────────────────────────────────────────────────
  Widget _itemCard(MenuItem item, BoxConstraints parentConstraints) {
    final currentOrderIndex =
        orderItems.indexWhere((e) => e['id'] == item.id);
    final currentQty = currentOrderIndex >= 0
        ? orderItems[currentOrderIndex]['qty'] as int
        : 0;
    final isSelected = currentQty > 0;

    String formatMoney(dynamic value) {
      final v = double.tryParse(value.toString()) ?? 0.0;
      return '₱${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Scale the circular image relative to the card width
        final imgSize = (constraints.maxWidth * 0.48).clamp(48.0, 110.0);

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.secondary
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.receiptDark
                    .withOpacity(isSelected ? 0.1 : 0.04),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Circular image ────────────────────────────────
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: imgSize,
                        height: imgSize,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary.withOpacity(0.3)
                                : Colors.grey.shade200,
                            width: 2,
                          ),
                          image: (item.imageUrl != null &&
                                  item.imageUrl!.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(item.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (item.imageUrl == null ||
                                item.imageUrl!.isEmpty)
                            ? Icon(Icons.fastfood_rounded,
                                size: imgSize * 0.3,
                                color: Colors.grey.shade400)
                            : null,
                      ),
                    ),

                    const Spacer(),

                    // ── Name & price ──────────────────────────────────
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatMoney(item.price),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.receiptDark.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Add / Added button ────────────────────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: !isSelected
                          ? SizedBox(
                              key: const ValueKey('add_btn'),
                              width: double.infinity,
                              height: 34,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  setState(() {
                                    orderItems.add({
                                      'id': item.id,
                                      'name': item.name,
                                      'price': double.parse(
                                          item.price.toString()),
                                      'qty': 1,
                                      'image_url': item.imageUrl,
                                    });
                                  });
                                },
                                child: const Text(
                                  "ADD",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              key: const ValueKey('added_state'),
                              width: double.infinity,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.secondary, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  "ADDED ✓",
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: AppColors.secondary,
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 11),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Finalize Order Section ────────────────────────────────────────────────────
  Widget _finalizeOrderSection({ScrollController? scrollController}) {
    final formattedOrderNum =
        OrderNumberUtils.formatOrderNumber(_nextOrderId, _orderType);

    return Container(
      margin: const EdgeInsets.fromLTRB(5, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(88),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.shopping_bag_outlined,
                      size: 20, color: AppColors.secondary),
                ),
                const SizedBox(width: 12),
                const Text(
                  'CURRENT ORDER',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _orderType == 'ONLINE'
                        ? Colors.blue
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    formattedOrderNum,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Order items list
          Expanded(
            child: orderItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.shopping_cart_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            'Start creating an order',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Add items from the menu to begin',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    itemCount: orderItems.length,
                    itemBuilder: (context, index) {
                      final item = orderItems[index];
                      return _orderItem(
                        index: index,
                        name: item['name'],
                        price:
                            "₱${(item['price'] * item['qty']).toStringAsFixed(2)}",
                        qty: item['qty'],
                      );
                    },
                  ),
          ),

          const Divider(height: 1),

          // Order type
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER TYPE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _orderTypeBtn(
                        icon: Icons.restaurant,
                        label: 'DINE IN',
                        isSelected: _orderType == 'DINE IN',
                        isFirst: true,
                        isLast: false,
                        onTap: () =>
                            setState(() => _orderType = 'DINE IN'),
                      ),
                    ),
                    Expanded(
                      child: _orderTypeBtn(
                        icon: Icons.shopping_cart,
                        label: 'TAKE OUT',
                        isSelected: _orderType == 'TAKE OUT',
                        isFirst: false,
                        isLast: true,
                        onTap: () =>
                            setState(() => _orderType = 'TAKE OUT'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Totals
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SUBTOTAL',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '₱${getSubtotal().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Divider(height: 1),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.receiptDark,
                      ),
                    ),
                    Text(
                      '₱${getTotal().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                // Clear button
                GestureDetector(
                  onTap: () {
                    if (orderItems.isEmpty) return;
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Clear Order'),
                        content: const Text(
                            'Are you sure you want to remove all items?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() => orderItems.clear());
                              Navigator.pop(context);
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                // Finalize button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutConfirmationScreen(
                            orderItems: orderItems,
                            orderType: _orderType,
                            orderOrderId: _nextOrderId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.receiptDark.withOpacity(0.25),
                            offset: const Offset(2, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(CupertinoIcons.checkmark_shield,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'FINALIZE ORDER',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Order Item Row ────────────────────────────────────────────────────────────
  Widget _orderItem({
    required String name,
    required String price,
    required int qty,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.receiptDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => orderItems.removeAt(index)),
                child: Icon(Icons.close,
                    size: 16, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Qty controls
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.receiptDark.withOpacity(.15),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _qtyBtn(Icons.remove, () {
                      setState(() {
                        if (orderItems[index]['qty'] > 1) {
                          orderItems[index]['qty']--;
                        } else {
                          orderItems.removeAt(index);
                        }
                      });
                    }),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '$qty',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.receiptDark,
                        ),
                      ),
                    ),
                    _qtyBtn(Icons.add, () {
                      setState(() => orderItems[index]['qty']++);
                    }),
                  ],
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 26,
        height: 26,
        child: Icon(icon, size: 15, color: AppColors.primary),
      ),
    );
  }

  Widget _orderTypeBtn({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isFirst,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary
              : AppColors.background.withOpacity(0.4),
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(10) : Radius.zero,
            right: isLast ? const Radius.circular(10) : Radius.zero,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  isSelected ? AppColors.white : AppColors.primary,
              size: 13,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color:
                    isSelected ? AppColors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}