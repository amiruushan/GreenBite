class Coupon {
  final int id;
  final String title;
  final String icon;
  final String color;
  final int cost;
  final double discount;

  Coupon({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.cost,
    required this.discount,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      title: json['title'],
      icon: json['icon'],
      color: json['color'],
      cost: json['cost'],
      discount: json['discount'],
    );
  }
}