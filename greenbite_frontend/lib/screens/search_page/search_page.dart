import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/cart/cart_screen.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';
import 'package:greenbite_frontend/screens/home_page/widgets/food_card.dart';

class SearchScreen extends StatefulWidget {
  final List<FoodItem> foodItems;

  const SearchScreen({super.key, required this.foodItems});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _filteredItems = [];
  String? _selectedCategory;

  final List<String> _categories = [
    "Pizza",
    "Burger",
    "Pasta",
    "Sushi",
    "Salad",
    "Dessert"
  ];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.foodItems;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterItems();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = (_selectedCategory == category) ? null : category;
      _filterItems();
    });
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.foodItems.where((item) {
        final matchesSearch =
            query.isEmpty || item.name.toLowerCase().contains(query);
        final matchesCategory =
            _selectedCategory == null || item.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // ✅ Theme-based background
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
        backgroundColor: Colors.transparent, // ✅ Transparent AppBar
        elevation: 0, // ✅ No shadow
        iconTheme: IconThemeData(
          color: theme.colorScheme.onBackground, // ✅ Icon color adapts to theme
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            color: theme.colorScheme.onBackground, // ✅ Action icons adapt
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            // 🔍 Themed Search Bar
            Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey[900]
                    : Colors.grey[200], // ✅ Adaptive color
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search for food...",
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search,
                      color: isDarkMode ? Colors.white : Colors.green),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                style: TextStyle(color: theme.colorScheme.onBackground),
              ),
            ),
            const SizedBox(height: 15),

            // 🏷 Category Filters (Dynamically Themed)
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 8), // Spacing between items
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () => _onCategorySelected(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[300]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 🍽 Search Results Section
            Expanded(
              child: _filteredItems.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            "No results found!",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 10),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: FoodCard(
                            foodItem: item,
                            isFavorite: false,
                            onFavoritePressed: () {},
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
