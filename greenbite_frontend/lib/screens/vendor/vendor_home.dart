import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/vendor/vendor_sales.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/widgets/vendor_nav_bar.dart';
import 'list_food.dart';
import 'vendor_profile.dart';
import 'food_item.dart';

class VendorHome extends StatefulWidget {
  final int shopId;

  const VendorHome({super.key, required this.shopId});

  @override
  _VendorHomeState createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> foodItems = [];
  bool isLoading = true;
  String vendorName = "";
  String vendorDescription = "";
  String vendorImageUrl = "";

  // Fetch vendor details and food items from backend
  Future<void> fetchVendorData() async {
    String? token = await AuthService.getToken();
    if (token == null) {
      throw Exception("No authentication token found");
    }
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/shop/${widget.shopId}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          vendorName = data["name"] ?? "Unknown Vendor";
          vendorDescription = data["description"] ?? "";
          vendorImageUrl = data["photo"] ?? "";
        });
      } else {
        throw Exception("Failed to load vendor details");
      }
    } catch (e) {
      print("Error fetching vendor details: $e");
    }
  }

  Future<void> fetchFoodItems() async {
    String? token = await AuthService.getToken();
    if (token == null) {
      throw Exception("No authentication token found");
    }
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/food-items/shop/${widget.shopId}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          foodItems = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load food items");
      }
    } catch (e) {
      print("Error fetching food items: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print("Shop ID: ${widget.shopId}"); // Debugging
    fetchVendorData();
    fetchFoodItems();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ListFood(shopId: widget.shopId), // Pass shopId
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VendorSalesPage(shopId: widget.shopId), // Pass shopId
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VendorProfile(vendorId: widget.shopId), // Pass shopId
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("GreenBite"),
        titleTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.green,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove elevation
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor Image
                  vendorImageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            vendorImageUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const SizedBox(height: 200),
                  const SizedBox(height: 16),

                  // Vendor Name and Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendorName,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vendorDescription,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Available Food Items",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // Food Items List
                  ListView.builder(
                    shrinkWrap: true, // Prevent infinite height
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable scrolling
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: foodItems.length,
                    itemBuilder: (context, index) {
                      final food = foodItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              food["photo"],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            food["name"],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(food["description"]),
                          trailing: Text(
                            "Rs. ${food["price"].toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FoodItemScreen(foodItem: food),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
      bottomNavigationBar: VendorNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        shopId: widget.shopId, // Pass shopId to VendorNavBar
      ),
    );
  }
}
