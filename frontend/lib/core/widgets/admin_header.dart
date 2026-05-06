import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────

const _kBg    = Color(0xFFEFE2C9);
const _kDark  = Color(0xFF2D2A26);
const _kGreen = Color(0xFF758C6D);
const _kBrown = Color(0xFFA98258);

// ─────────────────────────────────────────────────────────────────────────────
// GLOBAL ADMIN STATE  — singleton, survives page navigation
// ─────────────────────────────────────────────────────────────────────────────

class AdminState extends ChangeNotifier {
  // Private singleton
  AdminState._();
  static final AdminState instance = AdminState._();

  // ── Dark mode ──────────────────────────────────────────────────────────────
  bool _darkMode = false;
  bool get darkMode => _darkMode;
  void toggleDarkMode() {
    _darkMode = !_darkMode;
    notifyListeners();
  }

  // ── Notifications ──────────────────────────────────────────────────────────
  final List<AdminNotif> notifications = [
    AdminNotif(
      id: '1',
      icon: Icons.receipt_long_outlined,
      color: _kGreen,
      title: 'New Order #LL-401',
      body: 'Maria S. placed an order — ₱350',
      time: '2 mins ago',
      isUnread: true,
    ),
    AdminNotif(
      id: '2',
      icon: Icons.star_rounded,
      color: Color(0xFFE6A817),
      title: 'New 5-Star Review',
      body: 'Ana de Leon left a review on Nutella Frappe',
      time: '15 mins ago',
      isUnread: true,
    ),
    AdminNotif(
      id: '3',
      icon: Icons.person_add_outlined,
      color: Color(0xFF4CAF50),
      title: 'New Customer Registered',
      body: 'Jose R. created an account',
      time: '1 hr ago',
      isUnread: true,
    ),
    AdminNotif(
      id: '5',
      icon: Icons.check_circle_outline_rounded,
      color: _kGreen,
      title: 'Order #LL-398 Completed',
      body: 'Liza C.\'s order was delivered',
      time: '5 hrs ago',
      isUnread: false,
    ),
  ];

  int get unreadCount => notifications.where((n) => n.isUnread).length;

  void markAllRead() {
    for (final n in notifications) {
      n.isUnread = false;
    }
    notifyListeners();
  }

