import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/cart/cart_provider.dart';
import 'package:greenbite_frontend/service/auth_service';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({super.key, required this.foodItem});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int selectedQuantity = 1;

  void _addToCart() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart(widget.foodItem, selectedQuantity);

    int earnedPoints = widget.foodItem.tags.contains("vegan") ||
            widget.foodItem.tags.contains("low-fat") ||
            widget.foodItem.tags.contains("sugar-free")
        ? 20
        : 10;

    // ✅ Send API request to add normal points on successful purchase
    try {
      int? userId = await AuthService.getUserId();
      if (userId == null) throw Exception("User ID not found");

      final response = await http.post(
        Uri.parse("http://192.168.1.2:8080/api/user/add-points"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "normalPoints": earnedPoints}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("+$earnedPoints NP added!",
                  style: TextStyle(color: Colors.green))),
        );
      } else {
        print("Failed to add points: ${response.body}");
      }
    } catch (e) {
      print("Error adding points: $e");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              "${widget.foodItem.name} x$selectedQuantity added to cart!")),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItem = cartProvider.cartItems.firstWhere(
      (item) => item.id == widget.foodItem.id,
      orElse: () => FoodItem(
        id: '',
        name: '',
        description: '',
        price: 0,
        quantity: '0',
        photo: '',
        tags: [],
        restaurant: '',
        shopId: 0,
        category: '',
      ),
    );

    int cartQuantity = int.tryParse(cartItem.quantity) ?? 0;
    int maxQuantity = int.tryParse(widget.foodItem.quantity) ?? 1;
    bool canAddMore = (cartQuantity + selectedQuantity) <= maxQuantity;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodItem.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.foodItem.photo,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.foodItem.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.foodItem.restaurant,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              "\$${widget.foodItem.price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Description",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.foodItem.description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              widget.foodItem.tags.contains("vegan") ||
                      widget.foodItem.tags.contains("low-fat") ||
                      widget.foodItem.tags.contains("sugar-free")
                  ? "+20 NP on purchase"
                  : "+10 NP on purchase",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: selectedQuantity > 1
                      ? () {
                          setState(() {
                            selectedQuantity--;
                          });
                        }
                      : null,
                ),
                Text(
                  "$selectedQuantity / $maxQuantity",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: canAddMore ? Colors.green : Colors.grey,
                  ),
                  onPressed: canAddMore
                      ? () {
                          setState(() {
                            selectedQuantity++;
                          });
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canAddMore ? _addToCart : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: canAddMore ? Colors.green : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  canAddMore
                      ? "Add $selectedQuantity to Cart"
                      : "Max Quantity Reached",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
