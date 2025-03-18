import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';

class ShopItem {
  final String shopId;
  final String name;
  final String description;
  final String imageUrl; // Ensure this field is present
  final String address;
  final String phoneNumber;
  final List<FoodItem> foodItems;
  final double latitude; // Add latitude field
  final double longitude; // Add longitude field

  ShopItem({
    required this.shopId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.phoneNumber,
    this.foodItems = const [],
    required this.latitude, // Add latitude
    required this.longitude, // Add longitude
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
    double? latitude, // Add latitude
    double? longitude, // Add longitude
  }) {
    return ShopItem(
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      foodItems: foodItems ?? this.foodItems,
      latitude: latitude ?? this.latitude, // Add latitude
      longitude: longitude ?? this.longitude, // Add longitude
    );
  }

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      shopId: (json['shopId'] ?? json['id']).toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['photo'] ?? '', // Ensure this field is present
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      foodItems: (json['foodItems'] as List<dynamic>?)
              ?.map((item) => FoodItem.fromJson(item))
              .toList() ??
          [],
      latitude: json['latitude'] ?? 0.0, // Add latitude
      longitude: json['longitude'] ?? 0.0, // Add longitude
    );
  }
}
