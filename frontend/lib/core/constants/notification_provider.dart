import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION MODEL
// ─────────────────────────────────────────────────────────────────────────────

class AppNotification {
  final String id;
  final String sender;
  final String time;
  final String body;
  final bool isPriority;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.sender,
    required this.time,
    required this.body,
    this.isPriority = false,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        sender: sender,
        time: time,
        body: body,
        isPriority: isPriority,
        isRead: isRead ?? this.isRead,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTROLLER  (ChangeNotifier — rebuilds every listener on mutation)
// ─────────────────────────────────────────────────────────────────────────────

class NotificationController extends ChangeNotifier {
  final List<AppNotification> _notifications = [
    const AppNotification(
      id: 'n1',
      sender: 'L&L ADMIN',
      time: 'JUST NOW',
      body:
          'WELCOME TO L&L CAFE! WE ARE SO EXCITED TO SERVE YOU THE BEST FOOD IN TOWN.',
      isPriority: true,
      isRead: false,
    ),
  ];

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Mark a single notification as read by id.
  void markRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    if (_notifications[idx].isRead) return; // already read — no rebuild needed
    _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    notifyListeners();
  }

  /// Mark every notification as read at once.
  void markAllRead() {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// Add a new notification (e.g. from a push/websocket event).
  void add(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INHERITED WIDGET  — provides the controller to the whole widget tree
// Wrap your MaterialApp (or the authenticated subtree) with this.
//
//   NotificationProvider(
//     controller: NotificationController(),
//     child: MaterialApp(...),
//   )
//
// Read anywhere with:
//   NotificationProvider.of(context).unreadCount
//   NotificationProvider.of(context).markAllRead()
// ─────────────────────────────────────────────────────────────────────────────

class NotificationProvider extends InheritedNotifier<NotificationController> {
  const NotificationProvider({
    super.key,
    required NotificationController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Returns the nearest [NotificationController] up the tree.
  /// Subscribes the calling widget so it rebuilds on any change.
  static NotificationController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<NotificationProvider>();
    assert(provider != null,
        'NotificationProvider.of() called with no NotificationProvider in tree.\n'
        'Wrap your app or authenticated subtree with NotificationProvider.');
    return provider!.notifier!;
  }
}