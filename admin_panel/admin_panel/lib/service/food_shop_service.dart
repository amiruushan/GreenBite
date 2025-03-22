import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodShopService {
  final String baseUrl = "http://192.168.1.7:8080/api/admin";

  Future<List<FoodShopDTO>> getAllFoodShops() async {
    final response = await http.get(Uri.parse('$baseUrl/listFoodShops'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => FoodShopDTO.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load food shops');
    }
  }

  Future<void> addFoodShop(FoodShop foodShop) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addFoodShop'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(foodShop.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add food shop');
    }
  }

  Future<void> deleteFoodShop(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/deleteFoodShop/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete food shop');
    }
  }
}

class FoodShopDTO {
  final int shopId;
  final String name;
  final String photo;
  final String address;
  final String phoneNumber;
  final String? email; // Make email nullable
  final String? businessDescription; // Make business description nullable
  final DateTime? licenseExpirationDate; // Make license expiration date nullable
  final double latitude;
  final double longitude;

  FoodShopDTO({
    required this.shopId,
    required this.name,
    required this.photo,
    required this.address,
    required this.phoneNumber,
    this.email, // Make email nullable
    this.businessDescription, // Make business description nullable
    this.licenseExpirationDate, // Make license expiration date nullable
    required this.latitude,
    required this.longitude,
  });

  factory FoodShopDTO.fromJson(Map<String, dynamic> json) {
    return FoodShopDTO(
      shopId: json['shopId'],
      name: json['name'],
      photo: json['photo'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      email: json['email'], // Handle null email
      businessDescription: json['businessDescription'], // Handle null business description
      licenseExpirationDate: json['licenseExpirationDate'] != null
          ? DateTime.parse(json['licenseExpirationDate'])
          : null, // Handle null license expiration date
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class FoodShop {
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final String businessDescription;
  final String photo;
  final double latitude;
  final double longitude;
  final DateTime licenseExpirationDate;

  FoodShop({
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.businessDescription,
    required this.photo,
    required this.latitude,
    required this.longitude,
    required this.licenseExpirationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'businessDescription': businessDescription,
      'photo': photo,
      'latitude': latitude,
      'longitude': longitude,
      'licenseExpirationDate': licenseExpirationDate.toIso8601String(),
    };
  }
}