import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

const double _kMobile = 900;

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class NotificationItem {
  final String id;
  final String sender;
  final String time;
  final String body;
  final bool isPriority;

  const NotificationItem({
    required this.id,
    required this.sender,
    required this.time,
    required this.body,
    this.isPriority = false,
  });
}

final List<NotificationItem> _mockNotifications = [
  const NotificationItem(
    id: 'n1',
    sender: 'L&L ADMIN',
    time: 'JUST NOW',
    body: 'WELCOME TO L&L CAFE! WE ARE SO EXCITED TO SERVE YOU THE BEST FOOD IN TOWN.',
    isPriority: true,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION PANEL
// ─────────────────────────────────────────────────────────────────────────────

class NotificationPanel extends StatelessWidget {
  final bool isMobile;
  const NotificationPanel({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return isMobile ? _buildMobileSheet(context) : _buildDesktopPanel(context);
  }

  Widget _buildDesktopPanel(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 380,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Color(0xFFEFE2C9),
          border: Border(left: BorderSide(color: Color(0x1AA98258), width: 1.0)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            bottomLeft: Radius.circular(40),
          ),
          boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 50, offset: Offset(-10, 0))],
        ),
        child: Column(children: [_buildHeader(context), Expanded(child: _buildList())]),
      ),
    );
  }

  Widget _buildMobileSheet(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEFE2C9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFA98258).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            _buildHeader(context, isMobileHeader: true),
            Flexible(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {bool isMobileHeader = false}) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, isMobileHeader ? 12 : 32, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(bottom: BorderSide(color: Color(0x1AA98258), width: 1.0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
                color: const Color(0xFF758C6D), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('L&L CHANNEL',
                    style: TextStyle(
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                        fontSize: 20, height: 1.1, letterSpacing: -0.5,
                        color: Color(0xFF2D2A26))),
                SizedBox(height: 4),
                Text('ORDER NOTIFICATION',
                    style: TextStyle(
                        fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                        fontSize: 10, letterSpacing: 1.0, color: Color(0xFFA98258))),
              ],
            ),
          ),
          if (!isMobileHeader)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Center(
                    child: Icon(Icons.close_rounded, color: Color(0xFFA98258), size: 20)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 24, bottom: 40),
      itemCount: _mockNotifications.length,
      itemBuilder: (context, index) {
        final item = _mockNotifications[index];
        return Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(item.isPriority ? 1.0 : 0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: item.isPriority ? const Color(0x4D758C6D) : const Color(0x0DA98258),
              width: 1.0,
            ),
            boxShadow: item.isPriority
                ? const [BoxShadow(color: Color(0x26000000), blurRadius: 20, offset: Offset(0, 10))]
                : const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: item.isPriority
                            ? const Color(0xFF758C6D)
                            : const Color(0x33A98258),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(item.sender,
                        style: const TextStyle(
                            fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                            fontSize: 10, letterSpacing: 1.5, color: Color(0xFF2D2A26))),
                  ]),
                  Row(children: [
                    const Icon(Icons.access_time_rounded, size: 12, color: Color(0x66A98258)),
                    const SizedBox(width: 6),
                    Text(item.time,
                        style: const TextStyle(
                            fontFamily: 'Urbanist', fontWeight: FontWeight.w800,
                            fontSize: 10, color: Color(0x66A98258))),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              Text(item.body,
                  style: const TextStyle(
                      fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                      fontSize: 13, height: 1.5, letterSpacing: 0.5,
                      color: Color(0xFFA98258))),
              if (item.isPriority) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0x1A758C6D), width: 1.0))),
                  child: const Row(children: [
                    Icon(Icons.celebration_rounded, size: 14, color: Color(0xFF758C6D)),
                    SizedBox(width: 8),
                    Text('WELCOME MESSAGE',
                        style: TextStyle(
                            fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                            fontSize: 9, letterSpacing: 0.9, color: Color(0xFF758C6D))),
                  ]),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GUEST NAVBAR
// ─────────────────────────────────────────────────────────────────────────────

class GuestNavbar extends StatefulWidget implements PreferredSizeWidget {
  final String activeRoute;
  final VoidCallback? onLogin;
  final VoidCallback? onJoinNow;
  final VoidCallback? onBrowseMenu;

