class Flavor {
  final int id;
  final String flavorName;
  final bool isAvailable;

  Flavor({
    required this.id,
    required this.flavorName,
    required this.isAvailable,
  });

  factory Flavor.fromJson(Map<String, dynamic> json) {
    return Flavor(
      id: json['id'],
      flavorName: json['flavor_name'],
      isAvailable: json['is_available'] == 1,
    );
  }
}