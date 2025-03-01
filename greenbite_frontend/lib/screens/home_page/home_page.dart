import 'dart:convert';
import 'package:greenbite_frontend/screens/cart/cart_screen.dart';
import 'package:greenbite_frontend/screens/home_page/widgets/shop_tab.dart';
import 'package:greenbite_frontend/service/auth_service';
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
  int? _userId;
  int _selectedIndex = 0;
  List<FoodItem> foodItems = [];
  Set<FoodItem> favoriteItems = {}; // Use a Set to avoid duplicates

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
    _fetchUserId(); // Fetch the user ID
  }

  Future<void> _fetchUserId() async {
    int? userId = await AuthService.getUserId();
    setState(() {
      _userId = userId ?? 1; // Fallback to 1 if null
    });
  }

  Future<void> _loadFoodItems() async {
    try {
      int? userId = await AuthService.getUserId(); // Retrieve user ID
      if (userId == null) {
        print("No user ID found");
        return;
      }

      String? token = await AuthService.getToken(); // Retrieve token
      if (token == null) {
        print("No token found");
        return;
      }

      // Fetch all food items
      final foodResponse = await http.get(
        Uri.parse('http://192.168.1.5:8080/api/food-items/get'),
        headers: {"Authorization": "Bearer $token"},
      );

      // Fetch favorite items
      final favoriteResponse = await http.get(
        Uri.parse('http://192.168.1.5:8080/api/favorites/user/$userId'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (foodResponse.statusCode == 200 &&
          favoriteResponse.statusCode == 200) {
        List<dynamic> foodJson = json.decode(foodResponse.body);
        List<dynamic> favoriteJson = json.decode(favoriteResponse.body);

        // Convert food items
        List<FoodItem> allFoodItems =
            foodJson.map((data) => FoodItem.fromJson(data)).toList();

        // Convert favorites
        Set<FoodItem> favorites =
            favoriteJson.map((data) => FoodItem.fromJson(data)).toSet();

        setState(() {
          foodItems = allFoodItems;
          favoriteItems = favorites;
        });
      } else {
        print("Failed to load food or favorite items");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _toggleFavorite(FoodItem item) async {
    //final userId = 1; // Replace with actual user ID if available

    try {
      int? userId = await AuthService.getUserId(); // Retrieve user ID
      if (userId == null) {
        print("No user ID found");
        return;
      }
      String? token = await AuthService.getToken(); // Retrieve token
      if (token == null) {
        print("No token found");
        return;
      }
      if (favoriteItems.contains(item)) {
        // If already in favorites, remove from backend
        final response = await http.delete(
          Uri.parse(
              'http://192.168.1.5:8080/api/favorites/remove/$userId/${item.id}'),
          headers: {"Authorization": "Bearer $token"},
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
              'http://192.168.1.5:8080/api/favorites/add?userId=$userId&foodItemId=${item.id}'),
          headers: {"Authorization": "Bearer $token"},
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
    if (_userId == null) {
      // Show a loading indicator while waiting for the user ID
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final List<Widget> screens = [
      HomePageContent(
        foodItems: foodItems,
        favoriteItems: favoriteItems,
        onToggleFavorite: _toggleFavorite,
      ),
      SearchScreen(foodItems: foodItems),
      FavoritesScreen(
        userId: _userId!,
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

class HomePageContent extends StatefulWidget {
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
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  List<String> _selectedTags = []; // Track multiple selected tags

  // Extract unique tags from all food items
  List<String> getUniqueTags() {
    final Set<String> uniqueTags = {};
    for (var item in widget.foodItems) {
      uniqueTags.addAll(item.tags);
    }
    return uniqueTags.toList();
  }

  @override
  Widget build(BuildContext context) {
    // Filter recommended items based on the selected tags
    List<FoodItem> recommendedItems = widget.foodItems
        .where((item) =>
            _selectedTags.isEmpty || // Show all items if no tags are selected
            _selectedTags.every(
                (tag) => item.tags.contains(tag))) // Match ALL selected tags
        .toList();

    return DefaultTabController(
      length: 2, // Two tabs (Food Items & Shops)
      child: Scaffold(
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CartScreen()));
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Food Items"),
              Tab(text: "Shops"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 🍽 Food Items Tab
            widget.foodItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔍 Search Bar
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
                              )
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

                        // 📌 Categories Section
                        const Text(
                          "Categories",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
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

                        // 🍽 Recommended Section
                        const Text(
                          "Recommended For You",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        // 🏷 Clickable Tags for Filtering
                        Wrap(
                          spacing: 8,
                          children: getUniqueTags().map((tag) {
                            bool isSelected = _selectedTags.contains(tag);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedTags
                                        .remove(tag); // Deselect the tag
                                  } else {
                                    _selectedTags.add(tag); // Select the tag
                                  }
                                });
                              },
                              child: Chip(
                                label: Text(tag),
                                backgroundColor: isSelected
                                    ? Colors.green
                                    : Colors.grey[300],
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 10),

                        // 🍽 Recommended Items ListView
                        SizedBox(
                          height: 250,
                          child: recommendedItems.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No items match this filter!",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                                )
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: recommendedItems.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(width: 10),
                                  itemBuilder: (context, index) {
                                    final item = recommendedItems[index];
                                    return SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: FoodCard(
                                          foodItem: item,
                                          isFavorite: widget.favoriteItems
                                              .contains(item),
                                          onFavoritePressed: () =>
                                              widget.onToggleFavorite(item),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 20),

                        // 🍽 All Food Items
                        const Text(
                          "All Food Items",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.foodItems.length,
                          itemBuilder: (context, index) {
                            final item = widget.foodItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: FoodCard(
                                foodItem: item,
                                isFavorite: widget.favoriteItems.contains(item),
                                onFavoritePressed: () =>
                                    widget.onToggleFavorite(item),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

            const ShopsTab(),
          ],
        ),
      ),
    );
  }
}
