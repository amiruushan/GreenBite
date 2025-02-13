import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:greenbite_frontend/screens/cart/cart_screen.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';
import 'package:greenbite_frontend/screens/home_page/widgets/food_card.dart';

class FavoritesScreen extends StatefulWidget {
  final int userId; // Get user ID dynamically

  const FavoritesScreen({super.key, required this.userId});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FoodItem> favoriteItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/api/favorites/user/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);

        if (decodedResponse is List) {
          setState(() {
            favoriteItems =
                decodedResponse.map((data) => FoodItem.fromJson(data)).toList();
            isLoading = false;
          });
        } else {
          print("Unexpected response format: $decodedResponse");
        }
      } else {
        print("Failed to fetch favorites. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching favorites: $e");
    }
  }

  void _toggleFavorite(FoodItem item) async {
    final userId = widget.userId; // Use the passed user ID

    try {
      final response = await http.delete(
        Uri.parse(
          'http://127.0.0.1:8080/api/favorites/remove/$userId/${item.id}',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          favoriteItems.remove(item); // Remove item from UI
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Removed from favorites!")),
        );
      } else {
        print("Failed to remove favorite. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error removing favorite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteItems.isEmpty
              ? const Center(
                  child: Text(
                    "No favorites yet!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favoriteItems.length,
                  itemBuilder: (context, index) {
                    final item = favoriteItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FoodCard(
                        foodItem: item,
                        isFavorite: true,
                        onFavoritePressed: () {
                          _toggleFavorite(item);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
