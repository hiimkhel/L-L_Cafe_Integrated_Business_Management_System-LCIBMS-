class MenuItemModel {
  final String name;
  final String price;
  final String desc;
  bool isAvailable;

  MenuItemModel({
    required this.name,
    required this.price,
    required this.desc,
    this.isAvailable = true,
  });
}