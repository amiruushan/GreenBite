import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/food_item_model.dart';

class FoodItemService {
  final String baseUrl = "http://10.190.13.69:8080/api/admin";

  Future<List<FoodItem>> getFoodItems() async {
    final response = await http.get(Uri.parse('$baseUrl/listAllFoodItems'));

    if (response.statusCode == 200) {
      print("API Response: ${response.body}"); // Debug log
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => FoodItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load food items. Status code: ${response.statusCode}');
    }
  }

  Future<List<FoodItem>> getFoodItemsByShop(int shopId) async {
    final response = await http.get(Uri.parse('$baseUrl/listFoodItems/$shopId'));

    if (response.statusCode == 200) {
      print("API Response: ${response.body}"); // Debug log
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => FoodItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load food items by shop. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteFoodItem(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/delete'), body: jsonEncode({'id': id}));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete food item. Status code: ${response.statusCode}');
    }
  }
}