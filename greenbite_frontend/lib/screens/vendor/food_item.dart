import 'dart:convert';
import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../config.dart';

class FoodItemScreen extends StatefulWidget {
  final Map<String, dynamic> foodItem;

  const FoodItemScreen({super.key, required this.foodItem});

  @override
  _FoodItemScreenState createState() => _FoodItemScreenState();
}

class _FoodItemScreenState extends State<FoodItemScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _tagsController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.foodItem["name"]);
    _descriptionController =
        TextEditingController(text: widget.foodItem["description"]);
    _priceController =
        TextEditingController(text: widget.foodItem["price"].toString());
    _quantityController =
        TextEditingController(text: widget.foodItem["quantity"].toString());
    _tagsController =
        TextEditingController(text: widget.foodItem["tags"].join(', '));
    _selectedCategory = widget.foodItem["category"];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _updateFoodItem() async {
    String? token = await AuthService.getToken();
    if (token == null) {
      throw Exception("No authentication token found");
    }

    final updatedFoodItem = {
      "id": widget.foodItem["id"],
      "name": _nameController.text,
      "description": _descriptionController.text,
      "price": double.parse(_priceController.text),
      "quantity": int.parse(_quantityController.text),
      "photo": widget.foodItem["photo"],
      "shopId": widget.foodItem["shopId"],
      "tags": _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
      "category": _selectedCategory,
    };

    final jsonBody = jsonEncode(updatedFoodItem);

    final response = await http.put(
      Uri.parse('${Config.apiBaseUrl}/api/food-items/update'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food item updated successfully!")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update food item!")),
      );
    }
  }

  void _deleteFoodItem() async {
    String? token = await AuthService.getToken();
    if (token == null) {
      throw Exception("No authentication token found");
    }

    final response = await http.delete(
      Uri.parse('${Config.apiBaseUrl}/api/food-items/${widget.foodItem["id"]}'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food item deleted successfully!")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete food item!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Food Item",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 117, 237, 123),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _deleteFoodItem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.foodItem["photo"],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Food Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: "Tags (comma-separated)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: const [
                "Fast Food",
                "Beverage",
                "Dessert",
                "Healthy",
                "Drink",
                "Dessert",
                "Fruit",
              ].map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateFoodItem,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  "Update Food Item",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
