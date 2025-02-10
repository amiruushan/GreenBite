import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    try {
      String jsonString = await rootBundle.loadString('assets/food_data.json');
      List<dynamic> jsonResponse = json.decode(jsonString);
      setState(() {
        foodItems =
            jsonResponse.map((data) => FoodItem.fromJson(data)).toList();
      });
    } catch (e) {
      print("Error loading food items: $e"); // ✅ Prevents app crash
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomePageContent(foodItems: foodItems), // ✅ Always updated
      const SearchScreen(),
      const FavoritesScreen(),
      UserProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex], // ✅ Always shows the latest data
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
  const HomePageContent({super.key, required this.foodItems});

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
      body: foodItems.isEmpty
          ? const Center(
              child: CircularProgressIndicator()) // ✅ Show loading indicator
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search for food...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.search),
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
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: FoodCard(foodItem: foodItems[index]),
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FoodCard(foodItem: foodItems[index]),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
