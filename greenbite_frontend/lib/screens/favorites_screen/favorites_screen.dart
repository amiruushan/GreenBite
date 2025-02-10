import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';
import 'package:greenbite_frontend/screens/home_page/widgets/food_card.dart';

class FavoritesScreen extends StatelessWidget {
  final List<FoodItem> favoriteItems;

  const FavoritesScreen({super.key, required this.favoriteItems});

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
              print("Cart icon tapped");
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Favorites Title Below AppBar
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Favorites",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // ✅ Display Favorites List or "No favorites yet!" Message
          Expanded(
            child: favoriteItems.isEmpty
                ? const Center(
                    child: Text(
                    "No favorites yet!",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.green,
                        fontWeight: FontWeight.w700),
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoriteItems.length,
                    itemBuilder: (context, index) {
                      final item = favoriteItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FoodCard(
                          foodItem: item,
                          isFavorite: true,
                          onFavoritePressed: () {
                            // Optionally, you can allow removing favorites here
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
