import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/home_page/models/shop_item.dart';
import 'dart:convert'; // For JSON parsing
import 'package:http/http.dart' as http; // Import ShopItem class

class ShopsTab extends StatefulWidget {
  const ShopsTab({super.key});

  @override
  _ShopsTabState createState() => _ShopsTabState();
}

class _ShopsTabState extends State<ShopsTab> {
  List<ShopItem> shopItems = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchShopData(); // Call the function to fetch shop data
  }

  Future<void> fetchShopData() async {
    try {
      // Replace this URL with your backend API endpoint
      final response =
          await http.get(Uri.parse("https://example.com/shops.json"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          shopItems = data.map((json) => ShopItem.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load shops";
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nearby Shops",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shopItems.length,
            itemBuilder: (context, index) {
              final shop = shopItems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        shop.imageUrl, // Shop's image URL
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      shop.name, // Shop name
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(shop.description), // Shop description
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
