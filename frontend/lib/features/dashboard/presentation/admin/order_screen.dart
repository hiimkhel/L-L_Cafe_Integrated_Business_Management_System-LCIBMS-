import 'package:flutter/material.dart';
import '../../../../core/widgets/admin_header.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../config/theme/app_colors.dart';
import 'package:frontend/core/models/admin_order.dart';
import 'package:frontend/core/services/admin/order_service.dart';


final _now = DateTime.now();

const _kCols = [
  _Col('DATE / TIME', flex: 3), // e.g. 05/03/2026  3:37 PM
  _Col('ORDER ID',    flex: 2),
  _Col('CUSTOMER',    flex: 3),
  _Col('ITEMS',       flex: 1),
  _Col('TYPE',        flex: 2),
  _Col('STATUS',      flex: 3), // ← widened to fit "OUT FOR DELIVERY"
  _Col('TOTAL',       flex: 2),
  _Col('',            flex: 2), // actions
];

// ─────────────────────────────────────────────────────────────────────────────
// ORDER SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class OrderScreen extends StatefulWidget {
  final int activeIndex;
  final VoidCallback onLogout;

  const OrderScreen({super.key, this.activeIndex = 1, required this.onLogout});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _quickFilter = 'TODAY';
  DateTimeRange? _customRange;
  String _searchQuery = '';
  String _statusFilter = 'ALL';
  final _searchCtrl = TextEditingController();
  final orderService = OrderService();


  List<AdminOrder> _orders = [];
  bool isLoading = true;
  String? errorMessage;

  
  int get _totalOrders => _orders.length;

  double get _totalRevenue =>
      _orders.fold(0, (sum, o) => sum + o.total);

  int get _pendingCount =>
      _orders.where(
        (o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.preparing,
      ).length;

  int get _completedCount =>
      _orders.where(
        (o) => o.status == OrderStatus.completed,
      ).length;

  String _fmt(DateTime dt) {
    final h    = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m    = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '${dt.month.toString().padLeft(2,'0')}/${dt.day.toString().padLeft(2,'0')}/${dt.year}  $h:$m $ampm';
  }

  String _rangeLabel() {
    if (_customRange != null) {
      final s = _customRange!.start;
      final e = _customRange!.end;
      const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
      return '${months[s.month-1]} ${s.day} – ${months[e.month-1]} ${e.day}, ${e.year}';
    }
    return 'SELECT DATE RANGE';
  }

  Future<void> _pickDateRange(BuildContext context, Offset tapPosition) async {
    final initial = _customRange ?? DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 6)),
      end: DateTime.now(),
    );

    DateTime? startDate = initial.start;
    DateTime? endDate   = initial.end;
    DateTime displayMonth = DateTime(initial.end.year, initial.end.month);

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.18),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setLocal) {
          int daysInMonth(int y, int m) => DateTime(y, m + 1, 0).day;
          int firstWeekday(int y, int m) => DateTime(y, m, 1).weekday % 7;

          void prevMonth() => setLocal(() {
            displayMonth = DateTime(displayMonth.year, displayMonth.month - 1);
          });
          void nextMonth() => setLocal(() {
            displayMonth = DateTime(displayMonth.year, displayMonth.month + 1);
          });

          bool isSelected(DateTime d) {
            if (startDate == null) return false;
            if (endDate   == null) return isSameDay(d, startDate!);
            return !d.isBefore(startDate!) && !d.isAfter(endDate!);
          }

          bool isStart(DateTime d) => startDate != null && isSameDay(d, startDate!);
          bool isEnd  (DateTime d) => endDate   != null && isSameDay(d, endDate!);

          final dim    = daysInMonth(displayMonth.year, displayMonth.month);
          final offset = firstWeekday(displayMonth.year, displayMonth.month);
          final today  = DateTime.now();

          const months = ['January','February','March','April','May','June',
                          'July','August','September','October','November','December'];

          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 380,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15),
                        blurRadius: 30, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withOpacity(0.06),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        border: Border(bottom: BorderSide(color: AppColors.tertiary.withOpacity(0.1))),
                      ),
                      child: Row(children: [
                        Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.tertiary),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SELECT DATE RANGE',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2, color: AppColors.tertiary.withOpacity(0.6))),
                            const SizedBox(height: 2),
                            Text(
                              startDate == null
                                  ? 'Pick start date'
                                  : endDate == null
                                      ? '${_shortDate(startDate!)} → pick end'
                                      : '${_shortDate(startDate!)}  –  ${_shortDate(endDate!)}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                                  color: AppColors.tertiary),
                            ),
                          ],
                        )),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded, size: 14, color: AppColors.tertiary),
                          ),
                        ),
                      ]),
                    ),

                    // Month navigation
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(children: [
                        _NavBtn(icon: Icons.chevron_left_rounded, onTap: prevMonth),
                        Expanded(child: Text(
                          '${months[displayMonth.month - 1]} ${displayMonth.year}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.tertiary),
                        )),
                        _NavBtn(icon: Icons.chevron_right_rounded,
                            onTap: displayMonth.isBefore(DateTime(today.year, today.month))
                                ? nextMonth : null),
                      ]),
                    ),

                    // Day headers
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: ['S','M','T','W','T','F','S'].map((d) => Expanded(
                          child: Center(child: Text(d,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                  color: AppColors.tertiary.withOpacity(0.4)))),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Calendar grid
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7, mainAxisSpacing: 2, crossAxisSpacing: 2,
                            childAspectRatio: 1),
                        itemCount: dim + offset,
                        itemBuilder: (_, idx) {
                          if (idx < offset) return const SizedBox();
                          final day  = idx - offset + 1;
                          final date = DateTime(displayMonth.year, displayMonth.month, day);
                          final isFuture = date.isAfter(today);
                          final selected = isSelected(date);
                          final start    = isStart(date);
                          final end      = isEnd(date);
                          final isToday  = isSameDay(date, today);

                          return GestureDetector(
                            onTap: isFuture ? null : () {
                              setLocal(() {
                                if (startDate == null || (startDate != null && endDate != null)) {
                                  startDate = date; endDate = null;
                                } else {
                                  if (date.isBefore(startDate!)) {
                                    endDate = startDate; startDate = date;
                                  } else { endDate = date; }
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: start || end
                                    ? AppColors.tertiary
                                    : selected ? AppColors.tertiary.withOpacity(0.12) : Colors.transparent,
                                borderRadius: start
                                    ? const BorderRadius.horizontal(left: Radius.circular(8))
                                    : end
                                        ? const BorderRadius.horizontal(right: Radius.circular(8))
                                        : selected ? BorderRadius.zero : BorderRadius.circular(8),
                                border: isToday && !selected && !start && !end
                                    ? Border.all(color: AppColors.tertiary.withOpacity(0.4)) : null,
                              ),
                              child: Center(child: Text('$day',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: start || end ? FontWeight.w800 : FontWeight.w500,
                                    color: start || end ? Colors.white
                                        : isFuture ? AppColors.tertiary.withOpacity(0.2) : AppColors.tertiary,
                                  ))),
                            ),
                          );
                        },
                      ),
                    ),

                    // Actions
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: AppColors.tertiary.withOpacity(0.1)))),
                      child: Row(children: [
                        TextButton(
                          onPressed: () => setLocal(() { startDate = null; endDate = null; }),
                          style: TextButton.styleFrom(foregroundColor: AppColors.tertiary.withOpacity(0.5)),
                          child: const Text('CLEAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.tertiary,
                            side: BorderSide(color: AppColors.tertiary.withOpacity(0.3)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('CANCEL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: startDate != null && endDate != null
                              ? () async {
                                  setState(() {
                                    _customRange = DateTimeRange(start: startDate!, end: endDate!);
                                    _quickFilter = '';
                                  });
                                  await loadOrders();
                                  Navigator.pop(ctx);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.tertiary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.tertiary.withOpacity(0.25),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text('APPLY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _shortDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  void _clearDateRange() =>
      setState(() { _customRange = null; _quickFilter = 'TODAY'; });

  void _updateStatus(AdminOrder order, OrderStatus newStatus) {
    setState(() {
      final idx = _orders.indexWhere((o) => o.id == order.id);
      if (idx != -1) _orders[idx] = _orders[idx].copyWith(status: newStatus);
    });
    // TODO: await orderService.updateStatus(order.id, newStatus);
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> loadOrders() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      String? startDate;
      String? endDate;

      if (_customRange != null) {
        startDate =
            _customRange!.start.toIso8601String().split('T')[0];

        endDate =
            _customRange!.end.toIso8601String().split('T')[0];
      } else {
        final now = DateTime.now();

        switch (_quickFilter) {
          case 'TODAY':
            startDate =
                DateTime(now.year, now.month, now.day)
                    .toIso8601String()
                    .split('T')[0];

            endDate = startDate;
            break;

          case 'YESTERDAY':
            final y =
                now.subtract(const Duration(days: 1));

            startDate =
                DateTime(y.year, y.month, y.day)
                    .toIso8601String()
                    .split('T')[0];

            endDate = startDate;
            break;

          case 'LAST 7 DAYS':
            startDate =
                now.subtract(const Duration(days: 7))
                    .toIso8601String()
                    .split('T')[0];

            endDate =
                now.toIso8601String().split('T')[0];
            break;
        }
      }

      final orders = await orderService.getOrders(
        startDate: startDate,
        endDate: endDate,
        status:
            _statusFilter == 'ALL'
                ? null
                : _statusFilter,
        search:
            _searchQuery.trim().isEmpty
                ? null
                : _searchQuery.trim(),
      );
      print("Orders:");
      print(orders);
      setState(() {
        _orders = orders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadOrders();
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Row(
        children: [
          Sidebar(activeIndex: 1, onLogout: widget.onLogout),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminHeader(title: 'ORDERS', onLogout: widget.onLogout),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildStats(),
                        const SizedBox(height: 20),
                        _buildFilterRow(),
                        const SizedBox(height: 16),
                        Expanded(child: _buildTable()),
                      ],
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

  // ── Stats ─────────────────────────────────────────────────────────────────
  Widget _buildStats() {
    return Row(children: [
      _StatCard(label: 'TOTAL ORDERS',  value: '$_totalOrders',
          icon: Icons.receipt_long_outlined,        color: AppColors.tertiary),
      const SizedBox(width: 12),
      _StatCard(label: 'TOTAL REVENUE', value: '₱${_totalRevenue.toStringAsFixed(2)}',
          icon: Icons.payments_outlined,            color: const Color(0xFF4CAF50)),
      const SizedBox(width: 12),
      _StatCard(label: 'ACTIVE ORDERS', value: '$_pendingCount',
          icon: Icons.pending_actions_outlined,     color: const Color(0xFFE6A817)),
      const SizedBox(width: 12),
      _StatCard(label: 'COMPLETED',     value: '$_completedCount',
          icon: Icons.check_circle_outline_rounded, color: const Color(0xFF2196F3)),
    ]);
  }

  // ── Filters ───────────────────────────────────────────────────────────────
  Widget _buildFilterRow() {
    const quickFilters  = ['TODAY', 'YESTERDAY', 'LAST 7 DAYS'];
    const statusFilters = ['ALL', 'PENDING', 'PREPARING', 'OUT FOR DELIVERY', 'COMPLETED', 'CANCELLED'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row A — date filters + search
        Row(children: [
          Text('DATE:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
              letterSpacing: 1.2, color: AppColors.tertiary.withOpacity(0.7))),
          const SizedBox(width: 10),

          ...quickFilters.map((f) {
            final active = _customRange == null && _quickFilter == f;
            return GestureDetector(
              onTap: () async {
                setState(() {
                  _quickFilter = f;
                  _customRange = null;
                });

                await loadOrders();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? AppColors.tertiary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? AppColors.tertiary : AppColors.tertiary.withOpacity(0.25)),
                  boxShadow: active ? [BoxShadow(color: AppColors.tertiary.withOpacity(0.2),
                      blurRadius: 6, offset: const Offset(0, 2))] : [],
                ),
                child: Text(f, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: active ? Colors.white : AppColors.tertiary)),
              ),
            );
          }),

          const SizedBox(width: 8),

          GestureDetector(
            onTap: () => _pickDateRange(context, Offset.zero),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _customRange != null ? AppColors.tertiary.withOpacity(0.08) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _customRange != null
                        ? AppColors.tertiary
                        : AppColors.tertiary.withOpacity(0.25)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.calendar_today_outlined, size: 13,
                    color: _customRange != null
                        ? AppColors.tertiary
                        : AppColors.tertiary.withOpacity(0.6)),
                const SizedBox(width: 6),
                Text(_rangeLabel(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: _customRange != null
                        ? AppColors.tertiary
                        : AppColors.tertiary.withOpacity(0.6))),
                if (_customRange != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _clearDateRange,
                    child: Icon(Icons.close_rounded, size: 13, color: AppColors.tertiary),
                  ),
                ],
              ]),
            ),
          ),

          const Spacer(),

          SizedBox(
            width: 230, height: 36,
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => loadOrders(),
              style: TextStyle(fontSize: 12, color: AppColors.tertiary),
              decoration: InputDecoration(
                hintText: 'SEARCH ID OR CUSTOMER...',
                hintStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    letterSpacing: 0.4, color: AppColors.tertiary.withOpacity(0.4)),
                prefixIcon: Icon(Icons.search, size: 16,
                    color: AppColors.tertiary.withOpacity(0.5)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); },
                        child: Icon(Icons.close, size: 14,
                            color: AppColors.tertiary.withOpacity(0.5)))
                    : null,
                filled: true, fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.tertiary.withOpacity(0.25))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.tertiary)),
              ),
            ),
          ),
        ]),

        const SizedBox(height: 10),

        // Row B — status chips
        Row(children: [
          Text('STATUS:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
              letterSpacing: 1.2, color: AppColors.tertiary.withOpacity(0.7))),
          const SizedBox(width: 10),
          ...statusFilters.map((s) {
            final active     = _statusFilter == s;
            final statusEnum = s == 'ALL' ? null
                : OrderStatus.values.firstWhere((e) => e.label == s,
                    orElse: () => OrderStatus.pending);
            return GestureDetector(
              onTap: () async {
                setState(() {
                  _statusFilter = s;
                });

                await loadOrders();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: active
                      ? (statusEnum?.color ?? AppColors.tertiary).withOpacity(0.12)
                      : AppColors.receiptBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? (statusEnum?.color ?? AppColors.tertiary).withOpacity(0.6)
                        : AppColors.tertiary.withOpacity(0.2)),
                ),
                child: Text(s, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: active
                        ? (statusEnum?.color ?? AppColors.tertiary)
                        : AppColors.tertiary.withOpacity(0.6))),
              ),
            );
          }),
          const Spacer(),
          Text('${_orders.length} ORDER${_orders.length == 1 ? '' : 'S'} FOUND',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  letterSpacing: 0.8, color: AppColors.tertiary.withOpacity(0.5))),
        ]),
      ],
    );
  }

  // ── Table ─────────────────────────────────────────────────────────────────
  Widget _buildTable() {
    final orders = _orders;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.tertiary.withOpacity(0.07),
            blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        _buildTableHeader(),
        orders.isEmpty
            ? _buildEmptyState()
            : Expanded(child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (_, i) => _buildRow(orders[i], i),
              )),
      ]),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: AppColors.tertiary.withOpacity(0.12))),
      ),
      child: Row(
        children: _kCols.map((c) => Expanded(
          flex: c.flex,
          child: Padding(
            // ✅ Consistent left padding on every header cell
            padding: const EdgeInsets.only(left: 4),
            child: Text(c.label,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: AppColors.tertiary.withOpacity(0.65))),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildRow(AdminOrder order, int index) {
    final isOnline = order.entryType == 'ONLINE';
    final isPickup = order.entryType == 'PICKUP';
    final isEven   = index.isEven;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : AppColors.background.withOpacity(0.25),
        border: Border(bottom: BorderSide(color: AppColors.tertiary.withOpacity(0.07))),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

        // DATE / TIME  flex:3
        Expanded(flex: _kCols[0].flex, child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(_fmt(order.datetime),
              style: TextStyle(fontSize: 11, color: AppColors.tertiary.withOpacity(0.75))),
        )),

        // ORDER ID  flex:2
        Expanded(flex: _kCols[1].flex, child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.tertiary.withOpacity(0.2)),
              ),
              child: Text(order.id,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                      color: AppColors.tertiary)),
            ),
          ),
        )),

        // CUSTOMER  flex:3
        Expanded(flex: _kCols[2].flex, child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(order.customer,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                      color: Color(0xFF4a3520))),
              if (order.customerPhone != null)
                Text(order.customerPhone!,
                    style: TextStyle(fontSize: 10, color: AppColors.tertiary.withOpacity(0.5))),
            ],
          ),
        )),

        // ITEMS  flex:1
        Expanded(flex: _kCols[3].flex, child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text('${order.itemCount}',
              style: TextStyle(fontSize: 12, color: AppColors.tertiary.withOpacity(0.8))),
        )),

        // TYPE  flex:2
        Expanded(flex: _kCols[4].flex, child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: isOnline ? const Color(0xFFE8F5E9)
                    : isPickup  ? const Color(0xFFE3F2FD)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isOnline ? const Color(0xFF4CAF50).withOpacity(0.35)
                      : isPickup  ? const Color(0xFF2196F3).withOpacity(0.35)
                      : AppColors.tertiary.withOpacity(0.25)),
              ),
              child: Text(order.entryType,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.3,
                      color: isOnline ? const Color(0xFF2E7D32)
                          : isPickup  ? const Color(0xFF1565C0)
                          : AppColors.tertiary)),
            ),
          ),
        )),

        // STATUS  flex:3  ← widened so "OUT FOR DELIVERY" never bleeds
        // AFTER
        Expanded(flex: _kCols[5].flex, child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 8),
          child: Align(
          alignment: Alignment.centerLeft,
          child: _StatusDropdown(
          order: order, onChanged: (s) => _updateStatus(order, s)),
          ),
        )),

        // TOTAL  flex:2
        Expanded(flex: _kCols[6].flex, child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text('₱${order.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                  color: Color(0xFF4a3520))),
        )),

        // ACTIONS  flex:2
        Expanded(flex: _kCols[7].flex, child: Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () => _viewReceipt(order),
            icon: Icon(Icons.receipt_long_outlined, size: 13,
                color: AppColors.tertiary),
            label: Text('VIEW',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    letterSpacing: 0.4, color: AppColors.tertiary)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.tertiary.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        )),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(child: Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long_outlined, size: 48,
            color: AppColors.tertiary.withOpacity(0.2)),
        const SizedBox(height: 12),
        Text(_searchQuery.isNotEmpty
            ? 'No orders match "$_searchQuery"'
            : 'No orders for this period',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: AppColors.tertiary.withOpacity(0.4))),
      ],
    )));
  }

  void _viewReceipt(AdminOrder order) {
    showDialog(context: context, builder: (_) => _ReceiptDialog(order: order));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS DROPDOWN
// ─────────────────────────────────────────────────────────────────────────────

class _StatusDropdown extends StatelessWidget {
  final AdminOrder order;
  final ValueChanged<OrderStatus> onChanged;
  const _StatusDropdown({required this.order, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final s = order.status;
    return GestureDetector(
      onTap: () => _showStatusMenu(context, s),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: s.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: s.color.withOpacity(0.4)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6,
              decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          // ✅ Flexible + overflow ellipsis so long labels never overflow
          Flexible(child: Text(s.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                  letterSpacing: 0.3, color: s.color))),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 13, color: s.color),
        ]),
      ),
    );
  }

  Future<void> _showStatusMenu(BuildContext context, OrderStatus current) async {
    final renderBox  = context.findRenderObject() as RenderBox;
    final offset     = renderBox.localToGlobal(Offset.zero);
    final size       = renderBox.size;
    final screenH    = MediaQuery.of(context).size.height;

    // Each status row ≈ 42px, header ≈ 48px, bottom padding 6px
    const menuHeight = 5 * 42.0 + 48.0 + 6.0;
    final spaceBelow = screenH - (offset.dy + size.height);
    final showAbove  = spaceBelow < menuHeight + 16;

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (ctx) {
        return Stack(children: [
          Positioned.fill(child: GestureDetector(
            onTap: () => Navigator.pop(ctx),
            child: Container(color: Colors.transparent),
          )),
          Positioned(
            left: offset.dx,
            // ✅ If not enough space below, anchor the bottom of the menu
            // to just above the pill instead of going off screen
            top:  showAbove ? null : offset.dy + size.height + 6,
            bottom: showAbove
                ? screenH - offset.dy + 6
                : null,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 210,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.12),
                        blurRadius: 20, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('UPDATE STATUS',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: AppColors.tertiary.withOpacity(0.5))),
                      ),
                    ),
                    Divider(height: 1, color: AppColors.tertiary.withOpacity(0.08)),
                    ...OrderStatus.values.map((status) {
                      final isActive = status == current;
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          if (status != current) onChanged(status);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 11),
                          color: isActive ? status.bg : Colors.transparent,
                          child: Row(children: [
                            Container(width: 8, height: 8,
                                decoration: BoxDecoration(
                                    color: status.color,
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(status.label,
                                style: TextStyle(fontSize: 12,
                                    fontWeight: isActive
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: isActive
                                        ? status.color
                                        : const Color(0xFF4a3520)))),
                            if (isActive)
                              Icon(Icons.check_rounded, size: 14,
                                  color: status.color),
                          ]),
                        ),
                      );
                    }),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CALENDAR NAV BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _NavBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.tertiary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18,
            color: onTap != null
                ? AppColors.tertiary
                : AppColors.tertiary.withOpacity(0.2)),
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
  const _StatCard({required this.label, required this.value,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.07),
              blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                  letterSpacing: 1.0, color: AppColors.tertiary.withOpacity(0.55))),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w900, color: color)),
            ],
          )),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECEIPT DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _ReceiptDialog extends StatelessWidget {
  final AdminOrder order;
  const _ReceiptDialog({required this.order});

  String _fmt(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final h    = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m    = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '${months[dt.month-1]} ${dt.day}, ${dt.year}  $h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('ORDER RECEIPT',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                          letterSpacing: 0.5, color: AppColors.tertiary)),
                  const SizedBox(height: 2),
                  Text(_fmt(order.datetime),
                      style: TextStyle(fontSize: 11,
                          color: AppColors.tertiary.withOpacity(0.5))),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: order.status.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: order.status.color.withOpacity(0.4))),
                  child: Text(order.status.label,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
                          color: order.status.color)),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        color: AppColors.tertiary.withOpacity(0.08)),
                    child: Icon(Icons.close, size: 16, color: AppColors.tertiary),
                  ),
                ),
              ]),

              const SizedBox(height: 20),
              _ReceiptRow(label: 'Order ID',   value: '#${order.id}'),
              _ReceiptRow(label: 'Customer',   value: order.customer),
              if (order.customerPhone != null)
                _ReceiptRow(label: 'Phone', value: order.customerPhone!),
              _ReceiptRow(label: 'Entry Type', value: order.entryType),
              if (order.note != null)
                _ReceiptRow(label: 'Note', value: order.note!),

              const SizedBox(height: 14),
              Divider(color: AppColors.tertiary.withOpacity(0.12)),
              const SizedBox(height: 10),

              Text('ITEMS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
                  letterSpacing: 1.2, color: AppColors.tertiary.withOpacity(0.5))),
              const SizedBox(height: 10),

              Flexible(child: ListView(
                shrinkWrap: true,
                children: order.items.isEmpty
                    ? [Text('No item details.',
                        style: TextStyle(fontSize: 12,
                            color: AppColors.tertiary.withOpacity(0.4)))]
                    : order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          Text('${item.qty}×',
                              style: TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.tertiary)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item.name,
                              style: TextStyle(fontSize: 12,
                                  color: AppColors.tertiary.withOpacity(0.85)))),
                          Text('₱${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4a3520))),
                        ]),
                      )).toList(),
              )),

              Divider(color: AppColors.tertiary.withOpacity(0.12)),
              const SizedBox(height: 10),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('TOTAL',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
                        color: AppColors.tertiary)),
                Text('₱${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                        color: Color(0xFF4a3520))),
              ]),
              const SizedBox(height: 20),

              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Print / export coming soon.')));
                  },
                  icon: Icon(Icons.print_outlined, size: 14, color: AppColors.tertiary),
                  label: Text('PRINT',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: AppColors.tertiary)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.tertiary.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('CLOSE',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _ReceiptRow extends StatelessWidget {
  final String label, value;
  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: AppColors.tertiary.withOpacity(0.5))),
        Flexible(child: Text(value, textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: AppColors.tertiary))),
      ]),
    );
  }
}

class _Col {
  final String label;
  final int flex;
  const _Col(this.label, {required this.flex});
}