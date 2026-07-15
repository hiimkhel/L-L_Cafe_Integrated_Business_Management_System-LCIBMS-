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
import 'package:frontend/core/models/menu_item_variant.dart';
import 'package:frontend/core/widgets/variant_dialog.dart';
import 'package:frontend/core/services/pos/order_service.dart';
import 'package:frontend/core/models/flavor_models.dart';
import 'package:frontend/core/constants/cart_provider.dart';
import 'package:uuid/uuid.dart';          

class POSOrderScreen extends StatefulWidget {
  final Map<String, dynamic>? editingOrder;

  const POSOrderScreen({super.key, this.editingOrder});

  @override
  State<POSOrderScreen> createState() => _POSOrderScreenState();
}

class _POSOrderScreenState extends State<POSOrderScreen> {
  List<MenuItem> menuItems = [];
  List<MenuCategory> categories = [];
  int _nextOrderId = 1;
  Timer? _countTimer;
  int? editingOrderId;

  // Cart State Handler
  List<Map<String, dynamic>> orderItems = [];

  bool isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  String _orderType = 'DINE IN';

  int _pendingOnlineCount = 0;
  bool _loadingCount = false;

  final uuid = Uuid();

  @override
  void initState() {
    super.initState();

    loadMenu();
    _fetchPendingOnlineCount();

    if (widget.editingOrder != null) {
      loadOrderForEditing(widget.editingOrder!);
    }

    _countTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchPendingOnlineCount(),
    );
  }

  void loadOrderForEditing(Map<String, dynamic> order) {
    editingOrderId = order["id"];

    setState(() {
      orderItems.clear();

      for (final item in order["items"]) {
        orderItems.add({
          "cart_id": UniqueKey().toString(),

          "id": item["menu_item_id"],
          "name": item["name"],
          "category": item["category"],

          "price": double.parse(item["price"].toString()),
          "qty": item["qty"],

          "variant_id": item["variant"]?["id"],
          "variant_name": item["variant"]?["variant_name"],
          "variant_category": item["variant"]?["category"],

         "flavors": (item["flavors"] as List)
          .map((f) => Flavor.fromJson(f))
          .toList(),
        });
      }
    });
  }

 Future<void> _showCustomizeDialog(MenuItem item) async {
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => CustomizeItemDialog(item: item),
  );

  if (result == null) return;

  final MenuItemVariant? variant =
      result['variant'] as MenuItemVariant?;

  final List<Flavor> flavors =
      (result['flavors'] as List<Flavor>?) ?? [];

  setState(() {
    orderItems.add({
      'cart_id': uuid.v4(),

      'id': item.id,
      'name': item.name,

      // Base price for items without variants
      'price': variant?.price ?? item.price,

      // Variant information
      'variant_id': variant?.id,
      'variant_name': variant?.variantName,
      'variant_category': variant?.category,

      // Flavor information
      'flavors': flavors,

      'qty': 1,
    });
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
    Future<void> _updateEditedOrder() async {
      if (editingOrderId == null) return;

      final items = orderItems.map((item) {
        final price = (item["price"] as num).toDouble();
        final qty = item["qty"] as int;

        return {
          "menu_item_id": item["id"],
          "name": item["name"],
          "quantity": qty,
          "unit_price": price,
          "subtotal": price * qty,
          "variant_id": item["variant_id"],
          "flavors": item["flavors"],
        };
      }).toList();

      final total = items.fold<double>(
        0,
        (sum, item) => sum + item["subtotal"],
      );

      final success = await OrderService().modifyOrder(
        orderId: editingOrderId!,
        items: items,
        total: total,
      );

      if (!mounted) return;


      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order updated successfully."),
          ),
          
        );
          Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar( 
            content: Text("Failed to update order."),
          ),
        );
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
            child: Row(
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
                Expanded(flex: 1, child: _finaizeOrderSection()),
              ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
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
                        fontSize: 8,
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
          const Spacer(),
          _headerBtns(
            icon: Icon(Icons.queue, color: AppColors.primary, size: 13),
            label: 'ORDER QUEUE',
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
          Center(
            child: Container(
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
          ),
          const SizedBox(width: 11),
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
  }

  //---------------------------------------HeadBtn-----------------------------------------------------------
 //--------------------------------------- Header Button -----------------------------------------------------------
  Widget _headerBtns({
    Icon? icon,
    required String label,
    required VoidCallback onTap,
    int? badgeCount, // optional notification badge
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  const SizedBox(width: 4),
                ],
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
                hintText: 'Search item',
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                      fontSize: 10,
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

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _itemCard(item);
      },
    );
  }

