class MenuItem {
  final int id;
  final String name;
  final String category;
  final String imageUrl;
  final String description;
  final double price;

  MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.price,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? 'Uncategorized',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] == null)
          ? 0.0
          : double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }
}