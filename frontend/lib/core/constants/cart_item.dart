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
    this.imageUrl = '', // <-- Added this!
    this.quantity = 1,
  });
}
class Order {
  final String id;
  final List<CartItem> items;
  OrderStatus status;

  Order({required this.id, required this.items, this.status = OrderStatus.pending});
}

enum OrderStatus { pending, inProgress, archived }