// Category Card Widget
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryCard({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: Colors.green[700]),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

// List of Categories
final List<Map<String, dynamic>> foodCategories = [
  {"icon": Icons.local_pizza, "label": "Pizza"},
  {"icon": Icons.local_dining, "label": "Meals"},
  {"icon": Icons.cake, "label": "Desserts"},
  {"icon": Icons.local_cafe, "label": "Drinks"},
  {"icon": Icons.lunch_dining, "label": "Fast Food"},
  {"icon": Icons.rice_bowl, "label": "Asian"},
  {"icon": Icons.breakfast_dining, "label": "Breakfast"},
];
