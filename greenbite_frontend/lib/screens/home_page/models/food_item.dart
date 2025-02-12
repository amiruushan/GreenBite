class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  String quantity;
  final String photo;
  final List<String> tags;
  final String restaurant; // Assuming you want to keep this field
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
      tags: List<String>.from(json['tags']),
      restaurant:
          json['restaurant'] ?? 'Unknown', // Default value if not provided
      category:
          json['category'] ?? 'Uncategorized', // Default value for category
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
      'category': category, // Added category to JSON serialization
    };
  }
}
