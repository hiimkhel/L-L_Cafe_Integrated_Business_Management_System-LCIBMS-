import 'package:flutter/material.dart';
import 'dart:async';
import 'package:frontend/core/widgets/admin_header.dart';
import 'package:frontend/core/widgets/admin_sidebar.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/services/admin/customers_service.dart';

class CustomersScreen extends StatefulWidget {
  final int activeIndex;
  final VoidCallback onLogout;
  const CustomersScreen({super.key, this.activeIndex = 5, required this.onLogout});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late int activeIndex;

  
  List<dynamic> _customers = [];
  bool _isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    activeIndex = widget.activeIndex;
    _loadCustomers();
  }



    Future<void> _loadCustomers({String search = ""}) async {
    setState(() => _isLoading = true);

    try {
      final data = await CustomersService.getCustomers(search: search);

      setState(() {
        _customers = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading customers: $e");

      setState(() {
        _customers = [];
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadCustomers(search: value);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Sidebar(activeIndex: activeIndex, onLogout: widget.onLogout),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminHeader(title: "CUSTOMERS",  onLogout: widget.onLogout),
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
      'EMAIL',
      'ADDRESS',
      'TOTAL SPENT'
    ];

    const flexes = [1, 1, 2, 2, 3, 1];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(.6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          bottom: BorderSide(color: AppColors.tertiary.withOpacity(.15)),
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
    Widget _buildCustomerRow(Map<String, dynamic> customer, int index) {
      final createdAt = customer['created_at'];
      final date = (createdAt != null && createdAt.toString().length >= 10)
          ? createdAt.toString().substring(0, 10)
          : "N/A";

      final address = customer['address'] ?? "No Address";

      // TEMPORARY: until we connect orders table
      final totalSpent = customer['total_spent'] != null
          ? "₱${customer['total_spent']}"
          : "₱0.00";

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: index.isEven
              ? Colors.white
              : AppColors.background.withOpacity(.3),
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.15)),
          ),
        ),
        child: Row(
          children: [
            // JOIN DATE
            Expanded(
              flex: 1,
              child: Text(
                date,
                style: TextStyle(color: AppColors.tertiary.withOpacity(.8)),
              ),
            ),

            // ID
            Expanded(
              flex: 1,
              child: Text(
                "#${customer['id'] ?? '-'}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            // NAME
            Expanded(
              flex: 2,
              child: Text(
                customer['full_name'] ?? "Unknown",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            // EMAIL
            Expanded(
              flex: 2,
              child: Text(customer['email'] ?? "No Email"),
            ),

            // ADDRESS
            Expanded(
              flex: 3,
              child: Text(address),
            ),

            // TOTAL SPENT
            Expanded(
              flex: 1,
              child: Text(
                totalSpent,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
}