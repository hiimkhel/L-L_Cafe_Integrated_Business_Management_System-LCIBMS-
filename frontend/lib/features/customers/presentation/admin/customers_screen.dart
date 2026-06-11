import 'package:flutter/material.dart';
import 'dart:async';
import 'package:frontend/core/widgets/admin_header.dart';
import 'package:frontend/core/widgets/admin_sidebar.dart';
import 'package:frontend/core/services/admin/customers_service.dart';

const _kBg    = Color(0xFFEFE2C9);
const _kDark  = Color(0xFF2D2A26);
const _kGreen = Color(0xFF758C6D);
const _kBrown = Color(0xFFA98258);

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CustomersScreen extends StatefulWidget {
  final int activeIndex;
  final VoidCallback onLogout;

  const CustomersScreen({
    super.key,
    this.activeIndex = 4,
    required this.onLogout,
  });

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filtered  = [];
  bool   _isLoading   = true;
  String _searchQuery = '';
  String _sortField   = 'created_at';
  bool   _sortAsc     = false;
  int?   _expandedRow;
  Timer? _debounce;

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers({String search = ''}) async {
    setState(() => _isLoading = true);
    try {
      final data = await CustomersService.getCustomers(search: search);
      _customers = List<Map<String, dynamic>>.from(data);
      _applySort();
    } catch (e) {
      debugPrint('Error loading customers: $e');
      _customers = [];
      _filtered  = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _applySort() {
    _filtered = List.from(_customers);
    _filtered.sort((a, b) {
      final av = a[_sortField]?.toString() ?? '';
      final bv = b[_sortField]?.toString() ?? '';
      return _sortAsc ? av.compareTo(bv) : bv.compareTo(av);
    });
  }

  void _onSearch(String v) {
    setState(() => _searchQuery = v);
    _debounce?.cancel();
    _debounce = Timer(
        const Duration(milliseconds: 400), () => _loadCustomers(search: v));
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _searchQuery = '');
    _loadCustomers();
  }

  void _setSort(String field) {
    setState(() {
      if (_sortField == field) {
        _sortAsc = !_sortAsc;
      } else {
        _sortField = field;
        _sortAsc   = true;
      }
      _applySort();
    });
  }

  String _fmtDate(dynamic v) {
    if (v == null) return '—';
    final s = v.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  String _fmtSpent(dynamic v) {
    final d = double.tryParse(v?.toString() ?? '') ?? 0;
    return '₱${d.toStringAsFixed(2)}';
  }


  String _phone(Map<String, dynamic> c) =>
      c['phone']?.toString().isNotEmpty == true
          ? c['phone'].toString()
          : 'Not provided';

  String _totalOrders(Map<String, dynamic> c) {
    // TODO: map to real backend field e.g. c['orders_count']
    final v = c['orders_count'];
    if (v == null) return '—';
    return v.toString();
  }

  String _lastOrder(Map<String, dynamic> c) {
    // TODO: map to real backend field e.g. c['last_order_at']
    return _fmtDate(c['last_order_at']);
  }

  String _avgOrderValue(Map<String, dynamic> c) {
    // Derived: total_spent / orders_count
    final spent   = double.tryParse(c['total_spent']?.toString() ?? '') ?? 0;
    final orders  = int.tryParse(c['orders_count']?.toString() ?? '') ?? 0;
    if (orders == 0 || spent == 0) return '—';
    return '₱${(spent / orders).toStringAsFixed(2)}';
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Sidebar(activeIndex: widget.activeIndex, onLogout: widget.onLogout),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AdminHeader(title: 'CUSTOMERS', onLogout: widget.onLogout),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopRow(),
          const SizedBox(height: 16),
          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        _StatCard(label: 'TOTAL CUSTOMERS', value: '${_customers.length}',
            icon: Icons.people_alt_rounded, color: _kGreen),
        const SizedBox(width: 12),
        _StatCard(
          label: 'WITH ADDRESS',
          value: '${_customers.where((c) => (c['address'] ?? '').toString().isNotEmpty).length}',
          icon: Icons.location_on_outlined,
          color: _kBrown,
        ),
        const SizedBox(width: 12),
        _StatCard(label: 'RESULTS SHOWN', value: '${_filtered.length}',
            icon: Icons.filter_list_rounded, color: const Color(0xFF5B7FA6)),
        const Spacer(),
        SizedBox(
          width: 260,
          height: 44,
          child: _buildSearchBar(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kGreen.withOpacity(0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearch,
        style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
            fontSize: 12, color: _kDark),
        decoration: InputDecoration(
          hintText: 'SEARCH CUSTOMERS...',
          hintStyle: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
              fontSize: 11, color: _kDark.withOpacity(0.35), letterSpacing: 0.5),
          prefixIcon: Icon(Icons.search_rounded, size: 18,
              color: _kGreen.withOpacity(0.7)),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: _clearSearch,
                  child: Icon(Icons.close_rounded, size: 16,
                      color: _kDark.withOpacity(0.4)))
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
            blurRadius: 18, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        _buildHeader(),
        Expanded(child: _buildBody()),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
      decoration: BoxDecoration(
        color: _kBg,
        border: Border(bottom: BorderSide(color: _kGreen.withOpacity(0.18))),
      ),
      child: Row(children: [
        SizedBox(width: 36, child: _hdr('NO.')),
        const SizedBox(width: 12),
        Expanded(flex: 18, child: _sortHdr('JOIN DATE',   'created_at')),
        const SizedBox(width: 8),
        Expanded(flex: 14, child: _sortHdr('ID',          'id')),
        const SizedBox(width: 8),
        Expanded(flex: 24, child: _sortHdr('NAME',        'full_name')),
        const SizedBox(width: 8),
        Expanded(flex: 26, child: _sortHdr('EMAIL',       'email')),
        const SizedBox(width: 8),
        Expanded(flex: 22, child: _sortHdr('ADDRESS',     'address')),
        const SizedBox(width: 8),
        Expanded(flex: 16, child: _sortHdr('TOTAL SPENT', 'total_spent')),
        const SizedBox(width: 24 + 8),
      ]),
    );
  }

  Widget _hdr(String label) => Text(label,
      style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w800,
          fontSize: 10, letterSpacing: 1.0, color: _kDark.withOpacity(0.5)));

  Widget _sortHdr(String label, String field) {
    final active = _sortField == field;
    return GestureDetector(
      onTap: () => _setSort(field),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w800,
                fontSize: 10, letterSpacing: 1.0,
                color: active ? _kGreen : _kDark.withOpacity(0.5))),
        const SizedBox(width: 3),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.arrow_drop_up, size: 13,
              color: active && _sortAsc ? _kGreen : _kDark.withOpacity(0.2)),
          Icon(Icons.arrow_drop_down, size: 13,
              color: active && !_sortAsc ? _kGreen : _kDark.withOpacity(0.2)),
        ]),
      ]),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: _kGreen));
    if (_filtered.isEmpty) return _emptyState();
    return ListView.builder(
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _buildRow(_filtered[i], i),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 64, height: 64,
            decoration: BoxDecoration(color: _kGreen.withOpacity(0.08),
                shape: BoxShape.circle),
            child: Icon(Icons.people_outline_rounded, size: 32,
                color: _kGreen.withOpacity(0.4))),
        const SizedBox(height: 14),
        Text(_searchQuery.isNotEmpty
            ? 'NO RESULTS FOR "$_searchQuery"' : 'NO CUSTOMERS YET',
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 13, letterSpacing: 0.8,
                color: _kDark.withOpacity(0.35))),
        const SizedBox(height: 6),
        Text(_searchQuery.isNotEmpty
            ? 'Try a different name or email'
            : 'Registered customers will appear here',
            style: TextStyle(fontFamily: 'Urbanist', fontSize: 11,
                color: _kDark.withOpacity(0.3))),
        if (_searchQuery.isNotEmpty) ...[
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _clearSearch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: _kGreen,
                  borderRadius: BorderRadius.circular(10)),
              child: const Text('CLEAR SEARCH',
                  style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w800,
                      fontSize: 11, color: Colors.white, letterSpacing: 1)),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _buildRow(Map<String, dynamic> c, int index) {
    final isEven     = index.isEven;
    final isExpanded = _expandedRow == index;

    final date    = _fmtDate(c['created_at']);
    final id      = '${c['id'] ?? '—'}';
    final name    = c['full_name']?.toString() ?? 'Unknown';
    final email   = c['email']?.toString() ?? '—';
    final address = c['address']?.toString() ?? '';
    final spent   = _fmtSpent(c['total_spent']);
    final hasAddr = address.isNotEmpty;
    final spentZero = spent == '₱0.00';

    return GestureDetector(
      onTap: () => setState(() => _expandedRow = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: isEven ? Colors.white : _kBg.withOpacity(0.32),
          border: Border(bottom: BorderSide(color: _kGreen.withOpacity(0.07))),
        ),
        child: Column(children: [
          // ── Main row ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              SizedBox(width: 36,
                  child: Text('${index + 1}',
                      style: TextStyle(fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w700, fontSize: 11,
                          color: _kDark.withOpacity(0.3)))),
              const SizedBox(width: 12),
              Expanded(flex: 18, child: Text(date,
                  style: TextStyle(fontFamily: 'Urbanist', fontSize: 11,
                      color: _kDark.withOpacity(0.55)))),
              const SizedBox(width: 8),
              Expanded(flex: 14, child: Align(alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: _kGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text('#$id', style: const TextStyle(
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w800,
                        fontSize: 10, color: _kGreen)),
                  ))),
              const SizedBox(width: 8),
              Expanded(flex: 24, child: Text(name,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700, fontSize: 12, color: _kDark))),
              const SizedBox(width: 8),
              Expanded(flex: 26, child: Text(email,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Urbanist', fontSize: 11,
                      color: _kDark.withOpacity(0.6)))),
              const SizedBox(width: 8),
              Expanded(flex: 22, child: hasAddr
                  ? Text(address, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: 'Urbanist', fontSize: 11,
                          color: _kDark.withOpacity(0.6)))
                  : Text('No address', style: TextStyle(fontFamily: 'Urbanist',
                      fontStyle: FontStyle.italic, fontSize: 11,
                      color: _kDark.withOpacity(0.25)))),
              const SizedBox(width: 8),
              Expanded(flex: 16, child: Text(spent,
                  style: TextStyle(fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w800, fontSize: 12,
                      color: spentZero ? _kDark.withOpacity(0.28) : _kGreen))),
              SizedBox(width: 24,
                  child: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color: _kDark.withOpacity(0.28)),
                  )),
            ]),
          ),

          // ── Expanded detail panel — non-redundant content ────────────────
          if (isExpanded) _buildDetailPanel(c, id, name),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EXPANDED DETAIL PANEL
  // Shows only information NOT already visible in the table row:
  //   phone · account status · loyalty tier ·
  //   total orders · last order date · avg order value · notes
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDetailPanel(Map<String, dynamic> c, String id, String name) {
    final phone       = _phone(c);
    final totalOrders = _totalOrders(c);
    final lastOrder   = _lastOrder(c);
    final avgOrder    = _avgOrderValue(c);
    final notes       = c['notes']?.toString() ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kGreen.withOpacity(0.18)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──────────────────────────────────────────────────────────
        Text('ACCOUNT OVERVIEW',
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 9, letterSpacing: 1.8,
                color: _kBrown.withOpacity(0.65))),

        const SizedBox(height: 16),
        Divider(color: _kGreen.withOpacity(0.12), height: 1),
        const SizedBox(height: 16),

        // ── Two rows of stat tiles ──────────────────────────────────────────
        Row(children: [
          _DetailTile(
            icon: Icons.phone_outlined,
            label: 'PHONE NUMBER',
            value: phone,
            iconColor: _kGreen,
          ),
          const SizedBox(width: 12),
          _DetailTile(
            icon: Icons.receipt_long_outlined,
            label: 'TOTAL ORDERS',
            value: totalOrders,
            iconColor: const Color(0xFF2196F3),
          ),
          const SizedBox(width: 12),
          _DetailTile(
            icon: Icons.schedule_rounded,
            label: 'LAST ORDER',
            value: lastOrder,
            iconColor: const Color(0xFF9C27B0),
          ),
          const SizedBox(width: 12),
          _DetailTile(
            icon: Icons.trending_up_rounded,
            label: 'AVG. ORDER VALUE',
            value: avgOrder,
            iconColor: _kBrown,
            valueColor: avgOrder == '—' ? null : _kBrown,
          ),
        ]),

        // ── Notes (only if present) ─────────────────────────────────────────
        if (notes.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kGreen.withOpacity(0.12)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.sticky_note_2_outlined,
                  size: 14, color: _kBrown.withOpacity(0.6)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('NOTES', style: TextStyle(fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w800, fontSize: 9,
                      letterSpacing: 1.0, color: _kDark.withOpacity(0.4))),
                  const SizedBox(height: 3),
                  Text(notes, style: TextStyle(fontFamily: 'Urbanist',
                      fontSize: 11, color: _kDark.withOpacity(0.7))),
                ]),
              ),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL TILE  (used inside expanded panel)
// ─────────────────────────────────────────────────────────────────────────────

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color iconColor;
  final Color? valueColor;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: iconColor.withOpacity(0.12)),
        ),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700, fontSize: 8,
                      letterSpacing: 1.0, color: _kDark.withOpacity(0.38))),
              const SizedBox(height: 3),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w800, fontSize: 13,
                      color: valueColor ?? _kDark)),
            ],
          )),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label, required this.value,
    required this.icon,  required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 34, height: 34,
            decoration: BoxDecoration(color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: color, size: 17)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
          Text(value, style: const TextStyle(fontFamily: 'Urbanist',
              fontWeight: FontWeight.w900, fontSize: 20,
              color: Color(0xFF2D2A26), letterSpacing: -0.5)),
          Text(label, style: TextStyle(fontFamily: 'Urbanist',
              fontWeight: FontWeight.w700, fontSize: 8,
              letterSpacing: 1.0,
              color: const Color(0xFF2D2A26).withOpacity(0.38))),
        ]),
      ]),
    );
  }
}