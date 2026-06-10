import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/admin_sidebar.dart';
import 'package:frontend/core/widgets/admin_header.dart';
import 'package:frontend/core/models/review_model.dart';
import 'package:frontend/core/services/admin/reviews_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE
// ─────────────────────────────────────────────────────────────────────────────

const Color _white   = Color(0xFFFFFFFF);
const Color _surface = Color(0xFFF7F3EE);   // warm tinted rows
const Color _border  = Color(0xFFE8DDD0);   // beige-tinted border
const Color _green1  = Color(0xFF3D5A45);
const Color _green2  = Color(0xFF758C6D);
const Color _gold    = Color(0xFFA98258);
const Color _dark    = Color(0xFF2D2A26);
const Color _sub     = Color(0xFF7A7067);
const Color _red     = Color(0xFFDC2626);
const Color _beige   = Color(0xFFEFE2C9);

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ReviewsScreen extends StatefulWidget {
  final int activeIndex;
  final VoidCallback onLogout;
  const ReviewsScreen(
      {super.key, this.activeIndex = 5, required this.onLogout});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<ReviewModel> _all = [];
  bool _isLoading = true;
  String _error = '';
  String _segment = 'ALL';
  String _sortBy  = 'Newest';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final data = await ReviewService.fetchAll();
      setState(() { _all = data; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  // ── Derived ───────────────────────────────────────────────────────────────

  List<ReviewModel> get _visible {
    List<ReviewModel> list = List.from(_all);
    switch (_segment) {
      case 'PUBLISHED': list = list.where((r) => r.status == ReviewStatus.published).toList(); break;
      case 'ARCHIVED':  list = list.where((r) => r.status == ReviewStatus.archived).toList();  break;
      case 'PENDING':   list = list.where((r) => r.status == ReviewStatus.pending).toList();   break;
    }
    switch (_sortBy) {
      case 'Newest':  list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt)); break;
      case 'Oldest':  list.sort((a, b) => a.submittedAt.compareTo(b.submittedAt)); break;
      case 'Highest': list.sort((a, b) => b.rating.compareTo(a.rating));           break;
      case 'Lowest':  list.sort((a, b) => a.rating.compareTo(b.rating));           break;
    }
    return list;
  }

  int    get _totalCount     => _all.length;
  int    get _publishedCount => _all.where((r) => r.status == ReviewStatus.published).length;
  int    get _pendingCount   => _all.where((r) => r.status == ReviewStatus.pending).length;
  int    get _archivedCount  => _all.where((r) => r.status == ReviewStatus.archived).length;
  double get _avgRating      => _all.isEmpty ? 0 : _all.map((r) => r.rating).reduce((a, b) => a + b) / _all.length;

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _publish(ReviewModel r) async {
    await ReviewService.publish(r.id);
    _updateStatus(r.id, ReviewStatus.published);
    _snack('Review published', Icons.check_circle_outline_rounded, _green1);
  }

  Future<void> _republish(ReviewModel r) async {
    await ReviewService.republish(r.id);
    _updateStatus(r.id, ReviewStatus.published);
    _snack('Review re-published', Icons.refresh_rounded, _green1);
  }

  Future<void> _archive(ReviewModel r) async {
    await ReviewService.archive(r.id);
    _updateStatus(r.id, ReviewStatus.archived);
    _snack('Review archived', Icons.archive_outlined, _gold);
  }

  void _updateStatus(String id, ReviewStatus s) {
    setState(() {
      final i = _all.indexWhere((x) => x.id == id);
      if (i != -1) _all[i] = _all[i].copyWith(status: s);
    });
  }

  Future<void> _confirmDelete(ReviewModel r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(customerName: r.customerName),
    );
    if (confirmed == true) {
      await ReviewService.delete(r.id);
      setState(() => _all.removeWhere((x) => x.id == r.id));
      _snack('Review deleted', Icons.delete_outline_rounded, _red);
    }
  }

  void _snack(String msg, IconData icon, Color color) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 8),
          Text(msg, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Sidebar(activeIndex: widget.activeIndex, onLogout: widget.onLogout),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminHeader(title: 'REVIEWS', onLogout: widget.onLogout),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryRow(),
                        const SizedBox(height: 20),
                        _buildToolbar(),
                        const SizedBox(height: 16),
                        Expanded(child: _buildBody()),
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

  // ── Summary row ───────────────────────────────────────────────────────────

  Widget _buildSummaryRow() {
    return Row(children: [
      _SummaryCard(label: 'Total',     value: '$_totalCount',                  icon: Icons.rate_review_outlined,        accent: _green2),
      const SizedBox(width: 12),
      _SummaryCard(label: 'Published', value: '$_publishedCount',              icon: Icons.check_circle_outline_rounded, accent: _green1),
      const SizedBox(width: 12),
      _SummaryCard(label: 'Pending',   value: '$_pendingCount',                icon: Icons.hourglass_top_rounded,        accent: _gold),
      const SizedBox(width: 12),
      _SummaryCard(label: 'Archived',  value: '$_archivedCount',               icon: Icons.archive_outlined,             accent: _sub),
      const SizedBox(width: 12),
      _SummaryCard(label: 'Avg Rating',value: _avgRating.toStringAsFixed(1),   icon: Icons.star_rounded,                 accent: Colors.amber.shade600),
    ]);
  }

  // ── Toolbar ───────────────────────────────────────────────────────────────

  Widget _buildToolbar() {
    const segments = ['ALL', 'PENDING', 'PUBLISHED', 'ARCHIVED'];
    return Row(children: [
      // Segmented control — beige pill container
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _beige,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: segments.map((s) {
            final active = _segment == s;
            return GestureDetector(
              onTap: () => setState(() => _segment = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? _green1 : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: active
                      ? [BoxShadow(color: _green1.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Text(s,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.4,
                    color: active ? Colors.white : _dark.withOpacity(0.6),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),

      const Spacer(),

      // Refresh
      _IconToolBtn(icon: Icons.refresh_rounded, onTap: _load, tooltip: 'Refresh'),
      const SizedBox(width: 10),

      // Sort dropdown
      _SortDropdown(
        value: _sortBy,
        options: const ['Newest', 'Oldest', 'Highest', 'Lowest'],
        onChanged: (v) => setState(() => _sortBy = v),
      ),
    ]);
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _green1));
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off_rounded, size: 40, color: _sub.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text('Could not load reviews',
              style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.w600, color: _dark.withOpacity(0.5))),
          const SizedBox(height: 4),
          Text('Check your connection and try again.',
              style: const TextStyle(fontFamily: 'Urbanist', fontSize: 12, color: _sub)),
          const SizedBox(height: 16),
          _PillBtn(label: 'Retry', icon: Icons.refresh_rounded, color: _green1, onTap: _load),
        ]),
      );
    }

    final items = _visible;
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: _beige, shape: BoxShape.circle),
            child: Icon(Icons.inbox_rounded, size: 30, color: _gold.withOpacity(0.6)),
          ),
          const SizedBox(height: 14),
          Text('No reviews here yet',
              style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.w700, color: _dark)),
          const SizedBox(height: 4),
          Text(
            _segment == 'ALL'
                ? 'Submitted reviews will appear here.'
                : 'No ${_segment.toLowerCase()} reviews at the moment.',
            style: const TextStyle(fontFamily: 'Urbanist', fontSize: 12, color: _sub),
          ),
        ]),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: _white,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          _TableHeader(),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: _border),
              itemBuilder: (_, i) => _ReviewRow(
                review: items[i],
                isEven: i.isEven,
                onPublish:   () => _publish(items[i]),
                onArchive:   () => _archive(items[i]),
                onDelete:    () => _confirmDelete(items[i]),
                onRepublish: () => _republish(items[i]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLE HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: 'Urbanist',
      fontWeight: FontWeight.w800,
      fontSize: 10,
      letterSpacing: 1.2,
      color: _sub,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        // Warm beige header — pulls from palette
        color: _beige,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(children: [
        const SizedBox(width: 44),
        SizedBox(width: 160, child: Text('CUSTOMER', style: style)),
        SizedBox(width: 90,  child: Text('RATING',   style: style)),
        SizedBox(width: 120, child: Text('DATE',     style: style)),
        const Expanded(      child: Text('REVIEW',   style: style)),
        SizedBox(width: 110, child: Text('STATUS',   style: style, textAlign: TextAlign.center)),
        SizedBox(width: 120, child: Text('ACTIONS',  style: style, textAlign: TextAlign.right)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REVIEW ROW
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewRow extends StatelessWidget {
  final ReviewModel review;
  final bool isEven;
  final VoidCallback onPublish, onArchive, onDelete, onRepublish;

  const _ReviewRow({
    required this.review,
    required this.isEven,
    required this.onPublish,
    required this.onArchive,
    required this.onDelete,
    required this.onRepublish,
  });

  @override
  Widget build(BuildContext context) {
    final d = review.submittedAt;
    final dateStr =
        '${_p(d.month)}/${_p(d.day)}/${d.year}\n${_p(d.hour % 12 == 0 ? 12 : d.hour % 12)}:${_p(d.minute)} ${d.hour >= 12 ? 'PM' : 'AM'}';

    return Container(
      color: isEven ? _white : _surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

        // Avatar — green-tinted initials
        CircleAvatar(
          radius: 18,
          backgroundColor: _green2.withOpacity(0.15),
          backgroundImage: review.avatarUrl != null ? NetworkImage(review.avatarUrl!) : null,
          child: review.avatarUrl == null
              ? Text(
                  review.customerName.isNotEmpty ? review.customerName[0].toUpperCase() : '?',
                  style: const TextStyle(
                      fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 14, color: _green1))
              : null,
        ),
        const SizedBox(width: 8),

        // Customer name + ID
        SizedBox(
          width: 152,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(review.customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 13, color: _dark)),
            const SizedBox(height: 2),
            Text(review.customerId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Urbanist', fontSize: 10, color: _sub)),
          ]),
        ),

        // Rating — amber stars + number
        SizedBox(
          width: 90,
          child: Row(children: [
            Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade600),
            const SizedBox(width: 4),
            Text(review.rating.toStringAsFixed(1),
                style: const TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w800, fontSize: 13, color: _dark)),
          ]),
        ),

        // Date
        SizedBox(
          width: 120,
          child: Text(dateStr,
              style: const TextStyle(
                  fontFamily: 'Urbanist', fontSize: 11, height: 1.5, color: _sub)),
        ),

        // Review text
        Expanded(
          child: Text(review.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'Urbanist', fontSize: 12, height: 1.5, color: _dark.withOpacity(0.8))),
        ),

        // Status badge
        SizedBox(
          width: 110,
          child: Center(child: _StatusBadge(status: review.status)),
        ),

        // Action buttons
        SizedBox(
          width: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (review.status == ReviewStatus.pending)
                _RowIconBtn(icon: Icons.check_rounded, tooltip: 'Publish', color: _green1, onTap: onPublish),
              if (review.status == ReviewStatus.published)
                _RowIconBtn(icon: Icons.archive_outlined, tooltip: 'Archive', color: _gold, onTap: onArchive),
              if (review.status == ReviewStatus.archived)
                _RowIconBtn(icon: Icons.refresh_rounded, tooltip: 'Re-publish', color: _green1, onTap: onRepublish),
              const SizedBox(width: 6),
              _RowIconBtn(icon: Icons.delete_outline_rounded, tooltip: 'Delete', color: _red, onTap: onDelete),
            ],
          ),
        ),
      ]),
    );
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final ReviewStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;
    final IconData icon;

    switch (status) {
      case ReviewStatus.published:
        // Green from palette
        bg = _green1.withOpacity(0.10); fg = _green1;
        label = 'Published'; icon = Icons.check_circle_rounded;
        break;
      case ReviewStatus.archived:
        // Neutral warm-gray
        bg = _border; fg = _sub;
        label = 'Archived'; icon = Icons.archive_rounded;
        break;
      case ReviewStatus.pending:
        // Gold from palette
        bg = _gold.withOpacity(0.12); fg = _gold;
        label = 'Pending'; icon = Icons.hourglass_top_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: fg),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 10, color: fg)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUMMARY CARD
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final Color accent;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
          boxShadow: [BoxShadow(color: _dark.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          // Icon dot — uses palette accent
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 20, color: accent)),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Urbanist', fontSize: 10, fontWeight: FontWeight.w600, color: _sub)),
          ]),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _RowIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _RowIconBtn({required this.icon, required this.tooltip, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: color.withOpacity(0.22)),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

class _IconToolBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _IconToolBtn({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
          ),
          child: Icon(icon, size: 16, color: _sub),
        ),
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PillBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
        ]),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _SortDropdown({required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.sort_rounded, size: 14, color: _sub),
        const SizedBox(width: 6),
        DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _sub, size: 16),
          style: const TextStyle(fontFamily: 'Urbanist', fontSize: 12, fontWeight: FontWeight.w600, color: _dark),
          dropdownColor: _white,
          items: options.map((o) => DropdownMenuItem(
            value: o,
            child: Text(o, style: const TextStyle(fontFamily: 'Urbanist', fontSize: 12)),
          )).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELETE DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _DeleteDialog extends StatelessWidget {
  final String customerName;
  const _DeleteDialog({required this.customerName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: _white,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: _red.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.delete_outline_rounded, color: _red, size: 24),
          ),
          const SizedBox(height: 16),
          const Text('Delete Review',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900, fontSize: 16, color: _dark)),
          const SizedBox(height: 8),
          Text(
            'Permanently delete the review from $customerName? This cannot be undone.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Urbanist', fontSize: 13, height: 1.5, color: _sub),
          ),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _beige,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _border),
                ),
                child: const Text('Cancel',
                    style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 13, color: _dark)),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(8)),
                child: const Text('Delete',
                    style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}