Widget _itemCard(MenuItem item) {
  final isAvailable = item.isAvailable;
  
  final currentOrderIndex =
    item.hasVariants == 1
        ? -1
        : orderItems.indexWhere(
            (e) => e['id'] == item.id,
          );

final currentQty =
    currentOrderIndex >= 0
        ? orderItems[currentOrderIndex]['qty'] as int
        : 0;

final isSelected =
    item.hasVariants == 0 && currentQty > 0;

  String formatMoney(dynamic value) {
    final v = double.tryParse(value.toString()) ?? 0.0;
    return '₱${v.toStringAsFixed(2)}'
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

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
          color: AppColors.receiptDark.withOpacity(
            isSelected ? 0.10 : 0.04,
          ),
          offset: const Offset(0, 3),
          blurRadius: 10,
        ),
      ],
    ),
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ITEM NAME
              Text(
                item.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.receiptDark,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 6),

              // PRICE
              Text(
                item.startingPrice != null
                  ? "Starts at ${formatMoney(item.startingPrice)}"
                  : formatMoney(item.price),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.receiptDark.withOpacity(0.7),
                ),
              ),

              const Spacer(),

              // BUTTON
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: !isAvailable
                  ? Container(
                      key: const ValueKey('unavailable'),
                      width: double.infinity,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "UNAVAILABLE",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: .5,
                          ),
                        ),
                      ),
                    )
                  : !isSelected
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (item.hasVariants || item.hasFlavors) {
                              await _showCustomizeDialog(item);
                            } else {
                              setState(() {
                                orderItems.add({
                                  'id': item.id,
                                  'name': item.name,
                                  'price': double.parse(item.price.toString()),
                                  'qty': 1,
                                  'image_url': null,
                                });
                              });
                            }
                          },
                          child: const Text(
                            "ADD TO CART",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        key: const ValueKey('added_state'),
                        width: double.infinity,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.secondary,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "$currentQty IN CART",
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
            ],
          ),
        ),

        // CHECK ICON
        if (isSelected)
          Positioned(
            top: 10,
            right: 10,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: AppColors.secondary,
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 11,
              ),
            ),
          ),
      ],
    ),
  );
}

  //----------------------------------------Finalize Order Section-----------------------------------------------------------
  Widget _finaizeOrderSection() {

    String formattedOrderNum = OrderNumberUtils.formatOrderNumber(_nextOrderId, _orderType);
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  'CURRENT ORDER',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.receiptDark,
                    fontSize: 12,
                  ),
                ),

                const Spacer(),

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

          Expanded(
            child: orderItems.isEmpty 
            ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 38,
                      color: Colors.grey,
                    ),
                    Text(
                      'Start creating an order',
                      style: TextStyle(
                        fontSize: 10,
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
          :
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderItems.length,
              itemBuilder: (context, index) {
                final item = orderItems[index];

               return _orderItem(
                index: index,
                name: item['name'],
                variantCategory: item['variant_category'],
                variantName: item['variant_name'],
                flavors: item['flavors'],
                price: ((item['price'] as num).toDouble()) *
                  ((item['qty'] as num).toInt()),
                qty: item['qty'],
              );
              },
            ),
          ),
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
          editingOrderId == null ?
          _buildFinalizeButtons() : _buildEditButtons(),
        ],
      ),
    );
  }

  Widget _buildEditButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // Cancel Edit
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Cancel Editing"),
                  content: const Text(
                    "Discard your changes and exit edit mode?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Continue Editing"),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: () {
                        Navigator.pop(context);

                        setState(() {
                          editingOrderId = null;
                          orderItems.clear();
                        });

                        Navigator.pop(context); // Back to Order Queue
                      },
                      child: const Text("Discard"),
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
                Icons.close,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Update Order
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await _updateEditedOrder();
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.receiptDark,
                      offset: const Offset(3, 4),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "UPDATE ORDER",
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
    );
  }

  Widget _buildFinalizeButtons(){
    return Padding(
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
                            "FINALIZE ORDER",
                            style: const TextStyle(
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
          );
  }

  Widget _orderItem({
    required String name,
    String? variantCategory,
    String? variantName,
    List<Flavor>? flavors,
    required double price,
    required int qty,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 12,
      ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.receiptDark,
                      ),
                    ),

                    if (variantName != null) ...[
                      const SizedBox(height: 2),

                      Text(
                        "$variantCategory • $variantName",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],

                    if (flavors != null && flavors.isNotEmpty) ...[
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: flavors.map((flavor) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.secondary.withOpacity(.4),
                              ),
                            ),
                            child: Text(
                              flavor.flavorName,
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
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
          const SizedBox(height: 10),
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
                "₱${price.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 35,
        height: 35,
        child: Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
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
String buildOrderItemName(Map<String, dynamic> item) {
  print("========== ORDER ITEM ==========");
  print(item);

  if (item['variant_name'] == null) {
    return item['name'];
  }

  final category = item['variant_category'];
  final variant = item['variant_name'];

  final rawFlavors = item['flavors'];

  print("Category: $category");
  print("Variant: $variant");
  print("Raw flavors type: ${rawFlavors.runtimeType}");

  final List<Flavor> flavors =
      (rawFlavors as List<Flavor>? ?? []);

  for (final flavor in flavors) {
    print(
      "Flavor -> id: ${flavor.id}, "
      "name: ${flavor.flavorName}, "
      "available: ${flavor.isAvailable}",
    );
  }

  final flavorText =
      flavors.map((f) => f.flavorName).join(', ');

  print("Flavor Text: $flavorText");
  print("===============================");

  final displayName = "${item['name']}\n"
    "$category • $variant\n"
    "$flavorText";

  print(displayName);

  return displayName;
}