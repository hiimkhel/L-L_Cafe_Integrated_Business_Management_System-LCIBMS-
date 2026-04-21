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
      id: json['id'],
      name: json['name'],
      category: json['category'],
      imageUrl: json['image_url'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
    );
  }
}