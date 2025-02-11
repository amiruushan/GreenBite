import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/cart/cart_provider.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';
import 'package:provider/provider.dart';

class FoodDetailScreen extends StatelessWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(foodItem.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-Size Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                foodItem.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Food Name
            Text(
              foodItem.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Restaurant Name
            Text(
              foodItem.restaurant,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // Price
            Text(
              "\$${foodItem.price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),

            // Description
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              foodItem.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final cartProvider =
                      Provider.of<CartProvider>(context, listen: false);
                  cartProvider.addToCart(foodItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${foodItem.name} added to cart!"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
