import 'package:flutter/material.dart';
 import 'package:frontend/core/constants/cart_item.dart';
 
// ─────────────────────────────────────────────────────────────────────────────
// CART NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────
 
class CartNotifier extends ChangeNotifier {
  final List<CartItem> _items = [];
 
  List<CartItem> get items => List.unmodifiable(_items);
  int get totalCount => _items.fold(0, (s, c) => s + c.quantity);
  double get subtotal => _items.fold(0.0, (s, c) => s + c.price * c.quantity);
  bool get isEmpty => _items.isEmpty;
 
  void add(CartItem incoming) {
    final idx = _items.indexWhere(
      (c) => c.isSameConfiguration(incoming),
    );

    if (idx == -1) {
      _items.add(incoming);
    } else {
      _items[idx].quantity++;
    }

    notifyListeners();
  }
 
  void increment(String cartId) {
    final idx = _items.indexWhere((c) => c.cartId == cartId);

    if (idx != -1) {
      _items[idx].quantity++;
      notifyListeners();
    }
  }

  void decrement(String cartId) {
    final idx = _items.indexWhere((c) => c.cartId == cartId);

    if (idx == -1) return;

    if (_items[idx].quantity <= 1) {
      _items.removeAt(idx);
    } else {
      _items[idx].quantity--;
    }

    notifyListeners();
  }

  void remove(String cartId) {
    _items.removeWhere((c) => c.cartId == cartId);
    notifyListeners();
  }
 
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// INHERITED WIDGET WRAPPER
// ─────────────────────────────────────────────────────────────────────────────
 
class CartProvider extends InheritedNotifier<CartNotifier> {
  const CartProvider({
    super.key,
    required CartNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);
 
  static CartNotifier of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<CartProvider>();
    assert(provider != null, 'No CartProvider found in widget tree');
    return provider!.notifier!;
  }
}