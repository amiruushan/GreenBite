import 'dart:convert';
import 'package:greenbite_frontend/screens/cart/cart_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/favorites_screen/favorites_screen.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';
import 'package:greenbite_frontend/screens/home_page/widgets/category_card.dart';
import 'package:greenbite_frontend/screens/home_page/widgets/food_card.dart';
import 'package:greenbite_frontend/screens/search_page/search_page.dart';
import 'package:greenbite_frontend/screens/user_profile/user_profile_screen.dart';
import 'package:greenbite_frontend/widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<FoodItem> foodItems = [];
  Set<FoodItem> favoriteItems = {}; // Use a Set to avoid duplicates

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8080/api/food-items/get'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          foodItems =
              jsonResponse.map((data) => FoodItem.fromJson(data)).toList();
        });
      } else {
        print("Failed to load food items");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _toggleFavorite(FoodItem item) async {
    final userId = 1; // Replace with actual user ID if available

    try {
      if (favoriteItems.contains(item)) {
        // If already in favorites, remove from backend
        final response = await http.delete(
          Uri.parse(
              'http://127.0.0.1:8080/api/favorites/remove/$userId/${item.id}'),
        );

        if (response.statusCode == 200) {
          setState(() {
            favoriteItems.remove(item);
          });
        } else {
          print("Failed to remove favorite. Status: ${response.statusCode}");
        }
      } else {
        // If not in favorites, add to backend
        final response = await http.post(
          Uri.parse(
              'http://127.0.0.1:8080/api/favorites/add?userId=$userId&foodItemId=${item.id}'),
        );

        if (response.statusCode == 200) {
          setState(() {
            favoriteItems.add(item);
          });
        } else {
          print("Failed to add favorite. Status: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Error updating favorites: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _removeFavorite(FoodItem item) {
    setState(() {
      favoriteItems.removeWhere((fav) => fav.id == item.id);
      ;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int userId = 1;
    final List<Widget> screens = [
      HomePageContent(
        foodItems: foodItems,
        favoriteItems: favoriteItems,
        onToggleFavorite: _toggleFavorite,
      ),
      SearchScreen(foodItems: foodItems),
      FavoritesScreen(
        userId: userId,
        onRemoveFavorite: _removeFavorite,
      ),
      UserProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// ✅ Extracted Home Page Content Widget
class HomePageContent extends StatelessWidget {
  final List<FoodItem> foodItems;
  final Set<FoodItem> favoriteItems;
  final Function(FoodItem) onToggleFavorite;

  const HomePageContent({
    super.key,
    required this.foodItems,
    required this.favoriteItems,
    required this.onToggleFavorite,
  });

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
      body: foodItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      decoration: InputDecoration(
                        hintText: "Search for food...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.green),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Categories",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: foodCategories.map((category) {
                        return CategoryCard(
                          icon: category["icon"],
                          label: category["label"],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Recommended For You",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: foodItems.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final item = foodItems[index];
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: FoodCard(
                              foodItem: item,
                              isFavorite: favoriteItems.contains(item),
                              onFavoritePressed: () => onToggleFavorite(item),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "All Food Items",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: foodItems.length,
                    itemBuilder: (context, index) {
                      final item = foodItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FoodCard(
                          foodItem: item,
                          isFavorite: favoriteItems
                              .contains(item), // ✅ Checks correctly
                          onFavoritePressed: () =>
                              onToggleFavorite(item), // ✅ Toggle function
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
