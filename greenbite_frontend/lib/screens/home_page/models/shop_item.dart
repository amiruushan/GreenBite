import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';

class ShopItem {
  final String shopId;
  final String name;
  final String description;
  final String imageUrl;
  final String address;
  final String phoneNumber;
  final List<FoodItem> foodItems; // ✅ Make sure it's final

  ShopItem({
    required this.shopId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.phoneNumber,
    this.foodItems = const [],
  });

  // ✅ Add copyWith method
  ShopItem copyWith({
    String? shopId,
    String? name,
    String? description,
    String? imageUrl,
    String? address,
    String? phoneNumber,
    List<FoodItem>? foodItems,
  }) {
    return ShopItem(
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      foodItems: foodItems ?? this.foodItems,
    );
  }

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      shopId: json['shopId'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      foodItems: (json['foodItems'] as List<dynamic>?)
              ?.map((item) => FoodItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}
