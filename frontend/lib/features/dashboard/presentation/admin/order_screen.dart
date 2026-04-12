import 'package:flutter/material.dart';
import '../../../../core/widgets/admin_header.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import "../../../../config/theme/app_colors.dart";

class OrderScreen extends StatefulWidget {
  final int activeIndex;
  final VoidCallback onLogout;
  const OrderScreen({super.key, this.activeIndex = 1, required this.onLogout});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}


class _OrderScreenState extends State<OrderScreen> {
  late int activeIndex;

  @override
  void initState(){
    super.initState();
    activeIndex = widget.activeIndex;
    }
  String _selectedDateFilter = 'TODAY';

//Does not work for now: Only a UI Placeholder. Waiting for Database
  final List<String> _dateFilters = ['TODAY', 'YESTERDAY', 'LAST 7 DAYS'];

  final List<Map<String, dynamic>> _orders = [
    {'datetime': '2026-02-07 13:20', 'id': 'LL-398', 'customer': 'RICO B.',   'itemCount': 3, 'entryType': 'WALK-IN', 'total': '₱420.00'},
    {'datetime': '2026-02-07 12:45', 'id': 'LL-397', 'customer': 'LIZA M.',   'itemCount': 1, 'entryType': 'ONLINE',  'total': '₱185.50'},
    {'datetime': '2026-02-07 11:30', 'id': 'LL-396', 'customer': 'WALK-IN',   'itemCount': 4, 'entryType': 'ONLINE',  'total': '₱650.00'},
    {'datetime': '2026-02-06 17:15', 'id': 'LL-395', 'customer': 'ELENA S.',  'itemCount': 1, 'entryType': 'ONLINE',  'total': '₱120.00'},
    {'datetime': '2026-02-06 16:40', 'id': 'LL-394', 'customer': 'MARCUS D.', 'itemCount': 5, 'entryType': 'WALK-IN', 'total': '₱890.00'},
    {'datetime': '2026-02-06 15:22', 'id': 'LL-393', 'customer': 'ANA G.',    'itemCount': 2, 'entryType': 'WALK-IN', 'total': '₱310.00'},
    {'datetime': '2026-02-06 14:10', 'id': 'LL-392', 'customer': 'WALK-IN',   'itemCount': 1, 'entryType': 'WALK-IN', 'total': '₱145.00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Sidebar(activeIndex: 1,  onLogout: widget.onLogout),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminHeader(title: "ORDERS",  onLogout: widget.onLogout),
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
          _buildTopFilterRow(),
          const SizedBox(height: 16),
          Expanded(child: _buildOrderTable()),
        ],
      ),
    );
  }

  Widget _buildTopFilterRow() {
    return Row(
      children: [
        // Date toggle buttons
        Row(
          children: [
            Text(
              'FILTER:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.tertiary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(width: 10),
            ..._dateFilters.map((f) {
              final isActive = _selectedDateFilter == f;
              return GestureDetector(
                onTap: () => setState(() => _selectedDateFilter = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.tertiary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? AppColors.tertiary
                          : AppColors.tertiary.withOpacity(.4),
                    ),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isActive ? Colors.white : AppColors.tertiary,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        const Spacer(),
        // Date range display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.tertiary.withOpacity(.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.tertiary),
              const SizedBox(width: 6),
              Text(
                'FEB 01, 2026 - FEB 07, 2026',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tertiary,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Filter icon
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.tertiary.withOpacity(.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.tune_rounded, size: 16, color: AppColors.tertiary),
        ),
        const SizedBox(width: 10),
        // Search field
        SizedBox(
          width: 200,
          height: 34,
          child: TextField(
            style: TextStyle(fontSize: 12, color: AppColors.tertiary),
            decoration: InputDecoration(
              hintText: 'SEARCH ORDER ID...',
              hintStyle: TextStyle(
                color: AppColors.tertiary.withOpacity(.5),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              suffixIcon: Icon(Icons.search, size: 16, color: AppColors.tertiary),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.tertiary.withOpacity(.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.tertiary, width: .9),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTable() {
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
              itemCount: _orders.length,
              itemBuilder: (context, index) =>
                  _buildOrderRow(_orders[index], index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    const headers = ['DATE / TIME', 'ORDER ID', 'SPECIMEN / CUSTOMER', 'ITEM COUNT', 'ENTRY TYPE', 'TOTAL VALUE', ''];
    const flexes  = [2, 1, 2, 1, 1, 1, 2];

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
        children: List.generate(headers.length, (i) => Expanded(
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
        )),
      ),
    );
  }

  Widget _buildOrderRow(Map<String, dynamic> order, int index) {
    final isWalkIn = order['entryType'] == 'WALK-IN';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : AppColors.background.withOpacity(.3),
        border: Border(
          bottom: BorderSide(color: AppColors.tertiary.withOpacity(.08)),
        ),
      ),
      child: Row(
        children: [
          // Date / Time
          Expanded(
            flex: 2,
            child: Text(
              order['datetime'],
              style: TextStyle(
                fontSize: 12,
                color: AppColors.tertiary.withOpacity(.8),
              ),
            ),
          ),
          // Order ID pill
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.tertiary.withOpacity(.2)),
              ),
              child: Text(
                order['id'],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Customer
          Expanded(
            flex: 2,
            child: Text(
              order['customer'],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4a3520),
              ),
            ),
          ),
          // Item count
          Expanded(
            flex: 1,
            child: Text(
              '${order['itemCount']} Units',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.tertiary.withOpacity(.8),
              ),
            ),
          ),
          // Entry type pill
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isWalkIn
                    ? AppColors.background
                    : const Color(0xFFD4EDDA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isWalkIn
                      ? AppColors.tertiary.withOpacity(.25)
                      : const Color(0xFF155724).withOpacity(.25),
                ),
              ),
              child: Text(
                order['entryType'],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isWalkIn
                      ? AppColors.tertiary
                      : const Color(0xFF155724),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Total
          Expanded(
            flex: 1,
            child: Text(
              order['total'],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4a3520),
              ),
            ),
          ),
          // View Receipt button
          //Also doesnt work. Just a ui button
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.receipt_long_outlined, size: 13, color: AppColors.tertiary),
                label: Text(
                  'VIEW RECEIPT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tertiary,
                    letterSpacing: 0.4,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.tertiary.withOpacity(.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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