  const GuestNavbar({
    super.key,
    this.activeRoute = '/home',
    this.onLogin,
    this.onJoinNow,
    this.onBrowseMenu,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  State<GuestNavbar> createState() => _GuestNavbarState();
}

class _GuestNavbarState extends State<GuestNavbar> {
  OverlayEntry? _overlayEntry;

  static const _links = [
    _NI('HOME',    '/'),
    _NI('MENU',    '/menu'),
    _NI('ABOUT',   '/about'),
    _NI('CONTACT', '/contact'),
  ];

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }

  void _handleLinkTap(BuildContext context, String route) {
    _closeMenu();
    if (route == '/menu') {
      widget.onBrowseMenu?.call();
    } else {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _openMenu(BuildContext context) {
    _closeMenu();
    _overlayEntry = OverlayEntry(
      builder: (_) => _GuestMobileMenu(
        activeRoute: widget.activeRoute,
        links: _links,
        onClose: _closeMenu,
        // ✅ Pass login/joinNow so overlay buttons are wired
        onLogin: widget.onLogin,
        onJoinNow: widget.onJoinNow,
        onNavigate: (route) => _handleLinkTap(context, route),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {});
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() {});
  }

  bool get _menuOpen => _overlayEntry != null;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isMobile = c.maxWidth < _kMobile;
      return isMobile ? _buildMobile(context) : _buildDesktop(context);
    });
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xF2EFE2C9),
        border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(children: [
        _LogoImg(),
        const SizedBox(width: 48),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _links.map((l) => Padding(
                padding: const EdgeInsets.only(right: 32),
                child: _NavLink(
                  label: l.label,
                  active: widget.activeRoute == l.route,
                  onTap: () => _handleLinkTap(context, l.route),
                ),
              )).toList(),
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onLogin,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('LOGIN',
                style: TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 12, letterSpacing: 2.0, color: AppColors.primary)),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onJoinNow,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Color(0xFF2D2A26), offset: Offset(3, 3))],
            ),
            child: const Text('JOIN NOW',
                style: TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 12, letterSpacing: 1.2, color: Colors.white)),
          ),
        ),
      ]),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xF2EFE2C9),
        border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        _LogoImg(),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onLogin,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('LOGIN',
                style: TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 11, letterSpacing: 2, color: AppColors.primary)),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onJoinNow,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
                color: AppColors.secondary, borderRadius: BorderRadius.circular(10)),
            child: const Text('JOIN NOW',
                style: TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 10, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _menuOpen ? _closeMenu() : _openMenu(context),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4)],
            ),
            child: Icon(
              _menuOpen ? Icons.close_rounded : Icons.menu_rounded,
              color: AppColors.primary, size: 20,
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER NAVBAR  (logged-in users)
// ─────────────────────────────────────────────────────────────────────────────

class CustomerNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String activeRoute;
  final int cartCount;
  final int notifCount;
  final String? userName;
  final String? userClientId;
  final bool isGuest;
  final VoidCallback? onCart;
  final VoidCallback? onNotif;
  final VoidCallback? onProfile;
  final VoidCallback? onLogout;
  final VoidCallback? onLoginRequired;

  const CustomerNavbar({
    super.key,
    this.activeRoute = '/home',
    this.cartCount = 0,
    this.notifCount = 0,
    this.userName,
    this.userClientId,
    this.isGuest = false,
    this.onCart,
    this.onNotif,
    this.onProfile,
    this.onLogout,
    this.onLoginRequired,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  void _showNotifications(BuildContext context, bool isMobile) {
    if (isMobile) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => const NotificationPanel(isMobile: true),
      );
    } else {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        barrierColor: Colors.black.withOpacity(0.3),
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => const Align(
          alignment: Alignment.centerRight,
          child: NotificationPanel(isMobile: false),
        ),
        transitionBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final bool isMobile = c.maxWidth < _kMobile;
      return isMobile
          ? _MobileCustomerNav(
              activeRoute:    activeRoute,
              cartCount:      cartCount,
              notifCount:     notifCount,
              userName:       userName,
              userClientId:   userClientId,
              isGuest:        isGuest,
              onCart:         onCart,
              onNotif:        () => _showNotifications(context, true),
              onLogout:       onLogout,
              onLoginRequired: onLoginRequired,
            )
          : _DesktopCustomerNav(
              activeRoute:    activeRoute,
              cartCount:      cartCount,
              notifCount:     notifCount,
              isGuest:        isGuest,
              onCart:         onCart,
              onNotif:        () => _showNotifications(context, false),
              onProfile:      onProfile,
              onLogout:       onLogout,
              onLoginRequired: onLoginRequired,
            );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESKTOP CUSTOMER NAV
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopCustomerNav extends StatelessWidget {
  final String activeRoute;
  final int cartCount, notifCount;
  final bool isGuest;
  final VoidCallback? onCart, onNotif, onProfile, onLogout, onLoginRequired;

  static const _links = [
    _NI('HOME',   '/home'),
    _NI('MENU',   '/menu'),
    _NI('ORDERS', '/orders'),
    _NI('ABOUT',  '/about'),
  ];

  const _DesktopCustomerNav({
    required this.activeRoute,
    required this.cartCount,
    required this.notifCount,
    required this.isGuest,
    this.onCart,
    this.onNotif,
    this.onProfile,
    this.onLogout,
    this.onLoginRequired,
  });

  void _handleNavTap(BuildContext context, String route) {
    if (activeRoute == route) return;
    if (route == '/about' || route == '/contact') {
      Navigator.pushNamed(context, route);
    } else {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _handleCartTap(BuildContext context) {
    if (isGuest) { onLoginRequired?.call(); return; }
    onCart?.call();
    if (activeRoute != '/cart') Navigator.pushReplacementNamed(context, '/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xF2EFE2C9),
        border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(children: [
        GestureDetector(
          onTap: () => _handleNavTap(context, '/home'),
          child: _LogoImg(),
        ),
        const SizedBox(width: 48),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _links.map((l) => Padding(
                padding: const EdgeInsets.only(right: 32),
                child: _NavLink(
                  label: l.label,
                  active: activeRoute == l.route,
                  onTap: () => _handleNavTap(context, l.route),
                ),
              )).toList(),
            ),
          ),
        ),

        // ── Icons ──────────────────────────────────────────────────────
        if (!isGuest) ...[
          _IconCircleBtn(
              icon: Icons.notifications_none_rounded,
              badge: notifCount,
              onTap: onNotif),
          const SizedBox(width: 16),
          _IconCircleBtn(
              icon: Icons.shopping_cart_outlined,
              badge: cartCount,
              onTap: () => _handleCartTap(context)),
          const SizedBox(width: 16),
          _IconCircleBtn(
              icon: Icons.person_outline_rounded,
              onTap: () {
                onProfile?.call();
                if (activeRoute != '/profile') {
                  Navigator.pushReplacementNamed(context, '/profile');
                }
              }),
          const SizedBox(width: 16),
          _IconCircleBtn(
              icon: Icons.logout_rounded,
              onTap: () {
                onLogout?.call();
                Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
              }),
        ],

        // Guest mode — show cart (disabled) + login/join
        if (isGuest) ...[
          _IconCircleBtn(
              icon: Icons.shopping_cart_outlined,
              badge: 0,
              onTap: () => onLoginRequired?.call()),
          const SizedBox(width: 16),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onLoginRequired,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text('LOGIN',
                  style: TextStyle(
                      fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                      fontSize: 12, letterSpacing: 2.0, color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onLoginRequired,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Color(0xFF2D2A26), offset: Offset(3, 3))],
              ),
              child: const Text('JOIN NOW',
                  style: TextStyle(
                      fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                      fontSize: 12, letterSpacing: 1.2, color: Colors.white)),
            ),
          ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE CUSTOMER NAV
// ─────────────────────────────────────────────────────────────────────────────

class _MobileCustomerNav extends StatelessWidget {
  final String activeRoute;
  final int cartCount, notifCount;
  final String? userName, userClientId;
  final bool isGuest;                          // ✅ field present
  final VoidCallback? onCart, onNotif, onLogout, onLoginRequired;

  const _MobileCustomerNav({
    required this.activeRoute,
    required this.cartCount,
    required this.notifCount,
    required this.isGuest,                     // ✅ required
    this.userName,
    this.userClientId,
    this.onCart,
    this.onNotif,
    this.onLogout,
    this.onLoginRequired,
  });

  void _handleCartTap(BuildContext context) {
    if (isGuest) { onLoginRequired?.call(); return; }
    onCart?.call();
    if (activeRoute != '/cart') Navigator.pushReplacementNamed(context, '/cart');
  }

  void _openSideDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.centerRight,
        child: _SideDrawer(
          activeRoute:  activeRoute,
          userName:     isGuest ? 'GUEST' : (userName ?? 'USER'),
          userClientId: isGuest ? 'GUEST USER' : (userClientId ?? ''),
          isGuest:      isGuest,
          onLogout: isGuest ? null : () {
            onLogout?.call();
            Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
          },
          onLoginRequired: onLoginRequired,
          onNav: (route) {
            Navigator.pop(context);
            if (activeRoute == route) return;
            if (route == '/about' || route == '/contact') {
              Navigator.pushNamed(context, route);
            } else {
              Navigator.pushReplacementNamed(context, route);
            }
          },
        ),
      ),
      transitionBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xF2EFE2C9),
        border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (activeRoute != '/home') {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
          child: _LogoImg(),
        ),
        const Spacer(),

        // Notifications — hidden for guests
        if (!isGuest) ...[
          _IconCircleBtn(
              icon: Icons.notifications_none_rounded,
              badge: notifCount,
              onTap: onNotif),
          const SizedBox(width: 8),
        ],

        // Cart — always visible; guests get login redirect
        _IconCircleBtn(
            icon: Icons.shopping_cart_outlined,
            badge: isGuest ? 0 : cartCount,
            onTap: () => _handleCartTap(context)),
        const SizedBox(width: 10),

        // Hamburger → side drawer
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openSideDrawer(context),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2A26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_rounded, color: Colors.white, size: 18),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SIDE DRAWER  (logged-in mobile)
// ─────────────────────────────────────────────────────────────────────────────

class _SideDrawer extends StatelessWidget {
  final String activeRoute, userName, userClientId;
  final bool isGuest;
  final VoidCallback? onLogout, onLoginRequired;
  final void Function(String) onNav;

  static const _loggedInLinks = [
    _NID('HOME',    '/home',    Icons.grid_view_rounded),
    _NID('MENU',    '/menu',    Icons.receipt_long_rounded),
    _NID('ORDERS',  '/orders',  Icons.shopping_bag_outlined),
    _NID('ABOUT',   '/about',   Icons.info_outline_rounded),
    _NID('CONTACT', '/contact', Icons.mail_outline_rounded),
    _NID('PROFILE', '/profile', Icons.person_outline_rounded),
  ];

  static const _guestLinks = [
    _NID('HOME',    '/home',    Icons.grid_view_rounded),
    _NID('MENU',    '/menu',    Icons.receipt_long_rounded),
  ];

  const _SideDrawer({
    required this.activeRoute,
    required this.userName,
    required this.userClientId,
    required this.isGuest,
    this.onLogout,
    this.onLoginRequired,
    required this.onNav,
  });

  @override
  Widget build(BuildContext context) {
    final links = isGuest ? _guestLinks : _loggedInLinks;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 300,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(color: Color(0xFF2D2A26)),
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.1)))),
              child: Row(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: isGuest
                        ? const Color(0xFFA98258).withOpacity(0.6)
                        : const Color(0xFF758C6D),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
                    color: Colors.white, size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                        style: const TextStyle(
                            fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                            fontSize: 15, color: Colors.white)),
                    if (userClientId.isNotEmpty)
                      Text(userClientId,
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 11,
                              color: AppColors.primary)),
                  ],
                ),
              ]),
            ),

            // Nav links
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: links.map((l) {
                    final isActive = activeRoute == l.route;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onNav(l.route),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(children: [
                            Icon(l.icon,
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.primary.withOpacity(0.6),
                                size: 22),
                            const SizedBox(width: 16),
                            Text(l.label,
                                style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.primary.withOpacity(0.6))),
                            if (isActive) ...[
                              const Spacer(),
                              Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle),
                              ),
                            ],
                          ]),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Bottom action
            Padding(
              padding: const EdgeInsets.all(24),
              child: isGuest
                  ? Column(children: [
                      _DrawerBtn(
                        label: 'LOGIN',
                        icon: Icons.login_rounded,
                        bgColor: AppColors.primary,
                        textColor: Colors.white,
                        onTap: () {
                          Navigator.pop(context);
                          onLoginRequired?.call();
                        },
                      ),
                      const SizedBox(height: 10),
                      _DrawerBtn(
                        label: 'JOIN NOW',
                        icon: Icons.person_add_outlined,
                        bgColor: const Color(0xFFEFE2C9),
                        textColor: AppColors.secondary,
                        iconColor: AppColors.secondary,
                        onTap: () {
                          Navigator.pop(context);
                          onLoginRequired?.call();
                        },
                      ),
                    ])
                  : _DrawerBtn(
                      label: 'LOGOUT',
                      icon: Icons.logout_rounded,
                      bgColor: const Color(0xFFEFE2C9),
                      textColor: AppColors.primary,
                      iconColor: AppColors.primary,
                      onTap: () {
                        Navigator.pop(context);
                        onLogout?.call();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DRAWER BUTTON HELPER
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor, textColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _DrawerBtn({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.textColor,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor ?? textColor, size: 18),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 13, color: textColor)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GUEST MOBILE MENU OVERLAY
// ─────────────────────────────────────────────────────────────────────────────

class _GuestMobileMenu extends StatelessWidget {
  final String activeRoute;
  final List<_NI> links;
  final VoidCallback onClose;
  final void Function(String) onNavigate;
  // ✅ Both callbacks present — wired in GuestNavbar._openMenu
  final VoidCallback? onLogin;
  final VoidCallback? onJoinNow;

  const _GuestMobileMenu({
    required this.activeRoute,
    required this.links,
    required this.onClose,
    required this.onNavigate,
    this.onLogin,
    this.onJoinNow,
  });

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        height: screenH,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fake navbar bar
            Container(
              height: 72,
              color: const Color(0xF2EFE2C9),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/images/lnl.jpg',
                      width: 44, height: 44, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Center(
                                child: Text('L&L',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 10))),
                          )),
                ),
                const Spacer(),
                // ✅ LOGIN wired
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    onClose();
                    onLogin?.call();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('LOGIN',
                        style: TextStyle(
                            fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                            fontSize: 11, letterSpacing: 2,
                            color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 6),
                // ✅ JOIN NOW wired
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    onClose();
                    onJoinNow?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('JOIN NOW',
                        style: TextStyle(
                            fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                            fontSize: 10, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Color(0x1A000000), blurRadius: 4)
                      ],
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Color(0xFF2D2A26), size: 20),
                  ),
                ),
              ]),
            ),

            // Nav links
            Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: links.map((e) {
                  final isActive = activeRoute == e.route ||
                      (e.route == '/' && activeRoute == '/home') ||
                      (e.route == '/' && activeRoute == '/');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => onNavigate(e.route),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 22),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.secondary
                              : const Color(0xFFE8D9BF),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(e.label,
                            style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                letterSpacing: 1.5,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.secondary)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            Expanded(
              child: GestureDetector(
                onTap: onClose,
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _NI {
  final String label, route;
  const _NI(this.label, this.route);
}

class _NID {
  final String label, route;
  final IconData icon;
  const _NID(this.label, this.route, this.icon);
}

class _LogoImg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset('assets/images/lnl.jpg',
          width: 44, height: 44, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12)),
                child: const Center(
                    child: Text('L&L',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 10))),
              )),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavLink({required this.label, required this.active, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: active ? AppColors.secondary : AppColors.primary)),
            if (active) ...[
              const SizedBox(height: 3),
              Container(
                height: 3, width: 24,
                decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(100)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconCircleBtn extends StatelessWidget {
  final IconData icon;
  final int badge;
  final VoidCallback? onTap;

  const _IconCircleBtn({required this.icon, this.badge = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 38, height: 38,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: Icon(icon, color: const Color(0xFF2D2A26), size: 17),
        ),
        if (badge > 0)
          Positioned(
            top: -3, right: -3,
            child: Container(
              width: 15, height: 15,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  badge > 99 ? '99+' : '$badge',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}