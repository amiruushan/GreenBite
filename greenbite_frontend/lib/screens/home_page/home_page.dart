import 'dart:async';
import 'dart:convert';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/screens/cart/cart_screen.dart';
import 'package:greenbite_frontend/screens/food_detail_screen/food_detail_screen.dart';
import 'package:greenbite_frontend/screens/home_page/widgets/shop_tab.dart';
import 'package:greenbite_frontend/screens/home_page/widgets/update_location_button.dart';

import 'package:greenbite_frontend/service/auth_service';
import 'package:greenbite_frontend/service/location_service.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/favorites_screen/favorites_screen.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';
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

      // Get the user's current location
      final position = await LocationService.getCurrentLocation();
      final double latitude = position.latitude;
      final double longitude = position.longitude;
      print("User location: Latitude=$latitude, Longitude=$longitude");

      // Fetch nearby food items
      final foodResponse = await http.get(
        Uri.parse(
            '${Config.apiBaseUrl}/api/food-items/nearby/$latitude/$longitude/5'),
        headers: {"Authorization": "Bearer $token"},
      );

      // Fetch favorite items
      final favoriteResponse = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/favorites/user/$userId'),
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
              '${Config.apiBaseUrl}/api/favorites/remove/$userId/${item.id}'),
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
              '${Config.apiBaseUrl}/api/favorites/add?userId=$userId&foodItemId=${item.id}'),
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
  final List<String> _selectedTags = []; // Track multiple selected tags
  final PageController _featuredController =
      PageController(); // Controller for featured items
  int _currentFeaturedIndex = 0; // Track the current featured item index
  Timer? _featuredTimer; // Timer for auto-switching featured items

  @override
  void initState() {
    super.initState();
    // Start auto-switching featured items every 5 seconds
    _startFeaturedTimer();
  }

  @override
  void dispose() {
    _featuredController.dispose(); // Dispose the PageController
    _featuredTimer?.cancel(); // Cancel the timer
    super.dispose();
  }

  // Start the timer for auto-switching featured items
  void _startFeaturedTimer() {
    _featuredTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentFeaturedIndex < widget.foodItems.length - 1) {
        _currentFeaturedIndex++;
      } else {
        _currentFeaturedIndex = 0; // Loop back to the first item
      }
      _featuredController.animateToPage(
        _currentFeaturedIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

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
                        UpdateLocationButton(userId: 1),
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
                        const SizedBox(height: 10),

                        // 🍽 Featured Items Section
                        const Text(
                          "Recommended For You",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 170, // Adjust height as needed
                          child: Stack(
                            children: [
                              // PageView for Featured Items
                              PageView.builder(
                                controller: _featuredController,
                                itemCount: widget.foodItems.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentFeaturedIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final item = widget.foodItems[index];
                                  return GestureDetector(
                                    onTap: () {
                                      // Navigate to the food details page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FoodDetailScreen(foodItem: item),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          children: [
                                            Image.network(
                                              item.photo,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                            // Overlay for item name and price
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(12),
                                                    bottomRight:
                                                        Radius.circular(12),
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.name,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "\$${item.price.toStringAsFixed(2)}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Previous Button (<)
                              Positioned(
                                left: 8,
                                top: 0,
                                bottom: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios,
                                      color: Colors.white),
                                  onPressed: () {
                                    if (_currentFeaturedIndex > 0) {
                                      _featuredController.previousPage(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                ),
                              ),

                              // Next Button (>)
                              Positioned(
                                right: 8,
                                top: 0,
                                bottom: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios,
                                      color: Colors.white),
                                  onPressed: () {
                                    if (_currentFeaturedIndex <
                                        widget.foodItems.length - 1) {
                                      _featuredController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 🍽 Recommended Section
                        const Text(
                          "Food to Suit Your Diet",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        // 🏷 Clickable Tags for Filtering (Horizontal List)
                        SizedBox(
                          height:
                              50, // Set a fixed height for the horizontal tags
                          child: ListView.separated(
                            scrollDirection:
                                Axis.horizontal, // Make the list horizontal
                            itemCount: getUniqueTags().length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                                    width: 8), // Add spacing between tags
                            itemBuilder: (context, index) {
                              final tag =
                                  getUniqueTags()[index]; // Get the current tag
                              bool isSelected = _selectedTags.contains(
                                  tag); // Check if the tag is selected
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
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
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
