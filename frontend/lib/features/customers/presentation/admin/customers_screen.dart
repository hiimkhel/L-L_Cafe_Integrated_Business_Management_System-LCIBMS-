import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/admin_header.dart';
import 'package:frontend/core/widgets/admin_sidebar.dart';
import 'package:frontend/config/theme/app_colors.dart';

class CustomersScreen extends StatefulWidget {
  final int activeIndex;
  const CustomersScreen({super.key, this.activeIndex = 5});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late int activeIndex;

  @override
  void initState() {
    super.initState();
    activeIndex = widget.activeIndex;
  }

  // Dummy customers data
  final List<Map<String, dynamic>> _customers = [
    {
      'joinDate': '2026-02-07 13:20',
      'customerId': '#C-398',
      'customerName': 'RICO B.',
      'address': 'Makati City',
      'totalSpent': '₱420.00',
    },
    {
      'joinDate': '2026-02-07 12:45',
      'customerId': '#C-397',
      'customerName': 'LIZA M.',
      'address': 'Cebu City',
      'totalSpent': '₱185.50',
    },
    {
      'joinDate': '2026-02-06 17:15',
      'customerId': '#C-396',
      'customerName': 'ELENA S.',
      'address': 'Iloilo City',
      'totalSpent': '₱120.00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Sidebar(activeIndex: activeIndex),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminHeader(title: "CUSTOMERS"),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopSearchRow(),
          const SizedBox(height: 16),
          Expanded(child: _buildCustomerTable()),
        ],
      ),
    );
  }

  //  SEARCH BAR (UI only for now)
  Widget _buildTopSearchRow() {
    return SizedBox(
      width: double.infinity,
      height: 38,
      child: TextField(
        style: TextStyle(fontSize: 12, color: AppColors.tertiary),
        decoration: InputDecoration(
          hintText: 'SEARCH CUSTOMER...',
          hintStyle: TextStyle(
            color: AppColors.tertiary.withOpacity(.5),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          suffixIcon: Icon(Icons.search,
              size: 16, color: AppColors.tertiary),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: AppColors.tertiary.withOpacity(.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: AppColors.tertiary, width: .9),
          ),
        ),
      ),
    );
  }

  // TABLE
  Widget _buildCustomerTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.tertiary.withOpacity(.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) =>
                  _buildCustomerRow(_customers[index], index),
            ),
          ),
        ],
      ),
    );
  }

  // HEADER
  Widget _buildTableHeader() {
    const headers = [
      'JOIN DATE',
      'CUSTOMER ID',
      'CUSTOMER NAME',
      'ADDRESS',
      'TOTAL SPENT',
      ''
    ];

    const flexes = [2, 1, 2, 2, 1, 2];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(.6),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          bottom:
              BorderSide(color: AppColors.tertiary.withOpacity(.15)),
        ),
      ),
      child: Row(
        children: List.generate(
          headers.length,
          (i) => Expanded(
            flex: flexes[i],
            child: Text(
              headers[i],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                color: AppColors.tertiary.withOpacity(.8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ROW
  Widget _buildCustomerRow(
      Map<String, dynamic> customer, int index) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: index.isEven
            ? Colors.white
            : AppColors.background.withOpacity(.3),
        border: Border(
          bottom:
              BorderSide(color: AppColors.tertiary.withOpacity(.08)),
        ),
      ),
      child: Row(
        children: [
          // JOIN DATE
          Expanded(
            flex: 2,
            child: Text(
              customer['joinDate'],
              style: TextStyle(
                fontSize: 12,
                color: AppColors.tertiary.withOpacity(.8),
              ),
            ),
          ),

          // CUSTOMER ID
          Expanded(
            flex: 1,
            child: Text(
              customer['customerId'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4a3520),
              ),
            ),
          ),

          // CUSTOMER NAME
          Expanded(
            flex: 2,
            child: Text(
              customer['customerName'],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4a3520),
              ),
            ),
          ),

          // ADDRESS
          Expanded(
            flex: 2,
            child: Text(
              customer['address'],
              style: TextStyle(
                fontSize: 12,
                color: AppColors.tertiary.withOpacity(.8),
              ),
            ),
          ),

          // TOTAL SPENT
          Expanded(
            flex: 1,
            child: Text(
              customer['totalSpent'],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4a3520),
              ),
            ),
          ),

          // DETAILS BUTTON
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: AppColors.tertiary.withOpacity(.4)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'DETAILS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tertiary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}