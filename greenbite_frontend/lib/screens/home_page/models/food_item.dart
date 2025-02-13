class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  String quantity;
  final String photo;
  final List<String> tags;
  final String restaurant;
  final int shopId; // Assuming you want to keep this field
  final String category; // New category field

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.photo,
    required this.tags,
    required this.restaurant,
    required this.shopId,
    required this.category, // Added category as a required field
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
          ? List<String>.from(json['tags'])
          : json['tags'].toString().split(','), // ✅ Convert string to list
      restaurant: json['restaurant'] ?? 'Unknown',
      category: json['category'] ?? 'Uncategorized',
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
      'category': category, // Added category to JSON serialization
    };
  }
}
