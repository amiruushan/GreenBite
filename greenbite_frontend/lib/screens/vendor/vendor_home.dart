import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:greenbite_frontend/screens/vendor/vendor_profile.dart';
import '../../widgets/vendor_nav_bar.dart';
import 'list_food.dart';
import 'orders.dart';
import 'food_item.dart';

class VendorHome extends StatefulWidget {
  const VendorHome({super.key});

  @override
  _VendorHomeState createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> foodItems = [];
  bool isLoading = true;
  final int vendorId = 1; // Replace with dynamic vendor ID if needed

  // Fetch food items from backend
  Future<void> fetchFoodItems() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/food-items/shop/1'),
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
    fetchFoodItems(); // Fetch data when screen loads
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Orders()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VendorProfile()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const String vendorName = "Street Za";
    const String vendorDescription = "Best organic and fresh produce in town.";
    const String vendorImageUrl =
        "https://lh3.googleusercontent.com/p/AF1QipOv6Va9c7dh1Tml4WiUHs2o5PO0jKF6vZlvLk_U=s680-w680-h510";

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
          : foodItems.isEmpty
              ? const Center(child: Text("No food items available"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          vendorImageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                    ],
                  ),
                ),
      bottomNavigationBar: VendorNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
