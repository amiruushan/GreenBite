import 'package:flutter/material.dart';
import '../../widgets/vendor_nav_bar.dart';
import 'vendor_home.dart';
import 'orders.dart';
import 'vendor_profile.dart';

class ListFood extends StatefulWidget {
  const ListFood({super.key});

  @override
  State<ListFood> createState() => _ListFoodState();
}

class _ListFoodState extends State<ListFood> {
  final int _selectedIndex = 1; // Set to 1 for Add screen

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _tagsController = TextEditingController();

  // Variables for image and category
  String? _imageUrl;
  String? _selectedCategory;

  // Dummy categories for dropdown
  final List<String> _categories = [
    "Pizza",
    "Burger",
    "Cake",
    "Salad",
    "Drink",
    "Dessert",
  ];

  // Function to handle navigation
  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VendorHome()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Orders()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VendorProfile()),
      );
    }
  }

  // Function to handle form submission
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Prepare the data in JSON format
      final foodItem = {
        "id": null,
        "name": _nameController.text,
        "description": _descriptionController.text,
        "price": double.parse(_priceController.text),
        "quantity": int.parse(_quantityController.text),
        "photo": _imageUrl ?? "https://example.com/placeholder.jpg",
        "shopId": 1, // Hardcoded for now
        "tags": _tagsController.text.split(','),
        "category": _selectedCategory,
      };

      // Print the JSON data (for demonstration)
      print("Food Item Data: $foodItem");

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food item added successfully!")),
      );

      // Clear the form
      _formKey.currentState!.reset();
      setState(() {
        _imageUrl = null;
        _selectedCategory = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 117, 237, 123),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload (Placeholder)
              GestureDetector(
                onTap: () {
                  // TODO: Implement image upload logic
                  setState(() {
                    _imageUrl = "https://example.com/placeholder.jpg";
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imageUrl == null
                      ? const Center(
                    child: Icon(Icons.add_a_photo_rounded, size: 50, color: Colors.grey),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(_imageUrl!, fit: BoxFit.cover),
                  ),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the food name";
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a description";
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the price";
                  }
                  if (double.tryParse(value) == null) {
                    return "Please enter a valid price";
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the quantity";
                  }
                  if (int.tryParse(value) == null) {
                    return "Please enter a valid quantity";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tags (Keywords)
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: "Tags (comma-separated)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter at least one tag";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a category";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "Add Food Item",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: VendorNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}