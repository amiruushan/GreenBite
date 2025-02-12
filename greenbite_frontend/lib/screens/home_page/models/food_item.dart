class FoodItem {
  final String name;
  final String restaurant;
  final String imageUrl;
  final double price;
  final String description;
  final String category;
  String quantity;

  FoodItem(
      {required this.name,
      required this.restaurant,
      required this.imageUrl,
      required this.price,
      required this.description,
      required this.category,
      required this.quantity});

  // Convert JSON to FoodItem
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
        name: json['name'],
        restaurant: json['restaurant'],
        imageUrl: json['imageUrl'],
        price: (json['price'] as num).toDouble(), // Ensure price is double
        description: json['description'],
        category: json['category'],
        quantity: json['quantity'].toString());
  }

  // Convert FoodItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'restaurant': restaurant,
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'category': category,
      'quantity': quantity
    };
  }
}
