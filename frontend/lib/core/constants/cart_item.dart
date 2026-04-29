class CartItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final double originalPrice;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.originalPrice,
    this.quantity = 1,
  });
}
