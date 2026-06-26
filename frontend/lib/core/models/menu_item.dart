class MenuItem {
  
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final bool isAvailable;
  final bool hasVariants;
  final double? startingPrice;

  MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.isAvailable,
    required this.hasVariants,
    this.startingPrice
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'] ?? '',
      imageUrl: resolveImageUrl(json['image_url'] ?? 'temp.png'),
      price: double.parse(json['price'].toString()),
      isAvailable: json['is_available'] == 1,
      hasVariants: json['has_variants'] == 1,
      startingPrice: json['starting_price'] != null
        ? double.parse(json['starting_price'].toString())
        : null,
    );
  }
}

  String resolveImageUrl(String imageUrl) {
    // CHANGE THIS if testing on Android emulator or physical device.
    const String baseUrl = 'http://localhost:3006';
    const String uploadPath = '/uploads/menu-items/';

    // If already a full URL, return as-is.
    if (imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // Remove leading slash if present.
    final clean = imageUrl.startsWith('/')
        ? imageUrl.substring(1)
        : imageUrl;

    return '$baseUrl$uploadPath$clean';
  }