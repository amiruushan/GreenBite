import 'package:flutter/material.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/screens/home_page/models/shop_item.dart';
import 'package:greenbite_frontend/screens/home_page/widgets/shop_details_page.dart';

import 'package:greenbite_frontend/service/auth_service.dart';

import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:greenbite_frontend/service/location_service.dart';
import 'dart:convert'; // For JSON parsing
import 'package:http/http.dart' as http;

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
      String? token = await AuthService.getToken(); // Retrieve token
      if (token == null) {
        print("No token found");
        return;
      }

      // Get the user's current location
      final position = await LocationService.getCurrentLocation();
      final double latitude = position.latitude;
      final double longitude = position.longitude;

      final response = await http.get(
        Uri.parse(
            "${Config.apiBaseUrl}/api/shop/nearby?lat=$latitude&lon=$longitude&radius=5"),
        headers: {"Authorization": "Bearer $token"},
      );

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
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          errorMessage,
          style: TextStyle(
            color: theme.colorScheme.onSurface, // ✅ Adaptive text color
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nearby Shops",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface, // ✅ Adaptive text color
            ),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shopItems.length,
            itemBuilder: (context, index) {
              final shop = shopItems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey[900]
                          : Colors.white, // ✅ Adaptive background color
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopDetailsPage(
                                shopId: shop.shopId), // Pass the correct shopId
                          ),
                        );
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            shop.imageUrl, // Use imageUrl to display the shop's image
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          shop.name, // Shop name
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme
                                .onSurface, // ✅ Adaptive text color
                          ),
                        ),
                        subtitle: Text(
                          shop.description, // Shop description
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[700], // ✅ Adaptive text color
                          ),
                        ),
                      ),
                    ),
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
