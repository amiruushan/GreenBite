import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/home_page/data/dummy_data.dart';
import 'package:greenbite_frontend/screens/home_page/widgets/category_card.dart';
import 'package:greenbite_frontend/screens/home_page/widgets/food_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Green Bite"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            print("Profile icon tapped");
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent),
            onPressed: () {
              print("Support icon tapped");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search for food...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),

            // Categories Section
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

            // Recommended Section
            const Text(
              "Recommended For You",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250, // Increased height to prevent card cutoff
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recommendedFoodItems.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4), // Added vertical padding
                      child: FoodCard(foodItem: recommendedFoodItems[index]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Food Items List
            const Text(
              "All Food Items",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dummyFoodItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FoodCard(foodItem: dummyFoodItems[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
