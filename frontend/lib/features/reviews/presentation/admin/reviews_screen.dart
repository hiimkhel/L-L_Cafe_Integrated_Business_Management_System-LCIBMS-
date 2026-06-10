import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/admin_sidebar.dart';
import 'package:frontend/core/widgets/admin_header.dart';
import 'package:frontend/config/theme/app_colors.dart';
import 'package:frontend/core/models/review_model.dart';
import 'package:frontend/core/services/admin/reviews_service.dart';
// ─────────────────────────────────────────────────────────────────────────────
// PALETTE
// ─────────────────────────────────────────────────────────────────────────────

const Color _card    = Color(0xFFF7F0E4);
const Color _green1  = Color(0xFF3D5A45);
const Color _green2  = Color(0xFF758C6D);
const Color _gold    = Color(0xFFA98258);
const Color _dark    = Color(0xFF2D2A26);

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ReviewsScreen extends StatefulWidget {
  final int activeIndex;
  final VoidCallback onLogout;
  const ReviewsScreen({super.key, this.activeIndex = 5, required this.onLogout});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  // ── State ─────────────────────────────────────────────────────────────────
  List<ReviewModel> _all = [];
  bool _isLoading = true;
  String _error   = '';

  String _segment = 'ALL';    // ALL | PUBLISHED | ARCHIVED | PENDING
  String _sortBy  = 'Newest'; // Newest | Oldest | Highest | Lowest

  // ── Lifecycle ─────────────────────────────────────────────────────────────
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



  // ── Filtering + sorting ───────────────────────────────────────────────────
  List<ReviewModel> get _visible {
    List<ReviewModel> list = List.from(_all);

    // Segment filter
    switch (_segment) {
      case 'PUBLISHED': list = list.where((r) => r.status == ReviewStatus.published).toList(); break;
      case 'ARCHIVED':  list = list.where((r) => r.status == ReviewStatus.archived).toList();  break;
      case 'PENDING':   list = list.where((r) => r.status == ReviewStatus.pending).toList();   break;
    }

    // Sort
    switch (_sortBy) {
      case 'Newest':  list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt)); break;
      case 'Oldest':  list.sort((a, b) => a.submittedAt.compareTo(b.submittedAt)); break;
      case 'Highest': list.sort((a, b) => b.rating.compareTo(a.rating));           break;
      case 'Lowest':  list.sort((a, b) => a.rating.compareTo(b.rating));           break;
    }

    return list;
  }

  // ── Summary counts ────────────────────────────────────────────────────────
  int get _totalCount     => _all.length;
  int get _publishedCount => _all.where((r) => r.status == ReviewStatus.published).length;
  int get _pendingCount   => _all.where((r) => r.status == ReviewStatus.pending).length;
  int get _archivedCount  => _all.where((r) => r.status == ReviewStatus.archived).length;
  double get _avgRating   => _all.isEmpty ? 0 : _all.map((r) => r.rating).reduce((a, b) => a + b) / _all.length;

  // ── Actions ───────────────────────────────────────────────────────────────
  Future<void> _publish(ReviewModel r) async {
    await ReviewService.publish(r.id);
    setState(() {
      final i = _all.indexWhere((x) => x.id == r.id);
      if (i != -1) _all[i] = _all[i].copyWith(status: ReviewStatus.published);
    });
    _showSnack('Review published', Icons.check_circle_outline_rounded, _green1);
  }

  Future<void> _republish(ReviewModel r) async {
    await ReviewService.republish(r.id);

    setState(() {
      final i = _all.indexWhere((x) => x.id == r.id);

      if (i != -1) {
        _all[i] = _all[i].copyWith(
          status: ReviewStatus.published,
        );
      }
    });

    _showSnack(
      'Review re-published',
      Icons.refresh_rounded,
      _green1,
    );
  }

  Future<void> _archive(ReviewModel r) async {
    await ReviewService.archive(r.id);
    setState(() {
      final i = _all.indexWhere((x) => x.id == r.id);
      if (i != -1) _all[i] = _all[i].copyWith(status: ReviewStatus.archived);
    });
    _showSnack('Review archived', Icons.archive_outlined, _gold);
  }

  Future<void> _confirmDelete(ReviewModel r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text('Delete Review',
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                fontSize: 16, color: _dark)),
        content: Text(
          'Are you sure you want to permanently delete this review from ${r.customerName}? This cannot be undone.',
          style: TextStyle(fontFamily: 'Urbanist', fontSize: 13, color: _dark.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700, color: _green2)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(fontFamily: 'Urbanist',
                fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ReviewService.delete(r.id);
      setState(() => _all.removeWhere((x) => x.id == r.id));
      _showSnack('Review deleted', Icons.delete_outline_rounded, const Color(0xFFDC2626));
    }
  }

  void _showSnack(String msg, IconData icon, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(msg, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary row
                        _buildSummaryRow(),
                        const SizedBox(height: 20),
                        // Toolbar
                        _buildToolbar(),
                        const SizedBox(height: 16),
                        // List
                        Expanded(child: _buildList()),
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
    return Row(
      children: [
        _StatChip(label: 'TOTAL',     value: '$_totalCount',                      color: _green2),
        const SizedBox(width: 10),
        _StatChip(label: 'PUBLISHED', value: '$_publishedCount',                  color: _green1),
        const SizedBox(width: 10),
        _StatChip(label: 'PENDING',   value: '$_pendingCount',                    color: _gold),
        const SizedBox(width: 10),
        _StatChip(label: 'ARCHIVED',  value: '$_archivedCount',                   color: const Color(0xFF8A8070)),
        const SizedBox(width: 10),
        _StatChip(label: 'AVG RATING',value: _avgRating.toStringAsFixed(1),       color: Colors.amber.shade700,
            icon: Icons.star_rounded),
      ],
    );
  }

  // ── Toolbar ───────────────────────────────────────────────────────────────

  Widget _buildToolbar() {
    const segments = ['ALL', 'PENDING', 'PUBLISHED', 'ARCHIVED'];

    return Row(
      children: [
        // Segment filter
        ...segments.map((s) {
          final active = _segment == s;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _segment = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: active ? _green1 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: active ? _green1 : _green2.withOpacity(0.3)),
                  boxShadow: active
                      ? [BoxShadow(color: _green1.withOpacity(0.25),
                            blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Text(s,
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.5,
                        color: active ? Colors.white : _green1)),
              ),
            ),
          );
        }),

        const Spacer(),

        // Refresh
        _ToolbarBtn(icon: Icons.refresh_rounded, onTap: _load, tooltip: 'Refresh'),
        const SizedBox(width: 10),

        // Sort dropdown
        _SortDropdown(
          value: _sortBy,
          options: const ['Newest', 'Oldest', 'Highest', 'Lowest'],
          onChanged: (v) => setState(() => _sortBy = v),
        ),
      ],
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline_rounded, size: 40, color: _green2.withOpacity(0.4)),
          const SizedBox(height: 10),
          Text('Failed to load reviews',
              style: TextStyle(fontFamily: 'Urbanist', color: _dark.withOpacity(0.5))),
          const SizedBox(height: 8),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ]),
      );
    }

    final items = _visible;
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.rate_review_outlined, size: 48, color: _green2.withOpacity(0.25)),
          const SizedBox(height: 12),
          Text('No reviews in this category',
              style: TextStyle(fontFamily: 'Urbanist', fontSize: 13,
                  color: _dark.withOpacity(0.45))),
        ]),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ReviewCard(
        review: items[i],
        onPublish: () => _publish(items[i]),
        onArchive: () => _archive(items[i]),
        onDelete:  () => _confirmDelete(items[i]),
        onRepublish: () => _republish(items[i])
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REVIEW CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onPublish;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onRepublish;

  const _ReviewCard({
    required this.review,
    required this.onPublish,
    required this.onArchive,
    required this.onDelete,
    required this.onRepublish
  });

  @override
  Widget build(BuildContext context) {
    final d = review.submittedAt;
    final dateStr =
        '${_p(d.month)}/${_p(d.day)}/${d.year}  ${_p(d.hour % 12 == 0 ? 12 : d.hour % 12)}:${_p(d.minute)} ${d.hour >= 12 ? 'PM' : 'AM'}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusBorderColor.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
              color: _dark.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar ───────────────────────────────────────────────────────
          Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: _green2.withOpacity(0.15),
                backgroundImage: review.avatarUrl != null
                    ? NetworkImage(review.avatarUrl!)
                    : null,
                child: review.avatarUrl == null
                    ? Text(
                        review.customerName.isNotEmpty
                            ? review.customerName[0]
                            : '?',
                        style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: _green1))
                    : null,
              ),
              const SizedBox(height: 8),
              _StatusBadge(status: review.status),
            ],
          ),

          const SizedBox(width: 16),

          // ── Customer info ────────────────────────────────────────────────
          SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.customerId,
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 11,
                        color: _green2.withOpacity(0.8))),
                const SizedBox(height: 2),
                Text(review.customerName,
                    style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: _dark)),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.access_time_rounded, size: 11,
                      color: _green2.withOpacity(0.55)),
                  const SizedBox(width: 4),
                  Text(dateStr,
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 10,
                          color: _dark.withOpacity(0.45))),
                ]),
                const SizedBox(height: 10),
                // Star rating
                Row(children: [
                  ...List.generate(5, (i) => Icon(
                    i < review.rating.floor()
                        ? Icons.star_rounded
                        : (i < review.rating
                            ? Icons.star_half_rounded
                            : Icons.star_border_rounded),
                    color: Colors.amber.shade600,
                    size: 16,
                  )),
                  const SizedBox(width: 6),
                  Text(review.rating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: _dark)),
                ]),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // ── Review content ───────────────────────────────────────────────
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _green2.withOpacity(0.1)),
              ),
              child: SelectableText( // Use SelectableText for better admin usability
                review.content.isEmpty ? "No review text provided." : review.content,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14, // Increased size slightly
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A), // Deep black/grey for readability
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // ── Action buttons ───────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              // PENDING → Publish
              if (review.status == ReviewStatus.pending)
                _ActionBtn(
                  label: 'PUBLISH',
                  icon: Icons.check_circle_outline_rounded,
                  color: _green1,
                  onTap: onPublish,
                ),

              // PUBLISHED → Archive
              if (review.status == ReviewStatus.published)
                _ActionBtn(
                  label: 'ARCHIVE',
                  icon: Icons.archive_outlined,
                  color: _gold,
                  onTap: onArchive,
                ),

              // ARCHIVED → Re-publish
              if (review.status == ReviewStatus.archived)
                _ActionBtn(
                  label: 'RE-PUBLISH',
                  icon: Icons.refresh_rounded,
                  color: _green1,
                  onTap: onPublish,
                ),

              const SizedBox(height: 8),

              // DELETE (always available)
              _ActionBtn(
                label: 'DELETE',
                icon: Icons.delete_outline_rounded,
                color: const Color(0xFFDC2626),
                onTap: onDelete,
              ),
            ],
          )
        ],
      ),
    );
  }

  Color get _statusBorderColor {
    switch (review.status) {
      case ReviewStatus.published: return _green1;
      case ReviewStatus.archived:  return const Color(0xFF8A8070);
      case ReviewStatus.pending:   return _gold;
    }
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
    final Color color;
    final String label;
    final IconData icon;

    switch (status) {
      case ReviewStatus.published:
        color = _green1; label = 'PUBLISHED'; icon = Icons.check_circle_rounded; break;
      case ReviewStatus.archived:
        color = const Color(0xFF8A8070); label = 'ARCHIVED'; icon = Icons.archive_rounded; break;
      case ReviewStatus.pending:
        color = _gold; label = 'PENDING'; icon = Icons.hourglass_empty_rounded; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w800,
                fontSize: 8,
                letterSpacing: 0.5,
                color: color)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.5,
                  color: color)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData? icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
        ],
        Text(value,
            style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: color)),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: color.withOpacity(0.65))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SORT DROPDOWN
// ─────────────────────────────────────────────────────────────────────────────

class _SortDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _SortDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _green2.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: _dark.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.sort_rounded, size: 14, color: _green2.withOpacity(0.7)),
        const SizedBox(width: 6),
        DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _green2, size: 16),
          style: const TextStyle(fontFamily: 'Urbanist', fontSize: 12,
              fontWeight: FontWeight.w700, color: _dark),
          dropdownColor: Colors.white,
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
// TOOLBAR BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _ToolbarBtn({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _green2.withOpacity(0.25)),
          ),
          child: Icon(icon, size: 16, color: _green2),
        ),
      ),
    );
  }
}