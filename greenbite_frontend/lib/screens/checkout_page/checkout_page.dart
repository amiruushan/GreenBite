import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/screens/cart/cart_provider.dart';
import 'package:greenbite_frontend/screens/home_page/home_page.dart';
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
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

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

    // Calculate total points first
    final int totalEarnedPoints = cartProvider.cartItems.fold(0, (sum, item) {
      return sum +
          (item.tags.contains("vegan") ||
                  item.tags.contains("low-fat") ||
                  item.tags.contains("sugar-free")
              ? 20
              : 10);
    });

    try {
      String? token = await AuthService.getToken();
      if (token == null) {
        throw Exception("No authentication token found");
      }

      // Process all orders first
      final Map<int, List<FoodItem>> shopItemsMap = {};
      for (var item in cartProvider.cartItems) {
        shopItemsMap.putIfAbsent(item.shopId, () => []).add(item);
      }

      for (var shopId in shopItemsMap.keys) {
        final items = shopItemsMap[shopId]!;
        final totalPrice = items.fold(
            0.0, (sum, item) => sum + (item.price * int.parse(item.quantity)));

        // Handle Stripe payment if selected
        if (selectedOption == "Stripe Payment") {
          await _handleStripePayment(context, totalPrice);
        }

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
                      "description": item.description,
                      "price": item.price,
                      "quantity": item.quantity,
                      "photo": item.photo,
                      "tags": item.tags,
                      "category": item.category,
                      "latitude": item.latitude,
                      "longitude": item.longitude,
                    })
                .toList(),
            "totalAmount": totalPrice,
            "orderTime": DateTime.now().toIso8601String(),
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

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order Confirmed!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
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

  Future<void> _handleStripePayment(
      BuildContext context, double totalAmount) async {
    try {
      String? token = await AuthService.getToken();
      if (token == null) return;

      final int amountInCents = (totalAmount * 100).toInt();
      final response = await http.post(
        Uri.parse(
            '${Config.apiBaseUrl}/api/payments/create?amount=$amountInCents&currency=usd'),
        headers: {"Authorization": "Bearer $token"},
      );

      final responseData = json.decode(response.body);
      final clientSecret = responseData['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'GreenBite',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment successful!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
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
                  color: theme.colorScheme.onSurface,
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
        cartProvider.totalPrice() + 2.50 - cartProvider.discountAmount;

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
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
              "Subtotal", "\$${cartProvider.totalPrice().toStringAsFixed(2)}"),
          _buildSummaryRow("Delivery Fee", "\$2.50"),
          _buildSummaryRow("Discount",
              "-\$${cartProvider.discountAmount.toStringAsFixed(2)}"),
          _buildSummaryRow("Total", "\$${total.toStringAsFixed(2)}",
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
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : theme.colorScheme.onSurface,
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
                color: theme.colorScheme.onSurface,
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
