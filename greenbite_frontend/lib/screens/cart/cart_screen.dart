import 'package:flutter/material.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/screens/cart/cart_provider.dart';
import 'package:greenbite_frontend/screens/checkout_page/checkout_page.dart';
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
  String? selectedCoupon;
  double discountAmount = 0.0;
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
      "Authorization": "Bearer $token", // ✅ Add Authorization header
    };
  }

  Future<void> _fetchInventoryCoupons() async {
    try {
      int? userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User ID not found');

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/user/inventory/$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Deduplicate coupons using a Map keyed by coupon_code.
        Map<String, dynamic> uniqueCoupons = {};
        for (var item in data) {
          // Ensure each field has a default value.
          String code = (item["coupon_code"] ?? "UNKNOWN_CODE").toString();
          bool redeemed = item["redeemed"] ?? false;
          double discount =
              (item["discount"] is num) ? item["discount"].toDouble() : 0;
          String dealName = item["deal_name"] ?? "Unknown Deal";
          // Only add non-redeemed coupons OR the coupon that is currently selected.
          if (!redeemed || (selectedCoupon != null && code == selectedCoupon)) {
            uniqueCoupons[code] = {
              "deal_name": dealName,
              "coupon_code": code,
              "discount": discount,
              "redeemed": redeemed,
            };
          }
        }
        setState(() {
          inventoryCoupons = uniqueCoupons.values.toList();
          // If the currently selected coupon is no longer available, clear it.
          if (selectedCoupon != null &&
              !inventoryCoupons
                  .any((coupon) => coupon['coupon_code'] == selectedCoupon)) {
            selectedCoupon = null;
            discountAmount = 0.0;
          }
        });
      } else {
        print("Failed to fetch inventory: ${response.body}");
      }
    } catch (e) {
      print("Error fetching inventory: $e");
    }
  }

  void _applyDiscount(String couponCode, double discount) async {
    // Call backend to redeem coupon first
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/user/inventory/redeem-coupon'),
        headers: await _getHeaders(),
        body: jsonEncode({"couponCode": couponCode}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Applied & redeemed coupon: $couponCode!")),
        );
        // Update selected coupon and discount
        setState(() {
          selectedCoupon = couponCode;
          discountAmount = discount;
        });
        // Refresh the coupon list so that other redeemed coupons are filtered out.
        _fetchInventoryCoupons();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to redeem coupon: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error redeeming coupon: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    double totalPrice = cartProvider.totalPrice();
    double finalPrice = (totalPrice - discountAmount).clamp(0, double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent, // ✅ Transparent AppBar
        iconTheme: IconThemeData(
          color: theme.colorScheme.onBackground, // ✅ Adaptive icon color
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                "Your cart is empty!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color:
                      theme.colorScheme.onBackground, // ✅ Adaptive text color
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: isDarkMode
                            ? Colors.grey[900]
                            : Colors.white, // ✅ Adaptive card color
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Item Image
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
                              // Item Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme
                                            .onBackground, // ✅ Adaptive text color
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item.restaurant,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[
                                                700], // ✅ Adaptive text color
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "\$${item.price.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors
                                            .green, // ✅ Keep green for price
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity Display
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "x${item.quantity}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .green, // ✅ Keep green for quantity
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Remove Button (Trash Icon)
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  cartProvider.removeItem(item);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Coupon Redemption Section
                if (inventoryCoupons.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButton<String>(
                      hint: Text(
                        "Select Coupon",
                        style: TextStyle(
                          color: theme.colorScheme
                              .onBackground, // ✅ Adaptive text color
                        ),
                      ),
                      value: selectedCoupon,
                      items: inventoryCoupons
                          .map<DropdownMenuItem<String>>((coupon) {
                        return DropdownMenuItem<String>(
                          value: coupon['coupon_code'],
                          child: Text(
                            "${coupon['deal_name']} - \$${coupon['discount']}",
                            style: TextStyle(
                              color: theme.colorScheme
                                  .onBackground, // ✅ Adaptive text color
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (couponCode) {
                        var selectedItem = inventoryCoupons.firstWhere(
                            (item) => item['coupon_code'] == couponCode);
                        _applyDiscount(selectedItem['coupon_code'],
                            selectedItem['discount']);
                      },
                    ),
                  ),
                // Checkout Section (Sticky Bottom Bar)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey[900]
                        : Colors.white, // ✅ Adaptive background color
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
                      // Total Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme
                                  .onBackground, // ✅ Adaptive text color
                            ),
                          ),
                          Text(
                            "\$${totalPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme
                                  .onBackground, // ✅ Adaptive text color
                            ),
                          ),
                        ],
                      ),
                      // Discount Applied
                      if (selectedCoupon != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Discount ($selectedCoupon):",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red, // ✅ Keep red for discount
                              ),
                            ),
                            Text(
                              "-\$${discountAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red, // ✅ Keep red for discount
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      // Final Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Final Total:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme
                                  .onBackground, // ✅ Adaptive text color
                            ),
                          ),
                          Text(
                            "\$${finalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  Colors.green, // ✅ Keep green for final price
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Checkout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CheckoutPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor:
                                Colors.green, // ✅ Keep green for button
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
                ),
              ],
            ),
    );
  }
}
