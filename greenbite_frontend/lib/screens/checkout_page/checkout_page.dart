import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:greenbite_frontend/screens/cart/cart_provider.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:greenbite_frontend/screens/home_page/home_page.dart'; // Import the HomePage

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedOption = "Card Payment"; // Default selection

  void _selectOption(String option) {
    setState(() {
      selectedOption = option;
    });
  }

  Future<void> _confirmOrder(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItems = cartProvider.cartItems;

    // Prepare the order data to send to the backend
    final orderData = {
      "paymentMethod": selectedOption,
      "items": cartItems
          .map((item) => {
                "id": item.id,
                "quantity": item.quantity,
              })
          .toList(),
    };

    try {
      // Send the order to the backend
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8080/api/orders/confirm"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(orderData),
      );

      if (response.statusCode == 200) {
        // Order confirmed successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order confirmed! Your items are ready for pickup."),
            backgroundColor: Colors.green,
          ),
        );

        // Clear the cart after successful order
        cartProvider.clearCart();

        // Navigate to the HomePage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage()), // Navigate to HomePage
          (route) => false, // Remove all routes from the stack
        );
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to confirm order. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // 🍽 Header Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    "https://media.istockphoto.com/id/1388108025/vector/contactless-customer-payment-to-grocery-shop-cashier.jpg?s=612x612&w=0&k=20&c=xm_MasxuaP4kzcyG1cj7B1zjteWdrhuda8o2Xs2Ze0g=",
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 📝 Order Summary
              _buildOrderSummary(),

              const SizedBox(height: 20),

              // 💳 Choose Payment Method
              const Text(
                "Choose Payment Method",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Card Payment Option
              _buildOptionTile(
                title: "Card Payment",
                icon: LucideIcons.creditCard,
                isSelected: selectedOption == "Card Payment",
                onTap: () => _selectOption("Card Payment"),
              ),

              const SizedBox(height: 15),

              // Self Pickup Option
              _buildOptionTile(
                title: "Self Pick-up",
                icon: LucideIcons.mapPin,
                isSelected: selectedOption == "Self Pick-up",
                onTap: () => _selectOption("Self Pick-up"),
              ),

              const SizedBox(height: 30),

              // 🛒 Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedOption == "Self Pick-up") {
                      _confirmOrder(context); // Confirm order for self-pickup
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Selected: $selectedOption"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Proceed to Payment",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🛍 Order Summary Widget
  Widget _buildOrderSummary() {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
              "Subtotal", "\$${cartProvider.totalPrice().toStringAsFixed(2)}"),
          _buildSummaryRow("Delivery Fee", "\$2.50"),
          _buildSummaryRow("Total",
              "\$${(cartProvider.totalPrice() + 2.50).toStringAsFixed(2)}",
              isTotal: true),
        ],
      ),
    );
  }

  // 🧾 Order Summary Row Widget
  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // 💳 Payment Option Tile Widget
  Widget _buildOptionTile({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.green),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green, size: 26),
          ],
        ),
      ),
    );
  }
}
