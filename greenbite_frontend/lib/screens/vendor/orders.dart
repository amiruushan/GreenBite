import 'package:flutter/material.dart';
import '../../widgets/vendor_nav_bar.dart';
import 'vendor_home.dart';
import 'list_food.dart';
import 'vendor_profile.dart';

class Orders extends StatefulWidget {
  final int? shopId; // Make shopId optional

  const Orders({super.key, this.shopId}); // Remove required keyword

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final int _selectedIndex = 2; // Set to 2 for Orders screen

  // Function to handle navigation
  void _onItemTapped(int index) {
    if (index == 0) {
      if (widget.shopId == null) {
        print("Shop ID is null. Cannot navigate to VendorHome.");
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VendorHome(shopId: widget.shopId!), // Pass shopId
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ListFood()),
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
        title: const Text("Orders"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 117, 237, 123),
      ),
      body: Center(
        child: Text(
          "Orders",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      bottomNavigationBar: VendorNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
