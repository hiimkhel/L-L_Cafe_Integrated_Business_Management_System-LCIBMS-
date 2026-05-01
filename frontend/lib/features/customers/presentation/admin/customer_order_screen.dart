import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/constants/menu_data.dart';
import 'package:frontend/core/widgets/customer_navbar.dart';
import 'package:frontend/core/widgets/customer_footer.dart';
import 'package:frontend/core/constants/cart_item.dart';
import 'package:frontend/features/customers/presentation/admin/cart_screen.dart';
import 'package:frontend/core/constants/cart_provider.dart';
import 'package:frontend/core/widgets/bamboo_background.dart';

const double _kMobile = 768;
const double _kDesktopMaxWidth = 1280;
const Color _primary = Color(0xFF758C6D);

//-------------------------------------------screen------------------------------------------------------------
class CustomerOrderScreen extends StatefulWidget {
  final List<Order> orders; // ← add this

class CustomerOrderScreen extends StatefulWidget {
  final List<Order> orders;
  const CustomerOrderScreen({super.key, this.orders = const []});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Order> get _sourceOrders =>
      widget.orders.isEmpty ? _demoOrders : widget.orders;

  List<Order> get _filtered {
    final all = _sourceOrders.where((o) {
      if (_selectedIndex == 0) return o.status == OrderStatus.pending;
      if (_selectedIndex == 1) return o.status == OrderStatus.inProgress;
      return o.status == OrderStatus.archived;
    }).toList();

    if (_searchQuery.isEmpty || _selectedIndex != 2) return all;
    final q = _searchQuery.toLowerCase();
    return all
        .where((o) =>
            o.id.toLowerCase().contains(q) ||
            (o.timestamp?.toLowerCase().contains(q) ?? false) ||
            o.items.any((i) => i.toLowerCase().contains(q)))
        .toList();
  }

  int get _archiveCount =>
      _sourceOrders.where((o) => o.status == OrderStatus.archived).length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleExportHistory() {
    // TODO: hook up real export (CSV / PDF) from backend
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Export History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Export detailed architectural invoices for 2026.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              // TODO: call backend export endpoint
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting history…')),
              );
            },
            child: const Text('EXPORT HISTORY'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);
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
                cartCount: cart.totalCount,
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
                        _MobileOrderBody(
                          selectedIndex: _selectedIndex,
                          onTabChanged: (i) => setState(() {
                            _selectedIndex = i;
                            _searchQuery = '';
                            _searchController.clear();
                          }),
                          archiveCount: _archiveCount,
                          filtered: _filtered,
                          searchController: _searchController,
                          searchQuery: _searchQuery,
                          onSearchChanged: (v) =>
                              setState(() => _searchQuery = v),
                          onExport: _handleExportHistory,
                          onViewOrder: _showOrderDetail,
                        )
                      else
                        _DesktopOrderBody(
                          selectedIndex: _selectedIndex,
                          onTabChanged: (i) => setState(() {
                            _selectedIndex = i;
                            _searchQuery = '';
                            _searchController.clear();
                          }),
                          archiveCount: _archiveCount,
                          filtered: _filtered,
                          searchController: _searchController,
                          searchQuery: _searchQuery,
                          onSearchChanged: (v) =>
                              setState(() => _searchQuery = v),
                          onExport: _handleExportHistory,
                          onViewOrder: _showOrderDetail,
                        ),
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

  void _showOrderDetail(Order order) {
    // TODO: navigate to order detail screen / sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _OrderDetailSheet(order: order),
    );
  }
}

// ─────────────────────────── Desktop body ───────────────────────────────────

