import 'package:flutter/material.dart';
import 'package:admin_panel/widgets/common_layout.dart'; // Import the CommonLayout widget
import '../service/food_shop_service.dart';

class FoodShopScreen extends StatefulWidget {
  const FoodShopScreen({super.key});

  @override
  _FoodShopScreenState createState() => _FoodShopScreenState();
}

class _FoodShopScreenState extends State<FoodShopScreen> {
  final FoodShopService _foodShopService = FoodShopService();
  List<FoodShopDTO> _foodShops = [];
  List<FoodShopDTO> _filteredFoodShops = []; // For search functionality
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFoodShops();
    _searchController.addListener(_onSearchChanged); // Listen for search input changes
  }

  Future<void> _loadFoodShops() async {
    try {
      List<FoodShopDTO> foodShops = await _foodShopService.getAllFoodShops();
      setState(() {
        _foodShops = foodShops;
        _filteredFoodShops = foodShops; // Initialize filtered list
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load food shops: $e')),
      );
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFoodShops = _foodShops
          .where((shop) => shop.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _addFoodShop() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFoodShopScreen()),
    );

    if (result == true) {
      _loadFoodShops();
    }
  }

  Future<void> _deleteFoodShop(int shopId) async {
    try {
      await _foodShopService.deleteFoodShop(shopId);
      _loadFoodShops();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete food shop: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: "Food Shops", // Pass the title for the TopNavBar
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columnSpacing: 40, // Add spacing between columns
                dataRowHeight: 80,
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Photo')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Email')), // Add email column
                  DataColumn(label: Text('Description')), // Add business description column
                  DataColumn(label: Text('Expiration Date')), // Add license expiration date column
                  DataColumn(label: Text('Latitude')),
                  DataColumn(label: Text('Longitude')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _filteredFoodShops.map((foodShop) {
                  return DataRow(cells: [
                    DataCell(Text(foodShop.shopId.toString())),
                    DataCell(Text(foodShop.name)),
                    DataCell(
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                          border: Border.all(color: Colors.grey[300]!), // Light grey border
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3), // Subtle shadow
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: Offset(0, 2), // Shadow position
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8), // Match the container's border radius
                          child: Image.network(
                            foodShop.photo,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(foodShop.address)),
                    DataCell(Text(foodShop.phoneNumber)),
                    DataCell(Text(foodShop.email ?? 'N/A')), // Handle null email
                    DataCell(Text(foodShop.businessDescription ?? 'N/A')), // Handle null business description
                    DataCell(Text(foodShop.licenseExpirationDate?.toString() ?? 'N/A')), // Handle null license expiration date
                    DataCell(Text(foodShop.latitude.toString())),
                    DataCell(Text(foodShop.longitude.toString())),
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFoodShop(foodShop.shopId),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddFoodShopScreen extends StatefulWidget {
  const AddFoodShopScreen({super.key});

  @override
  _AddFoodShopScreenState createState() => _AddFoodShopScreenState();
}

class _AddFoodShopScreenState extends State<AddFoodShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _photoController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _expirationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Food Shop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Business Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a business description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _photoController,
                decoration: InputDecoration(
                  labelText: 'Photo URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a photo URL';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _latitudeController,
                decoration: InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a latitude';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _longitudeController,
                decoration: InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a longitude';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _expirationController,
                decoration: InputDecoration(
                  labelText: 'License Expiration Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an expiration date';
                  }
                  try {
                    DateTime.parse(value);
                  } catch (e) {
                    return 'Please enter a valid date in YYYY-MM-DD format';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final foodShop = FoodShop(
                      name: _nameController.text,
                      address: _addressController.text,
                      phoneNumber: _phoneController.text,
                      email: _emailController.text,
                      businessDescription: _descriptionController.text,
                      photo: _photoController.text,
                      latitude: double.parse(_latitudeController.text),
                      longitude: double.parse(_longitudeController.text),
                      licenseExpirationDate: DateTime.parse(_expirationController.text),
                    );

                    try {
                      await FoodShopService().addFoodShop(foodShop);
                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add food shop: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add Food Shop',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}