class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  String quantity;
  final String photo;
  final List<String> tags; // Tags can be empty
  final String restaurant;
  final int shopId; // Assuming you want to keep this field
  final String category; // New category field
  final double latitude; // Add latitude field
  final double longitude; // Add longitude field

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.photo,
    this.tags = const [], // Default to empty list
    required this.restaurant,
    required this.shopId,
    required this.category,
    required this.latitude, // Add latitude
    required this.longitude, // Add longitude
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'].toString(),
      photo: json['photo'],
      shopId: json['shopId'],
      tags: json['tags'] is List
          ? List<String>.from(json['tags'].where((tag) =>
              tag != null && tag.isNotEmpty)) // Filter out empty or null tags
          : [], // Default to empty list if tags is null or not a list
      restaurant: json['restaurant'] ?? 'Unknown',
      category: json['category'] ?? 'Uncategorized',
      latitude: json['latitude'] ?? 0.0, // Add latitude
      longitude: json['longitude'] ?? 0.0, // Add longitude
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'photo': photo,
      'tags': tags,
      'restaurant': restaurant,
      'shopId': shopId,
      'category': category,
      'latitude': latitude, // Add latitude
      'longitude': longitude, // Add longitude
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
