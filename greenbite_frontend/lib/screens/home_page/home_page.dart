import 'dart:async';
import 'dart:convert';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/screens/cart/cart_screen.dart';
import 'package:greenbite_frontend/screens/food_detail_screen/food_detail_screen.dart';
import 'package:greenbite_frontend/screens/home_page/widgets/shop_tab.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:greenbite_frontend/service/location_service.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/favorites_screen/favorites_screen.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';
import 'package:greenbite_frontend/screens/home_page/widgets/food_card.dart';
import 'package:greenbite_frontend/screens/search_page/search_page.dart';
import 'package:greenbite_frontend/screens/user_profile/user_profile_screen.dart';
import 'package:greenbite_frontend/widgets/bottom_nav_bar.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyAYKLcSlEwCHUZP23MmBG7SstvpP8xZcAQ');
  List<Prediction> _predictions = [];
  String _selectedLocation = "";
  bool _showDropdown = false; // Controls whether the dropdown is visible

  int? _userId;
  int _selectedIndex = 0;
  List<FoodItem> foodItems = [];
  Set<FoodItem> favoriteItems = {}; // Use a Set to avoid duplicates

  bool _isLoading = true; // Track loading state
  bool _noItemsFound = false; // Track if no items are found

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

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
        _showDropdown = false; // Hide dropdown if query is empty
      });
      return;
    }

    final response = await _places.autocomplete(query);
    if (response.status == "OK") {
      setState(() {
        _predictions = response.predictions;
        _showDropdown = true; // Show dropdown when predictions are available
      });
    } else {
      print("Error fetching predictions: ${response.errorMessage}");
    }
  }

  Future<Map<String, double>> _fetchUserLocation(int userId) async {
    try {
      String? token = await AuthService.getToken(); // Retrieve token
      if (token == null) {
        print("No token found");
        throw Exception("No token found");
      }

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/users/location/$userId'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          "latitude": data["latitude"],
          "longitude": data["longitude"],
        };
      } else {
        throw Exception("Failed to fetch user location");
      }
    } catch (e) {
      print("Error fetching user location: $e");
      rethrow;
    }
  }

  Future<void> _onLocationSelected(Prediction prediction) async {
    final details = await _places.getDetailsByPlaceId(prediction.placeId ?? "");
    if (details.status == "OK") {
      final lat = details.result.geometry?.location.lat;
      final lng = details.result.geometry?.location.lng;
      if (lat != null && lng != null && _userId != null) {
        // Update user location in the backend
        await LocationService.updateUserLocation(_userId!, lat, lng);

        // Update the selected location text and hide the dropdown
        setState(() {
          _selectedLocation = prediction.description ?? "";
          _showDropdown = false; // Hide dropdown after selection
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Location updated to ${prediction.description}")),
        );

        // Refresh the list of nearby food items
        await _loadFoodItems();
      }
    }
  }

  Future<void> _loadFoodItems() async {
    setState(() {
      _isLoading = true; // Start loading
      _noItemsFound = false; // Reset no items found flag
    });

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

      // Fetch the user's saved location from the backend
      final userLocation = await _fetchUserLocation(userId);
      final double latitude = userLocation["latitude"]!;
      final double longitude = userLocation["longitude"]!;
      print(
          "User location from backend: Latitude=$latitude, Longitude=$longitude");

      // Fetch nearby food items within a 10km radius
      final foodResponse = await http.get(
        Uri.parse(
            '${Config.apiBaseUrl}/api/food-items/nearby/$latitude/$longitude/10'), // 10km radius
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
          _isLoading = false; // Stop loading
          _noItemsFound = foodItems.isEmpty; // Set no items found flag
        });
      } else {
        print("Failed to load food or favorite items");
        setState(() {
          _isLoading = false; // Stop loading
          _noItemsFound = true; // Set no items found flag
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        _isLoading = false; // Stop loading
        _noItemsFound = true; // Set no items found flag
      });
    }
  }

  void _toggleFavorite(FoodItem item) async {
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
        onSearchLocations: _searchLocations,
        onLocationSelected: _onLocationSelected,
        predictions: _predictions,
        selectedLocation: _selectedLocation,
        showDropdown: _showDropdown,
        onCloseDropdown: () {
          setState(() {
            _showDropdown = false; // Close dropdown when requested
          });
        },
        isLoading: _isLoading,
        noItemsFound: _noItemsFound,
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
  final Function(String) onSearchLocations;
  final Function(Prediction) onLocationSelected;
  final List<Prediction> predictions;
  final String selectedLocation;
  final bool showDropdown;
  final VoidCallback onCloseDropdown;
  final bool isLoading;
  final bool noItemsFound;

  const HomePageContent({
    super.key,
    required this.foodItems,
    required this.favoriteItems,
    required this.onToggleFavorite,
    required this.onSearchLocations,
    required this.onLocationSelected,
    required this.predictions,
    required this.selectedLocation,
    required this.showDropdown,
    required this.onCloseDropdown,
    required this.isLoading,
    required this.noItemsFound,
  });

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final List<String> _selectedTags = [];
  final PageController _featuredController = PageController();
  int _currentFeaturedIndex = 0;
  Timer? _featuredTimer;
  final FocusNode _searchFocusNode =
      FocusNode(); // Focus node for the search bar
  final TextEditingController _searchController =
      TextEditingController(); // Controller for the search bar

  @override
  void initState() {
    super.initState();
    _startFeaturedTimer();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        widget.onCloseDropdown(); // Close dropdown when search bar loses focus
      }
    });

    // Set the initial text in the search bar
    _searchController.text = widget.selectedLocation;
  }

  @override
  void didUpdateWidget(HomePageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the search bar text when the selected location changes
    if (widget.selectedLocation != oldWidget.selectedLocation) {
      _searchController.text = widget.selectedLocation;
    }
  }

  @override
  void dispose() {
    _featuredController.dispose();
    _featuredTimer?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startFeaturedTimer() {
    _featuredTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentFeaturedIndex < widget.foodItems.length - 1) {
        _currentFeaturedIndex++;
      } else {
        _currentFeaturedIndex = 0;
      }
      _featuredController.animateToPage(
        _currentFeaturedIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  List<String> getUniqueTags() {
    final Set<String> uniqueTags = {};
    for (var item in widget.foodItems) {
      uniqueTags.addAll(item.tags);
    }
    return uniqueTags.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Filter recommended items based on the selected tags
    List<FoodItem> recommendedItems = widget.foodItems
        .where((item) =>
            _selectedTags.isEmpty ||
            _selectedTags.every((tag) => item.tags.contains(tag)))
        .toList();

    return DefaultTabController(
      length: 2, // Two tabs (Food Items & Shops)
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            "GreenBite",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.green,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: theme.colorScheme.onSurface,
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Food Items"),
              Tab(text: "Shops"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 🍽 Food Items Tab
            widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
                    onTap: () {
                      // Close the dropdown and unfocus the search bar when tapping outside
                      _searchFocusNode.unfocus();
                      widget.onCloseDropdown();
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔍 Location Search Bar (Always Visible)
                          Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[900]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  focusNode: _searchFocusNode,
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: "Search for a location...",
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                  onChanged: widget.onSearchLocations,
                                ),
                                if (widget.showDropdown &&
                                    widget.predictions.isNotEmpty)
                                  SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      itemCount: widget.predictions.length,
                                      itemBuilder: (context, index) {
                                        final prediction =
                                            widget.predictions[index];
                                        return ListTile(
                                          title: Text(
                                              prediction.description ?? ""),
                                          onTap: () {
                                            widget
                                                .onLocationSelected(prediction);
                                            _searchFocusNode
                                                .unfocus(); // Close keyboard
                                          },
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Show "No food items near you" message if no items are found
                          if (widget.noItemsFound)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Lottie.asset(
                                    'assets/animations/notfound.json',
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "No food items near you",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Show food items if available
                          if (!widget.noItemsFound) ...[
                            // 🍽 Featured Items Section
                            Text(
                              "Recommended For You",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 170,
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FoodDetailScreen(
                                                      foodItem: item),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                                                          const BorderRadius
                                                              .only(
                                                        bottomLeft:
                                                            Radius.circular(12),
                                                        bottomRight:
                                                            Radius.circular(12),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          item.name,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          "\$${item.price.toStringAsFixed(2)}",
                                                          style:
                                                              const TextStyle(
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
                                            duration: const Duration(
                                                milliseconds: 500),
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
                                            duration: const Duration(
                                                milliseconds: 500),
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
                            Text(
                              "Food to Suit Your Diet",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 🏷 Clickable Tags for Filtering (Horizontal List)
                            SizedBox(
                              height: 50,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: getUniqueTags().length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final tag = getUniqueTags()[index];
                                  bool isSelected = _selectedTags.contains(tag);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedTags.remove(tag);
                                        } else {
                                          _selectedTags.add(tag);
                                        }
                                      });
                                    },
                                    child: Chip(
                                      label: Text(tag),
                                      backgroundColor: isSelected
                                          ? Colors.green
                                          : (isDarkMode
                                              ? Colors.grey[800]
                                              : Colors.grey[300]),
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : theme.colorScheme.onSurface,
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
                                  ? Center(
                                      child: Text(
                                        "No items match this filter!",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.5),
                                        ),
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                            Text(
                              "All Food Items",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
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
                                    isFavorite:
                                        widget.favoriteItems.contains(item),
                                    onFavoritePressed: () =>
                                        widget.onToggleFavorite(item),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

            const ShopsTab(),
          ],
        ),
      ),
    );
  }
}
