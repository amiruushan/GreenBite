import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/vendor/vendor_profile.dart';
import '../../widgets/vendor_nav_bar.dart';
import 'list_food.dart';
import 'orders.dart';

class VendorHome extends StatefulWidget {
  const VendorHome({super.key});

  @override
  _VendorHomeState createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  int _selectedIndex = 0; // State to manage the selected index

  // Function to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the respective screen based on the selected index
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
    // Dummy data for the vendor
    final String vendorName = "Street Za";
    final String vendorDescription = "Best organic and fresh produce in town.";
    final String vendorImageUrl =
        "https://lh3.googleusercontent.com/p/AF1QipOv6Va9c7dh1Tml4WiUHs2o5PO0jKF6vZlvLk_U=s680-w680-h510";

    // Dummy food items
    final List<Map<String, dynamic>> foodItems = [
      {
        "name": "Fresh Apples",
        "photo": "https://lh3.googleusercontent.com/p/AF1QipMKrqUJrVzlF0WdfP5x5u_aHCVBY0epxPFMDpu4=s680-w680-h510",
        "description": "Crispy and delicious apples.",
        "price": 3.99,
      },
      {
        "name": "Organic Bananas",
        "photo": "https://lh3.googleusercontent.com/p/AF1QipMKrqUJrVzlF0WdfP5x5u_aHCVBY0epxPFMDpu4=s680-w680-h510",
        "description": "Rich in potassium and flavor.",
        "price": 2.49,
      },
      {
        "name": "Juicy Oranges",
        "photo": "https://lh3.googleusercontent.com/p/AF1QipMKrqUJrVzlF0WdfP5x5u_aHCVBY0epxPFMDpu4=s680-w680-h510",
        "description": "Freshly picked oranges.",
        "price": 4.29,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Green Bite"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 117, 237, 123),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Image
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

            // Vendor Name & Description
            Text(
              vendorName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              vendorDescription,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Food Items Section
            const Text(
              "Available Food Items",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            foodItems.isEmpty
                ? const Text(
              "No food items available",
              style: TextStyle(color: Colors.grey),
            )
                : ListView.builder(
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