  void markRead(String id) {
    final n = notifications.firstWhere((n) => n.id == id,
        orElse: () => notifications.first);
    n.isUnread = false;
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION MODEL
// ─────────────────────────────────────────────────────────────────────────────

class AdminNotif {
  final String id;
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  bool isUnread;

  AdminNotif({
    required this.id,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN HEADER
// ─────────────────────────────────────────────────────────────────────────────

class AdminHeader extends StatefulWidget {
  final String title;
  final VoidCallback onLogout;

  const AdminHeader({
    super.key,
    required this.title,
    required this.onLogout,
  });

  @override
  State<AdminHeader> createState() => _AdminHeaderState();
}

class _AdminHeaderState extends State<AdminHeader> {
  // Listen to the global singleton
  final _state = AdminState.instance;

  @override
  void initState() {
    super.initState();
    // Rebuild this widget whenever global state changes
    _state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  // ── Dark mode ──────────────────────────────────────────────────────────────
  void _toggleDarkMode() {
    _state.toggleDarkMode();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _state.darkMode ? '🌙  DARK MODE — coming soon' : '☀️  LIGHT MODE',
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: _kGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Notifications ──────────────────────────────────────────────────────────
  void _openNotifications() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, _, __) => _NotifPanel(
        state: _state,
        onClose: () => Navigator.pop(ctx),
      ),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0, -0.04), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }

  // ── Settings ───────────────────────────────────────────────────────────────
  void _openSettings() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, _, __) => _SettingsPanel(
        onClose: () => Navigator.pop(ctx),
      ),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0)
              .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  void _confirmLogout() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, _, __) => _LogoutDialog(
        onCancel: () => Navigator.pop(ctx),
        onConfirm: () {
          Navigator.pop(ctx);
          widget.onLogout();
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/', (r) => false);
        },
      ),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final unread = _state.unreadCount;
    final dark   = _state.darkMode;

    return Container(
      height: 64,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: _kBg,
        border:
            Border(bottom: BorderSide(color: _kGreen.withOpacity(0.15))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Title ─────────────────────────────────────────────────────
          Expanded(
            child: Text(
              widget.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: 1.5,
                color: _kGreen,
              ),
            ),
          ),

          // ── Right-side controls ───────────────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dark mode — icon + bg change when active
              _HeaderBtn(
                icon: dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_outlined,
                tooltip: dark ? 'Switch to light mode' : 'Switch to dark mode',
                active: dark,
                onTap: _toggleDarkMode,
              ),
              const SizedBox(width: 6),

              // Notifications — badge persists across pages
              _HeaderBtn(
                icon: Icons.notifications_rounded,
                tooltip: 'Notifications',
                badgeCount: unread,
                onTap: _openNotifications,
              ),
              const SizedBox(width: 6),

              // Settings
              _HeaderBtn(
                icon: Icons.settings_rounded,
                tooltip: 'Settings',
                onTap: _openSettings,
              ),

              // Divider
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                width: 1,
                height: 32,
                color: _kGreen.withOpacity(0.2),
              ),

              // Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: _kGreen.withOpacity(0.4), width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_rounded,
                    color: _kGreen, size: 20),
              ),
              const SizedBox(width: 10),

              // Name + role
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'L&L CAFE',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: _kBrown,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    'ADMIN',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: _kGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    height: 1.5,
                    width: 32,
                    decoration: BoxDecoration(
                      color: _kGreen.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Logout
              _HeaderBtn(
                icon: Icons.logout_rounded,
                tooltip: 'Logout',
                isDestructive: true,
                onTap: _confirmLogout,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool active;
  final int badgeCount;

  const _HeaderBtn({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.isDestructive = false,
    this.active = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Colors.redAccent
        : active
            ? _kBrown
            : _kGreen;

    return Tooltip(
      message: tooltip,
      preferBelow: true,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.redAccent.withOpacity(0.08)
                    : active
                        ? _kBrown.withOpacity(0.12)
                        : Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: color.withOpacity(isDestructive ? 0.3 : 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 17),
            ),
            if (badgeCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: _kBg, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATIONS PANEL  — StatefulWidget so it rebuilds when state changes
// ─────────────────────────────────────────────────────────────────────────────

class _NotifPanel extends StatefulWidget {
  final AdminState state;
  final VoidCallback onClose;

  const _NotifPanel({required this.state, required this.onClose});

  @override
  State<_NotifPanel> createState() => _NotifPanelState();
}

class _NotifPanelState extends State<_NotifPanel> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.state.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final notifs = widget.state.notifications;
    final unread = widget.state.unreadCount;

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 68, right: 16),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 360,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kGreen.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ───────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  decoration: BoxDecoration(
                    color: _kBg,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    border: Border(
                        bottom: BorderSide(
                            color: _kGreen.withOpacity(0.1))),
                  ),
                  child: Row(children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _kGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                          Icons.notifications_rounded,
                          color: _kGreen,
                          size: 17),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOTIFICATIONS',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: _kDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          unread > 0
                              ? '$unread unread'
                              : 'All caught up ✓',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 10,
                            color:
                                unread > 0 ? _kBrown : _kGreen,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _kGreen.withOpacity(0.2)),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: _kBrown, size: 14),
                      ),
                    ),
                  ]),
                ),

                // ── Notification rows ─────────────────────────────────────
                ...notifs.map((n) => _NotifRow(
                      notif: n,
                      onTap: () => widget.state.markRead(n.id),
                    )),

                // ── Footer — mark all read ────────────────────────────────
                GestureDetector(
                  onTap: unread > 0
                      ? () => widget.state.markAllRead()
                      : widget.onClose,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: unread > 0
                          ? _kGreen.withOpacity(0.07)
                          : _kBg,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(20)),
                      border: Border(
                          top: BorderSide(
                              color: _kGreen.withOpacity(0.1))),
                    ),
                    child: Center(
                      child: Text(
                        unread > 0 ? 'MARK ALL AS READ' : 'CLOSE',
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 1,
                          color: _kGreen,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final AdminNotif notif;
  final VoidCallback onTap;

  const _NotifRow({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: notif.isUnread
              ? _kGreen.withOpacity(0.04)
              : Colors.transparent,
          border: Border(
              bottom:
                  BorderSide(color: _kGreen.withOpacity(0.07))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: notif.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(notif.icon, color: notif.color, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: notif.isUnread
                              ? FontWeight.w800
                              : FontWeight.w600,
                          fontSize: 12,
                          color: _kDark,
                        ),
                      ),
                    ),
                    if (notif.isUnread)
                      Container(
                        width: 7,
                        height: 7,
                        margin:
                            const EdgeInsets.only(left: 6, top: 2),
                        decoration: const BoxDecoration(
                          color: _kGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ]),
                  const SizedBox(height: 2),
                  Text(
                    notif.body,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 10,
                      height: 1.4,
                      color: _kDark.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text(
                      notif.time,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: _kBrown.withOpacity(0.7),
                      ),
                    ),
                    if (notif.isUnread) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Tap to mark read',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 9,
                          color: _kGreen.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS PANEL
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsPanel extends StatefulWidget {
  final VoidCallback onClose;
  const _SettingsPanel({required this.onClose});

  @override
  State<_SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<_SettingsPanel> {
  // Local settings state (wire to your real preferences service)
  bool _emailNotifs    = true;
  bool _orderAlerts    = true;
  bool _reviewAlerts   = false;
  bool _stockAlerts    = true;
  String _language     = 'English';
  String _timezone     = 'UTC+8 (Philippine Time)';

  static const _languages = ['English', 'Filipino', 'Bisaya'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 440,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ───────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                decoration: BoxDecoration(
                  color: _kBg,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24)),
                  border: Border(
                      bottom: BorderSide(
                          color: _kGreen.withOpacity(0.12))),
                ),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _kGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.settings_rounded,
                        color: _kGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SETTINGS',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: _kDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Admin preferences',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 11,
                          color: _kBrown,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _kGreen.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: _kBrown, size: 15),
                    ),
                  ),
                ]),
              ),

              // ── Scrollable settings body ──────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── ACCOUNT SECTION ────────────────────────────────
                      _SectionLabel(label: 'ACCOUNT'),
                      const SizedBox(height: 8),
                      _ActionTile(
                        icon: Icons.person_outline_rounded,
                        color: _kGreen,
                        label: 'Admin Profile',
                        sub: 'L&L Cafe Admin · admin@lnlcafe.com',
                        onTap: () => _toast(context, 'Profile editor coming soon'),
                      ),
                      _ActionTile(
                        icon: Icons.lock_outline_rounded,
                        color: _kBrown,
                        label: 'Change Password',
                        sub: 'Last changed 30 days ago',
                        onTap: () => _toast(context, 'Password change coming soon'),
                      ),

                      const SizedBox(height: 20),

                      // ── NOTIFICATIONS SECTION ──────────────────────────
                      _SectionLabel(label: 'NOTIFICATIONS'),
                      const SizedBox(height: 8),
                      _ToggleTile(
                        icon: Icons.email_outlined,
                        color: const Color(0xFF5B7FA6),
                        label: 'Email Notifications',
                        sub: 'Receive order summaries by email',
                        value: _emailNotifs,
                        onChanged: (v) =>
                            setState(() => _emailNotifs = v),
                      ),
                      _ToggleTile(
                        icon: Icons.receipt_long_outlined,
                        color: _kGreen,
                        label: 'New Order Alerts',
                        sub: 'Notify when a new order is placed',
                        value: _orderAlerts,
                        onChanged: (v) =>
                            setState(() => _orderAlerts = v),
                      ),
                      _ToggleTile(
                        icon: Icons.star_outline_rounded,
                        color: const Color(0xFFE6A817),
                        label: 'Review Alerts',
                        sub: 'Notify when a customer leaves a review',
                        value: _reviewAlerts,
                        onChanged: (v) =>
                            setState(() => _reviewAlerts = v),
                      ),
                      _ToggleTile(
                        icon: Icons.inventory_2_outlined,
                        color: _kBrown,
                        label: 'Low Stock Alerts',
                        sub: 'Notify when items are running low',
                        value: _stockAlerts,
                        onChanged: (v) =>
                            setState(() => _stockAlerts = v),
                      ),

                      const SizedBox(height: 20),

                      // ── REGIONAL SECTION ───────────────────────────────
                      _SectionLabel(label: 'REGIONAL'),
                      const SizedBox(height: 8),
                      _DropdownTile(
                        icon: Icons.language_rounded,
                        color: const Color(0xFF4CAF50),
                        label: 'Language',
                        sub: _language,
                        items: _languages,
                        value: _language,
                        onChanged: (v) =>
                            setState(() => _language = v ?? _language),
                      ),
                      _ActionTile(
                        icon: Icons.access_time_rounded,
                        color: const Color(0xFFB07A9E),
                        label: 'Timezone',
                        sub: _timezone,
                        onTap: () => _toast(context, 'Timezone setting coming soon'),
                      ),

                      const SizedBox(height: 20),

                      // ── APPEARANCE SECTION ─────────────────────────────
                      _SectionLabel(label: 'APPEARANCE'),
                      const SizedBox(height: 8),
                      _ToggleTile(
                        icon: Icons.dark_mode_outlined,
                        color: _kDark,
                        label: 'Dark Mode',
                        sub: AdminState.instance.darkMode
                            ? 'Currently enabled'
                            : 'Currently disabled',
                        value: AdminState.instance.darkMode,
                        onChanged: (v) {
                          AdminState.instance.toggleDarkMode();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── Footer ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: _kGreen,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _kGreen.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'SAVE & CLOSE',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              fontFamily: 'Urbanist', fontWeight: FontWeight.w700)),
      backgroundColor: _kGreen,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Urbanist',
        fontWeight: FontWeight.w900,
        fontSize: 10,
        letterSpacing: 2,
        color: _kBrown.withOpacity(0.7),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kGreen.withOpacity(0.1)),
        ),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: _kDark,
                    )),
                Text(sub,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 10,
                      color: _kDark.withOpacity(0.45),
                    )),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: _kGreen.withOpacity(0.4), size: 18),
        ]),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.sub,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kGreen.withOpacity(0.1)),
      ),
      child: Row(children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: _kDark,
                  )),
              Text(sub,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 10,
                    color: _kDark.withOpacity(0.45),
                  )),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: _kGreen,
          activeTrackColor: _kGreen.withOpacity(0.3),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: _kDark.withOpacity(0.15),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ]),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String sub;
  final List<String> items;
  final String value;
  final ValueChanged<String?> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.sub,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kGreen.withOpacity(0.1)),
      ),
      child: Row(children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: _kDark,
              )),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isDense: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: _kGreen),
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: _kDark,
            ),
            items: items
                .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGOUT DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  const _LogoutDialog(
      {required this.onCancel, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: Colors.redAccent, size: 22),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LOGOUT',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: _kDark,
                          letterSpacing: 0.5,
                        )),
                    Text('Session will be ended',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 11,
                          color: _kBrown,
                        )),
                  ],
                ),
              ]),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.redAccent.withOpacity(0.2)),
                ),
                child: const Text(
                  'Are you sure you want to log out of the admin panel? Any unsaved changes will be lost.',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12,
                    height: 1.6,
                    color: _kDark,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _kGreen.withOpacity(0.35)),
                      ),
                      child: const Center(
                        child: Text('CANCEL',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: _kGreen,
                            )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('LOGOUT',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: Colors.white,
                              letterSpacing: 1,
                            )),
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}