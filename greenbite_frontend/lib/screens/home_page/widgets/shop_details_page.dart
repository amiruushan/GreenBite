import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/home_page/models/shop_item.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ShopDetailsPage extends StatefulWidget {
  final String shopId;

  const ShopDetailsPage({super.key, required this.shopId});

  @override
  _ShopDetailsPageState createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  ShopItem? shopItem;
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchShopDetails(widget.shopId); // Fetch shop details using the shopId
  }

  Future<void> fetchShopDetails(String shopId) async {
    try {
      final response =
          await http.get(Uri.parse("http://127.0.0.1:8080/api/shop/$shopId"));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          // Fetch shop details
          setState(() {
            shopItem = ShopItem.fromJson(data);
            isLoading = false;
          });

          // Fetch food items for the shop
          fetchFoodItems(shopId);
        } else {
          setState(() {
            errorMessage = "Invalid data received from API";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to load shop details";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
        isLoading = false;
      });
    }
  }

  Future<void> fetchFoodItems(String shopId) async {
    try {
      final response = await http
          .get(Uri.parse("http://127.0.0.1:8080/api/food-items/shop/$shopId"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<FoodItem> newFoodItems =
            data.map((json) => FoodItem.fromJson(json)).toList();

        setState(() {
          if (shopItem != null) {
            shopItem = shopItem!
                .copyWith(foodItems: newFoodItems); // Update food items
          }
        });
      } else {
        setState(() {
          errorMessage = "Failed to load food items";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty || shopItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Shop Details")),
        body: Center(
            child: Text(
                errorMessage.isNotEmpty ? errorMessage : "Shop not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(shopItem!.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                shopItem!.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Shop Name & Description
            Text(
              shopItem!.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              shopItem!.description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Address & Contact
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(shopItem!.address)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.green),
                const SizedBox(width: 8),
                Text(shopItem!.phoneNumber),
              ],
            ),
            const SizedBox(height: 16),

            // Food Items Section
            const Text(
              "Available Food Items",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            shopItem!.foodItems.isEmpty
                ? const Text("No food items available",
                    style: TextStyle(color: Colors.grey))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: shopItem!.foodItems.length,
                    itemBuilder: (context, index) {
                      final food = shopItem!.foodItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              food.photo,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            food.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(food.description),
                          trailing: Text(
                            "\$${food.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
