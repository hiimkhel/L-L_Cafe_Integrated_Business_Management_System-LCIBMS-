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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        fontSize: 10,
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

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
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
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.receiptDark.withOpacity(0.08),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getCategoryName(item.categoryId).toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            item.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.receiptDark,
            ),
          ),

          const Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₱${item.price}",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),

              GestureDetector(
                onTap: () {
                  setState(() {
                    final index = orderItems.indexWhere(
                      (e) => e['id'] == item.id,
                    );

                    if (index >= 0) {
                      orderItems[index]['qty'] += 1;
                    } else {
                      orderItems.add({
                        'id': item.id,
                        'name': item.name,
                        'price': double.parse(item.price.toString()),
                        'qty': 1,
                      });
                    }
                  });
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 20),
                ),
              ),
            ],
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
                    fontSize: 18,
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
            child: ListView.builder(
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
      ),
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
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.receiptDark,
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
