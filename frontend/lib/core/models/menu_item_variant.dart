class MenuItemVariant {
  final int id;
  final int menuItemId;
  final String category;
  final String variantName;
  final int pieces;
  final int requiredFlavors;
  final double price;
  final bool isAvailable;

  MenuItemVariant({
    required this.id,
    required this.menuItemId,
    required this.category,
    required this.variantName,
    required this.pieces,
    required this.requiredFlavors,
    required this.price,
    required this.isAvailable,
  });

  factory MenuItemVariant.fromJson(Map<String, dynamic> json) {
    return MenuItemVariant(
      id: json['id'],
      menuItemId: json['menu_item_id'],
      category: json['category'],
      variantName: json['variant_name'],
      pieces: json['pieces'],
      requiredFlavors: json['required_flavors'],
      price: double.parse(json['price'].toString()),
      isAvailable: json['is_available'] == 1,
    );
  }
}