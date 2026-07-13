class MenuItemModel {
  final String name;
  final String price;
  final String desc;
  bool isAvailable;
  final bool hasFlavors;

  MenuItemModel({
    required this.name,
    required this.price,
    required this.desc,
    this.isAvailable = true,
    required this.hasFlavors
  });
}