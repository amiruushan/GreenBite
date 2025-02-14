class ShopItem {
  final int shopId;
  final String name;
  final String description;
  final String imageUrl;

  ShopItem({
    required this.shopId,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  // Factory constructor to convert JSON to ShopItem
  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      shopId: json['shopId'],
      name: json['name'],
      description: json['description'] ?? 'No Description',
      imageUrl: json['imageUrl'],
    );
  }
}
