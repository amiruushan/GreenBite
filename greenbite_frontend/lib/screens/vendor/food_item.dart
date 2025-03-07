import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class FoodItemScreen extends StatefulWidget {
  final Map<String, dynamic> foodItem;

  const FoodItemScreen({super.key, required this.foodItem});

  @override
  _FoodItemScreenState createState() => _FoodItemScreenState();
}

class _FoodItemScreenState extends State<FoodItemScreen> {
  // Controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _tagsController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the food item data
    _nameController = TextEditingController(text: widget.foodItem["name"]);
    _descriptionController = TextEditingController(text: widget.foodItem["description"]);
    _priceController = TextEditingController(text: widget.foodItem["price"].toString());
    _quantityController = TextEditingController(text: widget.foodItem["quantity"].toString());
    _tagsController = TextEditingController(text: widget.foodItem["tags"].join(', '));
    _selectedCategory = widget.foodItem["category"];
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // Function to handle form submission (Update)
  void _updateFoodItem() async {
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

    // Convert the updated food item to JSON
    final jsonBody = jsonEncode(updatedFoodItem);

    // Send the PUT request to the backend API
    final response = await http.put(
      Uri.parse('http://192.168.1.3:8080/api/food-items/update'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonBody,
    );

    // Check the response status
    if (response.statusCode == 200) {
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food item updated successfully!")),
      );

      // Optionally, you can navigate back to the previous screen
      Navigator.pop(context);
    } else {
      // Show an error message if the update failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update food item!")),
      );
    }
  }

  // Function to handle delete
  void _deleteFoodItem() {
    // Print the deleted item (for demonstration)
    print("Deleted Food Item: ${widget.foodItem["name"]}");

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Food item deleted successfully!")),
    );

    // Navigate back to the home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Food Item",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            )),
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
            // Food Image
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

            // Food Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Food Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Quantity
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Tags (Keywords)
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: "Tags (comma-separated)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: const [
                "pizza",
                "Burger",
                "Cake",
                "Salad",
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

            // Update Button
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