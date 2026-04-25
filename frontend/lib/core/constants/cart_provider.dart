import 'package:flutter/material.dart';
 
// ─────────────────────────────────────────────────────────────────────────────
// CART ITEM MODEL
// ─────────────────────────────────────────────────────────────────────────────
 
class CartItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final double originalPrice;
  final String imageUrl;
  int quantity;
 
  CartItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.originalPrice,
    this.imageUrl = '',
    this.quantity = 1,
  });
}
 
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
    final idx = _items.indexWhere((c) => c.id == incoming.id);
    if (idx == -1) {
      _items.add(CartItem(
        id: incoming.id,
        name: incoming.name,
        category: incoming.category,
        price: incoming.price,
        originalPrice: incoming.originalPrice,
        imageUrl: incoming.imageUrl,
        quantity: 1,
      ));
    } else {
      _items[idx].quantity++;
    }
    notifyListeners();
  }
 
  void increment(String id) {
    final idx = _items.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _items[idx].quantity++;
      notifyListeners();
    }
  }
 
  void decrement(String id) {
    final idx = _items.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    if (_items[idx].quantity <= 1) {
      _items.removeAt(idx);
    } else {
      _items[idx].quantity--;
    }
    notifyListeners();
  }
 
  void remove(String id) {
    _items.removeWhere((c) => c.id == id);
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