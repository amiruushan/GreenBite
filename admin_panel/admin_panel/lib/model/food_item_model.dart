class FoodItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final int shopId;
  final String photo;
  final List<String> tags;
  final String category;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.shopId,
    required this.photo,
    required this.tags,
    required this.category,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      shopId: json['shopId'],
      photo: json['photo'],
      tags: List<String>.from(json['tags']),
      category: json['category'],
    );
  }
}