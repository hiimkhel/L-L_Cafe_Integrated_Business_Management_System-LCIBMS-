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

  // Cart State Handler
  List<Map<String, dynamic>> orderItems = [];

  bool isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  String _orderType = 'DINE IN';

  int _pendingOnlineCount = 0;
  bool _loadingCount = false;

  // Breakpoint below which the menu/cart layout stacks instead of
  // sitting side-by-side. Anything narrower than this can't comfortably
  // fit both panels at once. Raised from 760 to 900: the cart panel
  // needs roughly 320-360px of usable width for its order-type buttons,
  // subtotal row, and the delete + finalize button row to sit
  // comfortably without their text clipping or wrapping awkwardly.
  static const double _stackBreakpoint = 900;

  // Minimum width the cart panel is allowed to shrink to in the
  // side-by-side layout. Below this, "FINALIZE ORDER" and the subtotal
  // figures start to crowd each other even though nothing technically
  // overflows.
  static const double _cartPanelMinWidth = 320;

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

  // Handle calculation of subtotal price from cart items
  double getSubtotal() {
    double subtotal = 0;
    for (var item in orderItems) {
      subtotal += item['price'] * item['qty'];
    }
    return subtotal;
  }


  double getTotal() {
    return getSubtotal();
  }

  @override
  void dispose() {
    _countTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _orderHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < _stackBreakpoint;

                final menuPanel = Column(
                  children: [
                    _searchBar(),
                    _categoriesRow(),
                    const SizedBox(height: 10),
                    // On narrow screens the menu can't be an Expanded
                    // inside a scrolling Column (unbounded height), so
                    // give it a fixed viewport height instead.
                    isNarrow
                        ? SizedBox(
                            height: 520,
                            child: _itemButtons(),
                          )
                        : Expanded(child: _itemButtons()),
                  ],
                );

                final cartPanel = _finaizeOrderSection(
                  // On narrow/stacked layouts the cart section also needs
                  // a bounded height since it's no longer inside an
                  // Expanded flex row.
                  fixedHeight: isNarrow ? 640 : null,
                );

                if (isNarrow) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        menuPanel,
                        cartPanel,
                      ],
                    ),
                  );
                }

                // Compute explicit pixel widths instead of trusting flex
                // ratios alone, so the cart panel can never be squeezed
                // below its usable minimum — and so the menu panel takes
                // up exactly what's left, never more than the viewport
                // actually has. ClipRect is a defensive safety net: even
                // if some future change makes a child report a larger
                // intrinsic width than its slot, this guarantees nothing
                // visually bleeds past the screen edge.
                final cartWidthUpperBound =
                    (constraints.maxWidth * 0.45).clamp(_cartPanelMinWidth, double.infinity);
                final cartWidth = (constraints.maxWidth / 3)
                    .clamp(_cartPanelMinWidth, cartWidthUpperBound);
                final menuWidth = constraints.maxWidth - cartWidth;

                return ClipRect(
                  child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      SizedBox(width: menuWidth, child: menuPanel),
                      SizedBox(width: cartWidth, child: cartPanel),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //----------------------------------------Order Header-----------------------------------------------------------
  Widget _orderHeader() {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.primary)),
      ),
      child: Row(
        children: [
          // Zone 1: title. flex:5 so it isn't artificially squeezed to
          // a tiny fraction of the row by the trailing cluster's much
          // higher flex weight (see note below) — it still shrinks with
          // ellipsis if the title's natural width genuinely exceeds its
          // share, but normally just takes the space its content needs.
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: "L&L CAFE ",
                        style: TextStyle(color: AppColors.secondary),
                      ),
                      TextSpan(
                        text: "MAIN COUNTER",
                        style: TextStyle(color: AppColors.primary),
                      ),
                      TextSpan(
                        text: "\nMAKING GOOD FOOD FOR PEOPLE'S HAPPINESS",
                        style: TextStyle(
                          fontSize: 12,
                          //fontWeight: FontWeight.normal,
                          color: Colors.black,
                          letterSpacing: .9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // flex:1 here only consumes whatever space the trailing
          // cluster doesn't need — see the note on the cluster's
          // Flexible below for why the flex weights are set this way.
          const Spacer(flex: 1),

          // Trailing cluster: nav buttons + divider + logo + cashier
          // info, all grouped as one unit at the far right.
          //
          // Previously this used a horizontally-scrolling row with
          // reverse:true as the overflow fallback. The problem: when the
          // cluster didn't fully fit, the scroll defaulted to showing
          // the *end* of the content (logo/cashier) and silently
          // scrolled "ORDER QUEUE" mostly out of view with no scroll
          // indicator — it looked clipped/broken rather than
          // responsive, and the button was still there but effectively
          // hidden and hard to tap.
          //
          // Fixed by measuring available width and switching the nav
          // buttons to icon-only (label hidden) once space is tight.
          // This reclaims width without ever hiding a button entirely —
          // every control stays visible and tappable at any size.
          //
          // flex:20 (vs Spacer's flex:1) matters: Flexible defaults to
          // FlexFit.loose, so a Row divides remaining space between
          // flex children by their ratio and each child's *maximum*
          // available width is its share of that split — it can still
          // be smaller (loose), but never larger. With both this and
          // Spacer at flex:1, the cluster would be capped at half the
          // remaining space even when the title leaves much more room
          // free, forcing icon-only mode (and scrolling) far sooner
          // than necessary. flex:20 means Spacer only ever claims
          // genuine leftover space, while the cluster can claim nearly
          // all of it when needed.
          Flexible(
            flex: 20,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Rough width budget: full labels need ~330px for the
                // three buttons; below that, drop to icon-only buttons
                // (~140px) which still comfortably fits alongside the
                // divider and logo block down to fairly narrow widths.
                final bool compact = constraints.maxWidth < 330;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _headerBtns(
                        icon: Icon(Icons.queue, color: AppColors.primary, size: 13),
                        label: 'ORDER QUEUE',
                        compact: compact,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderQueueScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 11),
                      _headerBtns(
                        icon: Icon(
                          Icons.description_outlined,
                          color: AppColors.primary,
                          size: 13,
                        ),
                        label: 'REGISTRY',
                        compact: compact,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 11),
                      _headerBtns(
                        icon: Icon(
                          Icons.laptop_mac_outlined,
                          color: AppColors.primary,
                          size: 13,
                        ),
                        label: 'ONLINE ORDERS',
                        badgeCount: _pendingOnlineCount,
                        compact: compact,
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const OnlineOrdersScreen(),
                          );
                        },
                      ),
                      const SizedBox(width: 19),
                      Container(width: 1.5, height: 32, color: AppColors.tertiary),
                      const SizedBox(width: 19),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset("assets/images/lnl.jpg", fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
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
                              fontWeight: FontWeight.normal,
                              color: AppColors.secondary,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //---------------------------------------HeadBtn-----------------------------------------------------------
 //--------------------------------------- Header Button -----------------------------------------------------------
  Widget _headerBtns({
    Icon? icon,
    required String label,
    required VoidCallback onTap,
    int? badgeCount, // optional notification badge
    bool compact = false, // icon-only mode for tight widths
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 9 : 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon,
                  if (!compact) const SizedBox(width: 4),
                ],
                // Label is hidden (not just shrunk) in compact mode —
                // the icon alone still makes the button recognizable
                // and fully tappable, which is what matters; this is
                // the key change from the old scroll-based approach,
                // where the button was still "there" but effectively
                // invisible and hard to reach.
                if (!compact)
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

          // Notification badge
          if (badgeCount != null && badgeCount > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.white,
                    width: 2,
                  ),
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
  //----------------------------------------Search Bar-----------------------------------------------------------
  Widget _searchBar() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 25, color: AppColors.primary),
          const SizedBox(width: 7),
          Expanded(
            child: TextField(
              // Search  logic
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
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

  //----------------------------------------Categories Row-----------------------------------------------------------
  Widget _categoriesRow() {
    return SizedBox(
      height: 48,
      child: ScrollConfiguration(
        behavior: const _NoGlowScrollBehavior(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, i) {
            final isAll = i == 0;

            final label = isAll ? "All" : categories[i - 1].name;
            final isSelected = label == _selectedCategory;

            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
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
                      color: isSelected ? AppColors.white : AppColors.primary,
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

  //----------------------------------------Item Buttons-----------------------------------------------------------
  Widget _itemButtons() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredItems =
        menuItems.where((item) {
          final matchesCategory =
              _selectedCategory == 'All'
                  ? true
                  : categories
                          .firstWhere((c) => c.id == item.categoryId)
                          .name ==
                      _selectedCategory;

          final matchesSearch = item.name.toLowerCase().contains(_searchQuery);

          return matchesCategory && matchesSearch;
        }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Pick a column count that keeps each card at a reasonable
        // minimum width, instead of always forcing 4 columns regardless
        // of how much space is actually available.
        const double minCardWidth = 170;
        const double gridPadding = 24 * 2;
        const double spacing = 20;

        final usableWidth = constraints.maxWidth - gridPadding;
        int crossAxisCount =
            ((usableWidth + spacing) / (minCardWidth + spacing)).floor();
        crossAxisCount = crossAxisCount.clamp(1, 4);

        final cardWidth =
            (usableWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;

        // Compute the row height directly from what the card content
        // actually needs, instead of guessing via a fixed aspect ratio.
        // This is what makes the grid immune to zoom/font-scale: the
        // moment text or system font size grows, this number grows with
        // it, so the card is never forced shorter than its content (the
        // old bug — a Spacer can't go negative, so it silently overflows
        // by whatever the deficit is).
        final cardHeight = _itemCardHeight(cardWidth, context);

        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: cardHeight,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return _itemCard(item, cardWidth);
          },
        );
      },
    );
  }

  // Measures the height the card content needs at the given width, using
  // TextPainter to get Flutter's *actual* rendered line height for the
  // exact TextStyle and textScaler in play — rather than a hand-rolled
  // "fontSize * height" guess, which doesn't account for font metrics
  // (ascent/descent/leading) and was the source of the residual ~5px
  // overflow on two-line item names.
  double _itemCardHeight(double cardWidth, BuildContext context) {
    const double cardPadding = 14 * 2;
    final double imageSize = (cardWidth * 0.62).clamp(56.0, 120.0);

    final textScaler = MediaQuery.textScalerOf(context);

    double measureLineHeight(TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: 'Ay', style: style), // any non-empty text; line height is style-driven, not content-driven
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      return painter.height;
    }

    // Measure a single line directly rather than guessing a string that
    // we hope wraps to exactly 2 lines (that was the actual bug: if the
    // test phrase happened to fit on 1 line at a given cardWidth, the
    // budget silently undershot again, the same failure mode as before
    // just relocated). Line height for a fixed TextStyle is constant
    // regardless of content, so multiplying by the known max line count
    // is exact, not a guess.
    const nameStyle =
        TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.2);
    const priceStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.bold);

    final double nameBlockHeight = measureLineHeight(nameStyle) * 2; // maxLines: 2 in the actual card
    final double priceHeight = measureLineHeight(priceStyle);

    const double topGap = 6;
    const double imageToSpacerGap = 16; // visual breathing room replacing Spacer
    const double nameToPriceGap = 4;
    const double priceToButtonGap = 12;
    const double buttonHeight = 38;

    // Safety margin to absorb any sub-pixel rounding or unaccounted-for
    // discrepancy between this measurement pass and the actual render
    // pass — better to have a few pixels of harmless empty space at the
    // bottom of the card than risk the overflow banner reappearing.
    const double safetyMargin = 6;

    return cardPadding +
        topGap +
        imageSize +
        imageToSpacerGap +
        nameBlockHeight +
        nameToPriceGap +
        priceHeight +
        priceToButtonGap +
        buttonHeight +
        safetyMargin;
  }

Widget _itemCard(MenuItem item, double cardWidth) {

  final currentOrderIndex = orderItems.indexWhere((e) => e['id'] == item.id);
  final currentQty = currentOrderIndex >= 0 ? orderItems[currentOrderIndex]['qty'] as int : 0;
  final isSelected = currentQty > 0;

  // Formatting utility inside the layout scope
  String formatMoney(dynamic value) {
    final v = double.tryParse(value.toString()) ?? 0.0;
    return '₱${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  return Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isSelected ? AppColors.secondary : Colors.transparent,
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.receiptDark.withOpacity(isSelected ? 0.1 : 0.04),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ],
    ),
    child: Stack(
      children: [

        Padding(
          padding: const EdgeInsets.all(14),
          child: Builder(
            builder: (context) {
              // Image scales with the card's own width instead of being
              // pinned to 120x120, so it no longer overflows on smaller
              // cards (e.g. when the grid switches to more columns).
              // cardWidth is passed in from the grid's own column-width
              // calculation, so this matches _itemCardHeight exactly —
              // no separate measurement that could drift out of sync.
              final imageSize = (cardWidth * 0.62).clamp(56.0, 120.0);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),

                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.secondary.withOpacity(0.3)
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                        image: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(item.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (item.imageUrl == null || item.imageUrl!.isEmpty)
                          ? Icon(
                              Icons.fastfood_rounded,
                              size: imageSize * 0.27,
                              color: Colors.grey.shade400,
                            )
                          : null,
                    ),
                  ),

                  // Fixed gap instead of Spacer. A Spacer can't shrink
                  // below zero, so if content is taller than the row
                  // (e.g. due to zoom or text scaling), it silently
                  // overflows by the deficit — this is exactly what was
                  // happening at 125% zoom. mainAxisExtent on the grid
                  // now guarantees the row is always tall enough for
                  // this fixed-budget layout, so no Spacer is needed.
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.receiptDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatMoney(item.price),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.receiptDark.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── SECONDARY ACTION BUTTON CONTROLS ──────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: !isSelected
                        ? SizedBox(
                            key: const ValueKey('add_btn'),
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                setState(() {
                                  orderItems.add({
                                    'id': item.id,
                                    'name': item.name,
                                    'price': double.parse(item.price.toString()),
                                    'qty': 1,
                                    'image_url': item.imageUrl,
                                  });
                                });
                              },
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "ADD TO CART",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            key: const ValueKey('added_state'),
                            width: double.infinity,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.12), // Elegant tint fallback
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.secondary, width: 1),
                            ),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "ADDED TO CART",
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),

        if (isSelected)
          Positioned(
            top: 10,
            right: 10,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.check, color: Colors.white, size: 11),
            ),
          ),
      ],
    ),
  );
}
  //----------------------------------------Finalize Order Section-----------------------------------------------------------
  Widget _finaizeOrderSection({double? fixedHeight}) {

    String formattedOrderNum = OrderNumberUtils.formatOrderNumber(_nextOrderId, _orderType);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: fixedHeight == null ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 21),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(88),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 22,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 15),
              // Allow the title to shrink instead of pushing the badge
              // off-screen on narrow widths.
              Expanded(
                child: Text(
                  'CURRENT ORDER',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.receiptDark,
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  // Dynamic background based on order type
                  color: _orderType == 'ONLINE' ? Colors.blue : AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  formattedOrderNum,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white, // Inverted for better readability
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 1),

        fixedHeight == null
            ? Expanded(child: _orderListOrEmptyState())
            : SizedBox(height: 220, child: _orderListOrEmptyState()),

        const Divider(height: 1, color: Color.fromARGB(255, 237, 236, 236)),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
                      onTap: () {
                        setState(() {
                          _orderType = 'DINE IN';
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _orderTypeBtn(
                      icon: Icons.shopping_cart,
                      label: 'TAKE OUT',
                      isSelected: _orderType == 'TAKE OUT',
                      isFirst: false,
                      isLast: true,
                      onTap: () {
                        setState(() {
                          _orderType = 'TAKE OUT';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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

              const SizedBox(height: 8),
              const Divider(
                height: 1,
                color: Color.fromARGB(255, 237, 236, 236),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL ORDER COST',
                    style: TextStyle(
                      fontSize: 15,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (orderItems.isEmpty) return;

                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Clear Order'),
                          content: const Text(
                            'Are you sure you want to remove all items?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  orderItems.clear();
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the next screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutConfirmationScreen( orderItems: orderItems, orderType: _orderType, orderOrderId: _nextOrderId),
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.receiptDark,
                          offset: Offset(3, 4),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.checkmark_shield,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'FINALIZE ORDER',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
    );

    return Container(
      height: fixedHeight,
      // Right margin matches the header's horizontal padding (24px) so
      // the cart card's right edge lines up with the logo block above
      // it instead of sitting 10px further left, which is what was
      // reading as "a few extra px of space" on the right side.
      margin: const EdgeInsets.fromLTRB(5, 14, 24, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: content,
    );
  }

  Widget _orderListOrEmptyState() {
    return orderItems.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
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
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderItems.length,
            itemBuilder: (context, index) {
              final item = orderItems[index];

              return _orderItem(
                index: index,
                name: item['name'],
                price: "₱${item['price'] * item['qty']}",
                qty: item['qty'],
              );
            },
          );
  }

  Widget _orderItem({
    required String name,
    required String price,
    required int qty,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
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
              // Long item names now truncate instead of overflowing into
              // the close button.
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.receiptDark,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 18, color: AppColors.primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    orderItems.removeAt(index);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.receiptDark.withOpacity(.2),
                      offset: Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      setState(() {
                        orderItems[index]['qty']++;
                      });
                    }),
                  ],
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 14,
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
        width: 28,
        height: 28,
        child: Icon(icon, size: 16, color: AppColors.primary),
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
          color:
              isSelected
                  ? AppColors.secondary
                  : AppColors.background.withOpacity(0.4),
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? Radius.circular(10) : Radius.zero,
            right: isLast ? Radius.circular(10) : Radius.zero,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.primary,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Function for overflowing categories
class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}