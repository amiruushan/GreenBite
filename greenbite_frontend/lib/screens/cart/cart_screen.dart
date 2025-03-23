import 'package:flutter/material.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/screens/cart/cart_provider.dart';
import 'package:greenbite_frontend/screens/checkout_page/checkout_page.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> inventoryCoupons = [];

  @override
  void initState() {
    super.initState();
    _fetchInventoryCoupons();
  }

  Future<Map<String, String>> _getHeaders() async {
    String? token = await AuthService.getToken();
    if (token == null) throw Exception("No JWT token found.");
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<void> _fetchInventoryCoupons() async {
    try {
      int? userId = await AuthService.getUserId();
      if (userId == null) return;

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/user/inventory/$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          inventoryCoupons =
              data.where((coupon) => coupon['redeemed'] == false).toList();
        });
      }
    } catch (e) {
      print("Error fetching coupons: $e");
    }
  }

  void _applyDiscount(String couponCode, double discount, String dealName) {
    final cartProvider = context.read<CartProvider>();
    cartProvider.applyCoupon(
        couponCode, discount, dealName); // Pass the deal name
    _fetchInventoryCoupons(); // Refresh available coupons
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: theme.colorScheme.onSurface,
        ),
      ),
      body: cartProvider.cartItems.isEmpty
          ? _buildEmptyCart(theme)
          : _buildCartContent(cartProvider, theme, isDarkMode),
    );
  }

  Widget _buildEmptyCart(ThemeData theme) {
    return Center(
      child: Text(
        "Your cart is empty!",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildCartContent(
      CartProvider cartProvider, ThemeData theme, bool isDarkMode) {
    final double totalPrice = cartProvider.totalPrice();
    final double finalPrice =
        (totalPrice - cartProvider.discountAmount).clamp(0, double.infinity);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartProvider.cartItems.length,
            itemBuilder: (context, index) {
              final item = cartProvider.cartItems[index];
              return _buildCartItem(item, theme, isDarkMode, cartProvider);
            },
          ),
        ),
        if (inventoryCoupons.isNotEmpty) _buildCouponSelector(theme),
        _buildCheckoutSection(cartProvider, theme, isDarkMode, finalPrice),
      ],
    );
  }

  Widget _buildCartItem(FoodItem item, ThemeData theme, bool isDarkMode,
      CartProvider cartProvider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.photo,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.restaurant,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "\$${item.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "x${item.quantity}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => cartProvider.removeItem(item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSelector(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButton<String>(
        hint: Text(
          "Select Coupon",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        value: context.watch<CartProvider>().selectedCoupon,
        items: inventoryCoupons.map<DropdownMenuItem<String>>((coupon) {
          return DropdownMenuItem<String>(
            value: coupon['coupon_code'],
            child: Text(
              "${coupon['deal_name']} - \$${coupon['discount']}",
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          );
        }).toList(),
        onChanged: (couponCode) {
          if (couponCode != null) {
            var selected = inventoryCoupons
                .firstWhere((item) => item['coupon_code'] == couponCode);
            _applyDiscount(couponCode, selected['discount'],
                selected['deal_name']); // Pass the deal name
          }
        },
      ),
    );
  }

  Widget _buildCheckoutSection(CartProvider cartProvider, ThemeData theme,
      bool isDarkMode, double finalPrice) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                "\$${cartProvider.totalPrice().toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (cartProvider.selectedCoupon != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Discount (${cartProvider.selectedCoupon}):",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    "-\$${cartProvider.discountAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Final Total:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                "\$${finalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckoutPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Proceed to Checkout",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
