import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/constants/menu_data.dart';
import 'package:frontend/features/checkout/admin/presentation/checkout_screen.dart';
import 'package:frontend/features/dashboard/presentation/pos/online_orders_screen.dart';

class POSOrderScreen extends StatefulWidget {
  const POSOrderScreen({super.key});

  @override
  State<POSOrderScreen> createState() => _POSOrderScreenState();
}

class _POSOrderScreenState extends State<POSOrderScreen> {
  String _selectedCategory = MenuData.categories.first;
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
                      text: "\nARCHITECTING THE PERFECT BREW",
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
            onTap: () {},
          ),
          const SizedBox(width: 11),
          _headerBtns(
            icon: Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 13,
            ),
            label: 'REGISTRY',
            onTap: () {},
          ),
          const SizedBox(width: 11),
_headerBtns(
  icon: Icon(
    Icons.laptop_mac_outlined,
    color: AppColors.primary,
    size: 13,
  ),
  label: 'ONLINE ORDERS',
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
                "CASHIER 128",
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
  Widget _headerBtns({
    Icon? icon,
    required label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) icon,
            const SizedBox(width: 4),
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
    final categories = ['All', ...MenuData.categories];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 25),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.white : AppColors.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  //----------------------------------------Item Buttons-----------------------------------------------------------
  Widget _itemButtons() {
    final items =
        _selectedCategory == 'All'
            ? MenuData.itemsByCategory.entries
                .expand(
                  (e) => e.value.map((item) => {'category': e.key, ...item}),
                )
                .toList()
            : (MenuData.itemsByCategory[_selectedCategory] ?? [])
                .map((item) => {'category': _selectedCategory, ...item})
                .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _itemCard(item);
      },
    );
  }

  Widget _itemCard(Map<String, String> item) {
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
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (item['category'] ?? '').toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item['name'] ?? '',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.receiptDark,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['price'] ?? '',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  //add to order logic here
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 20,
                    color: AppColors.primary,
                  ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#00123',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),

          //------------------------------------------------------------------------------------------------------------
          //-------------------------------------------------------------------------------------------------------------
          //--------------------------------------------temporary order list---------------------------------------------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _orderItem(name: 'Burger Meal', price: '₱199.00', qty: 2),
              ],
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
                        isSelected: true,
                        isFirst: true,
                        isLast: false,
                      ),
                    ),
                    Expanded(
                      child: _orderTypeBtn(
                        icon: Icons.shopping_cart,
                        label: 'TAKE OUT',
                        isSelected: false,
                        isFirst: false,
                        isLast: true,
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
                      '₱165.00',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ENGINEERING TAX (12%)',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '₱19.80',
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
                      '₱184.80',
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
                Container(
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
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                       // Navigate to the next screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutConfirmationScreen(), // Replace with your screen
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
                    )
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
              Icon(Icons.close, size: 18, color: AppColors.primary),
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
                    _qtyBtn(Icons.remove, () {}),
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
                    _qtyBtn(Icons.add, () {}),
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
      child: Container(
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
  }) {
    return Container(
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
    );
  }

  //for improvement.. add logic
}
