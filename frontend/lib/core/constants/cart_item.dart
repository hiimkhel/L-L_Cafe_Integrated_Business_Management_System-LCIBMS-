import 'package:frontend/core/models/flavor_models.dart';
import 'package:frontend/core/models/menu_item_variant.dart';

class CartItem {
  final String cartId;

  /// Menu Item
  final String id;
  final String name;

  /// Menu Category (Foods, Coffee, etc.)
  final String category;

  /// Variant (Chicken Wings only for now)
  final MenuItemVariant? variant;

  /// Selected flavors
  final List<Flavor> flavors;

  final double price;
  final double originalPrice;
  final String imageUrl;

  int quantity;

  CartItem({
    required this.cartId,
    required this.id,
    required this.name,
    required this.category,
    this.variant,
    this.flavors = const [],
    required this.price,
    required this.originalPrice,
    this.imageUrl = '',
    this.quantity = 1,
  });

  bool isSameConfiguration(CartItem other) {
    if (id != other.id) return false;

    if (variant?.id != other.variant?.id) return false;

    if (flavors.length != other.flavors.length) return false;

    final a = flavors.map((e) => e.id).toList()..sort();
    final b = other.flavors.map((e) => e.id).toList()..sort();

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }
}