class _DesktopOrderBody extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final int archiveCount;
  final List<Order> filtered;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onExport;
  final ValueChanged<Order> onViewOrder;

  const _DesktopOrderBody({
    required this.selectedIndex,
    required this.onTabChanged,
    required this.archiveCount,
    required this.filtered,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onExport,
    required this.onViewOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DesktopHeader(),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Divider(
              thickness: 1.2, color: AppColors.primary.withOpacity(0.5)),
        ),
        const SizedBox(height: 10),
        _DesktopCategoryRow(
          selectedIndex: selectedIndex,
          archiveCount: archiveCount,
          onTabChanged: onTabChanged,
        ),
        const SizedBox(height: 10),
        // Archive tools row (search + export)
        if (selectedIndex == 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Row(
              children: [
                Expanded(child: _SearchBar(controller: searchController, onChanged: onSearchChanged)),
                const SizedBox(width: 16),
                _ExportButton(onPressed: onExport),
              ],
            ),
          ),
        if (selectedIndex == 2) const SizedBox(height: 12),
        _DesktopOrderList(
            filtered: filtered, onViewOrder: onViewOrder),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(45, 15, 30, 0),
      child: Row(
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2),
              children: [
                TextSpan(
                    text: 'ORDER STATUS: ',
                    style: TextStyle(color: AppColors.receiptDark)),
                TextSpan(
                    text: 'ORDERS',
                    style: TextStyle(color: AppColors.secondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopCategoryRow extends StatelessWidget {
  final int selectedIndex;
  final int archiveCount;
  final ValueChanged<int> onTabChanged;

  const _DesktopCategoryRow({
    required this.selectedIndex,
    required this.archiveCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labels = ['PENDING', 'IN PROGRESS', 'ARCHIVE ($archiveCount)'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isActive = i == selectedIndex;
          return Padding(
            padding:
                EdgeInsets.only(right: i < labels.length - 1 ? 20 : 0),
            child: GestureDetector(
              onTap: () => onTabChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 55, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF9E7145)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.8,
                    color: isActive
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
}

class _DesktopOrderList extends StatelessWidget {
  final List<Order> filtered;
  final ValueChanged<Order> onViewOrder;

  const _DesktopOrderList(
      {required this.filtered, required this.onViewOrder});

  @override
  Widget build(BuildContext context) {
    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
            child: Text('No orders found.',
                style: TextStyle(fontSize: 16, color: Colors.grey))),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: filtered
            .map((order) => _DesktopOrderCard(
                order: order, onView: () => onViewOrder(order)))
            .toList(),
      ),
    );
  }
}

class _DesktopOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onView;
  const _DesktopOrderCard({required this.order, required this.onView});

  @override
  Widget build(BuildContext context) {
    final badgeLabel = order.subStatus ?? _statusLabel(order.status);
    final badgeColor = order.subStatus == 'OUT FOR DELIVERY'
        ? const Color(0xFF2196F3)
        : _statusColor(order.status);

    // Show up to 5 items then "+N more"
    const maxVisible = 5;
    final visible = order.items.take(maxVisible).toList();
    final overflow = order.items.length - maxVisible;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: code / badge / total
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('REFERENCE CODE',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary.withOpacity(0.7),
                            letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text('#${order.id}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.receiptDark,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(badgeLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
              ),
              const SizedBox(width: 24),
              Text(
                '₱${order.total.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── Row 2: timestamp / method
          Row(
            children: [
              if (order.timestamp != null) ...[
                Icon(Icons.access_time_rounded,
                    size: 16, color: AppColors.primary.withOpacity(0.6)),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TIMESTAMP',
                        style: TextStyle(
                            fontSize: 9,
                            color: AppColors.primary.withOpacity(0.5),
                            letterSpacing: 1)),
                    Text(order.timestamp!,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: AppColors.receiptDark)),
                  ],
                ),
                const SizedBox(width: 30),
              ],
              if (order.method != null) ...[
                Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.primary.withOpacity(0.6)),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('METHOD',
                        style: TextStyle(
                            fontSize: 9,
                            color: AppColors.primary.withOpacity(0.5),
                            letterSpacing: 1)),
                    Text(order.method!,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: AppColors.receiptDark)),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          // ── Row 3: item chips
          if (order.items.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ...visible.map((item) => _ItemChip(label: item)),
                if (overflow > 0) _ItemChip(label: '+$overflow MORE', faded: true),
              ],
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Mobile body ────────────────────────────────────

class _MobileOrderBody extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final int archiveCount;
  final List<Order> filtered;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onExport;
  final ValueChanged<Order> onViewOrder;

  const _MobileOrderBody({
    required this.selectedIndex,
    required this.onTabChanged,
    required this.archiveCount,
    required this.filtered,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onExport,
    required this.onViewOrder,
  });

  @override
  Widget build(BuildContext context) {
    final labels = ['PENDING', 'IN PROGRESS', 'ARCHIVE ($archiveCount)'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text('ORDERS',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.receiptDark,
                  letterSpacing: 1.5)),
          const SizedBox(height: 16),
          // Tab row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(labels.length, (i) {
                final isActive = i == selectedIndex;
                return Padding(
                  padding: EdgeInsets.only(
                      right: i < labels.length - 1 ? 10 : 0),
                  child: GestureDetector(
                    onTap: () => onTabChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF9E7145)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 5,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Text(labels[i],
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.primary.withOpacity(0.8))),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          // Archive: search bar
          if (selectedIndex == 2) ...[
            _SearchBar(
                controller: searchController, onChanged: onSearchChanged),
            const SizedBox(height: 12),
          ],
          // Order cards
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                  child: Text('No orders found.',
                      style: TextStyle(color: Colors.grey))),
            )
          else
            ...filtered.map((o) => _MobileOrderCard(
                order: o, onView: () => onViewOrder(o))),
          // Archive: export banner
          if (selectedIndex == 2) ...[
            const SizedBox(height: 4),
            _MobileExportBanner(onExport: onExport),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _MobileOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onView;
  const _MobileOrderCard({required this.order, required this.onView});

  @override
  Widget build(BuildContext context) {
    final badgeLabel = order.subStatus ?? _statusLabel(order.status);
    final badgeColor = order.subStatus == 'OUT FOR DELIVERY'
        ? const Color(0xFF2196F3)
        : _statusColor(order.status);

    const maxVisible = 3;
    final visible = order.items.take(maxVisible).toList();
    final overflow = order.items.length - maxVisible;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('REFERENCE CODE',
                        style: TextStyle(
                            fontSize: 9,
                            color: AppColors.primary.withOpacity(0.6),
                            letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text('#${order.id}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.receiptDark)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(16)),
                child: Text(badgeLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (order.timestamp != null)
            _MobileInfoRow(
                icon: Icons.access_time_rounded,
                label: 'TIMESTAMP',
                value: order.timestamp!),
          if (order.method != null) ...[
            const SizedBox(height: 8),
            _MobileInfoRow(
                icon: Icons.location_on_outlined,
                label: 'METHOD',
                value: order.method!),
          ],
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('ITEMS',
                style: TextStyle(
                    fontSize: 9,
                    color: AppColors.primary.withOpacity(0.5),
                    letterSpacing: 1)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...visible.map((item) => _ItemChip(label: item)),
                if (overflow > 0)
                  _ItemChip(label: '+$overflow MORE', faded: true),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL',
                      style: TextStyle(
                          fontSize: 9,
                          color: AppColors.primary.withOpacity(0.5),
                          letterSpacing: 1)),
                  Text('₱${order.total.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary)),
                ],
              ),
              GestureDetector(
                onTap: onView,
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 16,
                        color: AppColors.primary.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text('VIEW',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary.withOpacity(0.7),
                            letterSpacing: 1)),
                    Icon(Icons.chevron_right,
                        size: 16,
                        color: AppColors.primary.withOpacity(0.7)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MobileInfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary.withOpacity(0.6)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    color: AppColors.primary.withOpacity(0.5),
                    letterSpacing: 1)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.receiptDark)),
          ],
        ),
      ],
    );
  }
}

class _MobileExportBanner extends StatelessWidget {
  final VoidCallback onExport;
  const _MobileExportBanner({required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.receipt_long,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Export detailed architectural invoices for 2026.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onExport,
              child: const Text('EXPORT HISTORY',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Shared small widgets ───────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search by order ID, date or item…',
        hintStyle:
            TextStyle(color: AppColors.primary.withOpacity(0.5), fontSize: 13),
        prefixIcon:
            Icon(Icons.search, color: AppColors.primary.withOpacity(0.6)),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.primary.withOpacity(0.5),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                })
            : null,
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide:
                BorderSide(color: AppColors.primary.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ExportButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2A2A2A),
        foregroundColor: Colors.white,
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
        elevation: 3,
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.file_download_outlined, size: 18),
      label: const Text('EXPORT HISTORY',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
              fontSize: 12)),
    );
  }
}

class _ItemChip extends StatelessWidget {
  final String label;
  final bool faded;
  const _ItemChip({required this.label, this.faded = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: faded
            ? AppColors.primary.withOpacity(0.08)
            : AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: faded
                  ? AppColors.primary.withOpacity(0.5)
                  : AppColors.primary,
              letterSpacing: 0.5)),
    );
  }
}

// ─────────────────────────── Order detail sheet ─────────────────────────────

class _OrderDetailSheet extends StatelessWidget {
  final Order order;
  const _OrderDetailSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(24),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text('Order #${order.id}',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('₱${order.total.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary)),
            const Divider(height: 32),
            if (order.timestamp != null)
              ListTile(
                  leading: const Icon(Icons.access_time_rounded),
                  title: const Text('Timestamp'),
                  subtitle: Text(order.timestamp!)),
            if (order.method != null)
              ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Method'),
                  subtitle: Text(order.method!)),
            const SizedBox(height: 8),
            const Text('Items',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(item),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            // TODO: add track / cancel / reorder actions
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }
}