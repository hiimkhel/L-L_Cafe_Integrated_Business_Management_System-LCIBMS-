class MenuItem {
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.isAvailable,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: double.parse(json['price'].toString()),
      isAvailable: json['is_available'] == 1,
    );
  }
}