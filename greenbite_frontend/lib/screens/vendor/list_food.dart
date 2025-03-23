import 'dart:convert';
import 'dart:io'; // For File class
import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/vendor/vendor_sales.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // For image picking
import '../../config.dart';
import '../../widgets/vendor_nav_bar.dart';
import 'vendor_home.dart';
import 'vendor_profile.dart';

class ListFood extends StatefulWidget {
  final int shopId;

  const ListFood({super.key, required this.shopId});

  @override
  State<ListFood> createState() => _ListFoodState();
}

class _ListFoodState extends State<ListFood> {
  int _selectedIndex = 1; // For navigation
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _tagsController = TextEditingController();
  File? _imageFile; // To store the selected image file
  String? _selectedCategory;
  final List<String> _categories = [
    "Pizza",
    "Burger",
    "Cake",
    "Salad",
    "Drink",
    "Dessert",
  ];
  bool _isSaving = false; // To handle loading state

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VendorHome(shopId: widget.shopId),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VendorSalesPage(shopId: widget.shopId),
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VendorProfile(vendorId: widget.shopId),
        ),
      );
    }
  }

  // Function to pick an image from the gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Function to handle form submission
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    String? token = await AuthService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No authentication token found")),
      );
      return;
    }

    // Prepare the food item data
    final foodItem = {
      "name": _nameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "price": double.parse(_priceController.text.trim()),
      "quantity": int.parse(_quantityController.text.trim()),
      "shopId": widget.shopId,
      "tags": _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
      "category": _selectedCategory,
    };

    try {
      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.apiBaseUrl}/api/food-items/list-food-item'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Add the food item JSON
      request.fields['foodItem'] = jsonEncode(foodItem);

      // Add the image file if selected
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foodImage',
            _imageFile!.path,
          ),
        );
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Food item added successfully!")),
        );
        _formKey.currentState!.reset();
        setState(() {
          _imageFile = null;
          _selectedCategory = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to add food item. Please try again.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "GreenBite",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.green,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove elevation
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.green, // Match icon color
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    // Show a dialog to choose between gallery and camera
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Choose Image Source"),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text("Gallery"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.gallery);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text("Camera"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.camera);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : Center(
                            child: Icon(
                              Icons.add_a_photo_rounded,
                              size: 50,
                              color:
                                  isDarkMode ? Colors.grey[400] : Colors.grey,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Food Name
              _buildSectionTitle("Food Name"),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Enter food name",
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
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
              _buildSectionTitle("Description"),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: "Enter food description",
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
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

              // Price and Quantity
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Price"),
                        TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            hintText: "Enter price",
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Quantity"),
                        TextFormField(
                          controller: _quantityController,
                          decoration: InputDecoration(
                            hintText: "Enter quantity",
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
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
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tags
              _buildSectionTitle("Tags"),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  hintText: "Enter tags (comma-separated)",
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
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
              _buildSectionTitle("Category"),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  hintText: "Select category",
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
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

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
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
        shopId: widget.shopId,
      ),
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
