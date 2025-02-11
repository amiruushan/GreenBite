import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/cart/cart_screen.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';
import 'package:greenbite_frontend/screens/home_page/widgets/food_card.dart';

class FavoritesScreen extends StatefulWidget {
  final List<FoodItem> favoriteItems;

  const FavoritesScreen({super.key, required this.favoriteItems});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String searchQuery = "";
  List<FoodItem> filteredFavorites = [];

  @override
  void initState() {
    super.initState();
    filteredFavorites = widget.favoriteItems;
  }

  void _searchFavorites(String query) {
    setState(() {
      searchQuery = query;
      filteredFavorites = widget.favoriteItems
          .where((item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.restaurant.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Green Bite"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 117, 237, 123),
        leading: IconButton(
          icon: const Icon(Icons.support_agent),
          onPressed: () {
            print("Support icon tapped");
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CartScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _searchFavorites,
                decoration: InputDecoration(
                  hintText: "Search favorites...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.green),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // ✅ Display Favorites or Show "No Favorites" Message
            Expanded(
              child: filteredFavorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border,
                              size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          const Text(
                            "No favorites found!",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Try searching for something else.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: filteredFavorites.length,
                      itemBuilder: (context, index) {
                        final item = filteredFavorites[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FoodCard(
                            foodItem: item,
                            isFavorite: true,
                            onFavoritePressed: () {
                              // Handle favorite removal if needed
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
