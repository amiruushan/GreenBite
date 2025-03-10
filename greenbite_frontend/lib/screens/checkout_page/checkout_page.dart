import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/screens/cart/cart_provider.dart';
import 'package:greenbite_frontend/screens/home_page/home_page.dart';
import 'package:greenbite_frontend/service/auth_service.dart';import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
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

    // Format order data
    final orderData = {
      "customerId": 1, // Update this dynamically if needed
      "paymentMethod":
          selectedOption == "Stripe Payment" ? "Credit Card" : "Self Checkout",
      "items": cartProvider.cartItems
          .map((item) => {
                "id": item.id, // Ensure your CartItem model has an `id`
                "quantity": item.quantity,
              })
          .toList(),
    };

    try {
      String? token = await AuthService.getToken(); // Retrieve token
      if (token == null) {
        print("No token found");
        return;
      }
      if (selectedOption == "Stripe Payment") {
        await _handleStripePayment(context);
      }

      // Confirm order in backend
      final orderResponse = await http.post(
        Uri.parse("${Config.apiBaseUrl}0/api/orders/confirm"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(orderData),
      );

      if (orderResponse.statusCode == 200) {
        // Clear the cart
        cartProvider.clearCart();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Order Confirmed!"), backgroundColor: Colors.green),
        );

        // Reload the app (navigate to home)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      } else {
        throw Exception("Failed to confirm order.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Order confirmation failed"),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleStripePayment(BuildContext context) async {
    try {
      String? token = await AuthService.getToken();
      if (token == null) {
        print("No token found");
        return;
      }
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final double totalAmount =
          cartProvider.totalPrice() + 2.50; // Include delivery fee
      final int amountInCents =
          (totalAmount * 100).toInt(); // Stripe requires amount in cents

      // Call backend with dynamic amount
      final response = await http.post(
        Uri.parse(
            '${Config.apiBaseUrl}/api/payments/create?amount=$amountInCents&currency=usd'),
        headers: {"Authorization": "Bearer $token"},
      );

      final responseData = json.decode(response.body);
      final clientSecret = responseData['clientSecret']; // Extract clientSecret

      // Initialize the PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'GreenBite',
        ),
      );

      // Present the PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Payment successful!"),
            backgroundColor: Colors.green),
      );

      // Clear the cart and navigate to the home page
      cartProvider.clearCart();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed"), backgroundColor: Colors.red),
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

              const SizedBox(height: 15),

              // Stripe Payment Option
              _buildOptionTile(
                title: "Card Payment",
                icon: Icons.payment,
                isSelected: selectedOption == "Stripe Payment",
                onTap: () => _selectOption("Stripe Payment"),
              ),

              const SizedBox(height: 15),

              // Self Pickup Option
              _buildOptionTile(
                title: "Self Pick-up",
                icon: Icons.map,
                isSelected: selectedOption == "Self Pick-up",
                onTap: () => _selectOption("Self Pick-up"),
              ),

              const SizedBox(height: 30),

              // 🛒 Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _confirmOrder(context);
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
