import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/constants/menu_data.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/constants/cart_item.dart';
import 'package:frontend/features/customers/presentation/admin/cart_screen.dart';
import 'package:frontend/core/widgets/bamboo_background.dart';

const double _kMobile = 768;
const double _kDesktopMaxWidth = 1280;
const Color _primary = Color(0xFF758C6D);

//-------------------------------------------screen------------------------------------------------------------
class CustomerOrderScreen extends StatefulWidget {
  final List<Order> orders; // ← add this

  const CustomerOrderScreen({super.key, this.orders = const []});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  int _selectedIndex = 0;
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
                activeRoute: '/orders',
                cartCount: 3,
                notifCount: 1,
                onCart: () {},
                onNotif: () {},
                onProfile: () => Navigator.pushNamed(context, '/profile'),
                onLogout: () {},
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (isMobile)
                        ...[

                      ] else ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _customerOrderHeader(),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Divider(
                                thickness: 1.2,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _customerOderCategory(),
                            const SizedBox(height: 10),
                            _customerOrders(),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ],
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

  Widget _customerOrderHeader({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 45,
        15,
        isMobile ? 16 : 30,
        0,
      ),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              children: const [
                TextSpan(
                  text: 'ORDER STATUS: ',
                  style: TextStyle(color: AppColors.receiptDark),
                ),
                TextSpan(
                  text: 'ORDERS',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerOderCategory() {
    final List<Map<String, String>> categories = [
      {'label': 'PENDING'},
      {'label': 'IN PROGRESS'},
      {'label': 'ARCHIVE (2)'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        children: List.generate(categories.length, (i) {
          final isActive = i == _selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: i < categories.length - 1 ? 20 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 55,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      isActive ? const Color(0xFF9E7145) : AppColors.background,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  categories[i]['label']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                    color:
                        isActive
                            ? Colors.white
                            : AppColors.primary.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _customerOrders() {
    final filtered =
        widget.orders.where((o) {
          if (_selectedIndex == 0) return o.status == OrderStatus.pending;
          if (_selectedIndex == 1) return o.status == OrderStatus.inProgress;
          return o.status == OrderStatus.archived;
        }).toList();

    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          'No orders yet.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      children:
          filtered.map((order) {
            // ← loop through orders
            return Container(
              margin: const EdgeInsets.only(
                bottom: 12,
              ), // spacing between cards
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            'REFERENCE CODE',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text('#${order.id}'), // ← pull the ID here
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
