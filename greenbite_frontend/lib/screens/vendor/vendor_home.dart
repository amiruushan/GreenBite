import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/vendor/vendor_sales.dart';
import 'package:http/http.dart' as http;
import 'package:greenbite_frontend/screens/vendor/vendor_profile.dart';
import '../../config.dart';
import '../../widgets/vendor_nav_bar.dart';
import 'list_food.dart';
import 'food_item.dart';

class VendorHome extends StatefulWidget {
  final int? shopId; // Make shopId optional

  const VendorHome({super.key, this.shopId}); // Remove required keyword

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
    if (widget.shopId == null) {
      print("Shop ID is null. Cannot fetch vendor details.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${Config.apiBaseUrl}/api/shop/${widget.shopId}'), // Use widget.shopId
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
    if (widget.shopId == null) {
      print("Shop ID is null. Cannot fetch food items.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${Config.apiBaseUrl}/api/food-items/shop/${widget.shopId}'), // Use widget.shopId
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
    fetchVendorData(); // Fetch vendor details
    fetchFoodItems(); // Fetch food items
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ListFood()),
      );
    } else if (index == 2) {
      if (widget.shopId == null) {
        print("Shop ID is null. Cannot navigate to VendorSalesPage.");
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VendorSalesPage(shopId: widget.shopId!), // Pass shopId
        ),
      );
    } else if (index == 3) {
      if (widget.shopId == null) {
        print("Shop ID is null. Cannot navigate to VendorProfile.");
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VendorProfile(vendorId: widget.shopId!), // Pass shopId
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 117, 237, 123),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Expanded(
                  child: foodItems.isEmpty
                      ? const Center(child: Text("No food items available"))
                      : ListView.builder(
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(food["description"]),
                                trailing: Text(
                                  "\$${food["price"].toStringAsFixed(2)}",
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
                ),
              ],
            ),
      bottomNavigationBar: VendorNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
