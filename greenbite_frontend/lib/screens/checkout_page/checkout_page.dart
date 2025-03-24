import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/screens/cart/cart_provider.dart';
import 'package:greenbite_frontend/screens/checkout_page/order_summary_screen.dart';

import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? selectedOption;

  void _selectOption(String option) {
    setState(() {
      selectedOption = option;
    });
  }

  Future<void> _confirmOrder(BuildContext context) async {
    Provider.of<CartProvider>(context, listen: false);

    // Validate payment method selection
    if (selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a payment method!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // If Stripe Payment is selected, handle the payment first
    if (selectedOption == "Stripe Payment") {
      try {
        // Handle Stripe payment
        await _handleStripePayment(context);

        // If payment is successful, proceed with order confirmation
        await _processOrder(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment failed: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
        return; // Stop further processing if payment fails
      }
    } else {
      // For other payment methods (e.g., Self Pick-up), proceed directly with order confirmation
      await _processOrder(context);
    }
  }

  Future<void> _processOrder(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Fetch user's saved location from the backend
    Future<Map<String, double>> _fetchUserLocation() async {
      try {
        String? token = await AuthService.getToken();
        int? userId = await AuthService.getUserId();
        if (token == null || userId == null) {
          throw Exception("User not authenticated");
        }

        final response = await http.get(
          Uri.parse('${Config.apiBaseUrl}/api/users/location/$userId'),
          headers: {"Authorization": "Bearer $token"},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          return {
            "latitude": data["latitude"] ?? 0.0,
            "longitude": data["longitude"] ?? 0.0,
          };
        } else {
          throw Exception("Failed to fetch user location");
        }
      } catch (e) {
        print("Error fetching user location: $e");
        throw e;
      }
    }

    // Calculate total points first
    final int totalEarnedPoints = cartProvider.cartItems.fold(0, (sum, item) {
      return sum +
          (item.tags.contains("Vegan") ||
                  item.tags.contains("High Calory") ||
                  item.tags.contains("Low Sugar") ||
                  item.tags.contains("Low Fat") ||
                  item.tags.contains("Vegetarian") ||
                  item.tags.contains("High Protein")
              ? 50
              : 10);
    });

    try {
      String? token = await AuthService.getToken();
      if (token == null) {
        throw Exception("No authentication token found");
      }

      // Get user's saved location from backend
      final userLocation = await _fetchUserLocation();
      final double latitude = userLocation["latitude"]!;
      final double longitude = userLocation["longitude"]!;

      final Map<int, List<FoodItem>> shopItemsMap = {};
      for (var item in cartProvider.cartItems) {
        shopItemsMap.putIfAbsent(item.shopId, () => []).add(item);
      }

      for (var shopId in shopItemsMap.keys) {
        final items = shopItemsMap[shopId]!;
        final totalPrice = items.fold(
            0.0,
            (sum, item) =>
                sum +
                (item.price * int.parse(item.quantity)) - // Add delivery fee
                cartProvider.discountAmount); // Subtract discount

        // Process order for each shop
        final orderResponse = await http.post(
          Uri.parse("${Config.apiBaseUrl}/api/orders/confirm"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode({
            "shopId": shopId,
            "customerId": await AuthService.getUserId() ?? 0,
            "paymentMethod": selectedOption == "Stripe Payment"
                ? "Credit Card"
                : "Self Checkout",
            "items": items
                .map((item) => {
                      "id": item.id,
                      "name": item.name,
                      "price": item.price,
                      "quantity": item.quantity,
                    })
                .toList(),
            "totalAmount":
                totalPrice, // Pass the total amount (subtotal + delivery fee - discount)
            "orderTime": DateTime.now().toIso8601String(),
            "latitude": latitude, // Now fetched from backend
            "longitude": longitude, // Now fetched from backend
          }),
        );

        if (orderResponse.statusCode != 200) {
          throw Exception(
              "Order failed for shop $shopId: ${orderResponse.body}");
        }
      }

      // Only proceed if all orders succeeded
      // Redeem coupon
      if (cartProvider.selectedCoupon != null) {
        print("Attempting to redeem coupon: ${cartProvider.selectedCoupon}");
        final couponResponse = await http.post(
          Uri.parse('${Config.apiBaseUrl}/api/user/inventory/redeem-coupon'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode({"couponCode": cartProvider.selectedCoupon}),
        );

        print("Coupon redemption response: ${couponResponse.statusCode}");
        print("Coupon redemption response body: ${couponResponse.body}");

        if (couponResponse.statusCode != 200) {
          throw Exception("Coupon redemption failed: ${couponResponse.body}");
        }
      }

      // Add points
      if (totalEarnedPoints > 0) {
        final pointsResponse = await http.post(
          Uri.parse("${Config.apiBaseUrl}/api/users/add-points"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode({
            "userId": await AuthService.getUserId(),
            "normalPoints": totalEarnedPoints
          }),
        );

        if (pointsResponse.statusCode != 200) {
          throw Exception("Points addition failed: ${pointsResponse.body}");
        }
      }

      // Clear cart state
      cartProvider.clearCart();
      cartProvider.clearCoupon();

      // Fetch the order details from the backend
      final orderDetailsResponse = await http.get(
        Uri.parse("${Config.apiBaseUrl}/api/orders/latest"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (orderDetailsResponse.statusCode == 200) {
        final Map<String, dynamic> orderDetails =
            json.decode(orderDetailsResponse.body);

        // Navigate to the OrderSummaryPage with the fetched details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSummaryPage(
              orderId: orderDetails['orderId'],
              orderTime: orderDetails['orderTime'],
              total: orderDetails[
                  'totalAmount'], // Pass the total amount (subtotal + delivery fee - discount)
              npEarned: totalEarnedPoints,
              status: orderDetails['status'],
              latitude: orderDetails['latitude'], // Pass user's latitude
              longitude: orderDetails['longitude'], // Pass user's longitude
              paymentMethod: orderDetails['paymentMethod'],
            ),
          ),
        );
      } else {
        throw Exception(
            "Failed to fetch order details: ${orderDetailsResponse.body}");
      }
    } catch (e) {
      print("Order Error Details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleStripePayment(BuildContext context) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Calculate the total amount (subtotal + delivery fee - discount)
      final double totalAmount =
          cartProvider.totalPrice() - cartProvider.discountAmount;

      String? token = await AuthService.getToken();
      if (token == null) return;

      // Convert the total amount to cents (Stripe requires amounts in cents)
      final int amountInCents = (totalAmount * 100).toInt();

      // Call the backend to create a payment intent
      final response = await http.post(
        Uri.parse(
            '${Config.apiBaseUrl}/api/payments/create?amount=$amountInCents&currency=usd'),
        headers: {"Authorization": "Bearer $token"},
      );

      // Parse the response to get the client secret
      final responseData = json.decode(response.body);
      final clientSecret = responseData['clientSecret'];

      // Initialize the Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'GreenBite',
        ),
      );

      // Present the payment sheet to the user
      await Stripe.instance.presentPaymentSheet();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment successful!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show an error message if the payment fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
      rethrow; // Re-throw the error to stop further processing
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
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
              _buildOrderSummary(),
              const SizedBox(height: 20),
              Text(
                "Choose Payment Method",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 15),
              _buildOptionTile(
                title: "Stripe Payment",
                icon: Icons.payment,
                isSelected: selectedOption == "Stripe Payment",
                onTap: () => _selectOption("Stripe Payment"),
              ),
              const SizedBox(height: 15),
              _buildOptionTile(
                title: "Self Pick-up",
                icon: Icons.map,
                isSelected: selectedOption == "Self Pick-up",
                onTap: () => _selectOption("Self Pick-up"),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedOption != null
                      ? () => _confirmOrder(context)
                      : null,
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

  Widget _buildOrderSummary() {
    final cartProvider = Provider.of<CartProvider>(context);
    final theme = Theme.of(context);
    final double total =
        cartProvider.totalPrice() - cartProvider.discountAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
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
          Text(
            "Order Summary",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 10),
          _buildSummaryRow("Subtotal",
              "Rs. ${cartProvider.totalPrice().toStringAsFixed(2)}"),
          _buildSummaryRow("Discount",
              "-Rs. ${cartProvider.discountAmount.toStringAsFixed(2)}"),
          _buildSummaryRow("Total", "Rs. ${total.toStringAsFixed(2)}",
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    final theme = Theme.of(context);

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
              color: theme.colorScheme.onBackground,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : theme.colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green.withOpacity(0.1)
              : theme.brightness == Brightness.dark
                  ? Colors.grey[900]
                  : Colors.white,
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onBackground,
              ),
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
