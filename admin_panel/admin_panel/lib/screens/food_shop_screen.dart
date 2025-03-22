import 'package:flutter/material.dart';

import '../service/food_shop_service.dart';

class FoodShopScreen extends StatefulWidget {
  @override
  _FoodShopScreenState createState() => _FoodShopScreenState();
}

class _FoodShopScreenState extends State<FoodShopScreen> {
  final FoodShopService _foodShopService = FoodShopService();
  List<FoodShopDTO> _foodShops = [];

  @override
  void initState() {
    super.initState();
    _loadFoodShops();
  }

  Future<void> _loadFoodShops() async {
    try {
      List<FoodShopDTO> foodShops = await _foodShopService.getAllFoodShops();
      setState(() {
        _foodShops = foodShops;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load food shops: $e')),
      );
    }
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

  Future<void> _deleteFoodShop(int id) async {
    try {
      await _foodShopService.deleteFoodShop(id);
      _loadFoodShops();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete food shop: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Shops'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addFoodShop,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _foodShops.length,
        itemBuilder: (context, index) {
          final foodShop = _foodShops[index];
          return ListTile(
            title: Text(foodShop.name),
            subtitle: Text(foodShop.address),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteFoodShop(foodShop.shopId),
            ),
          );
        },
      ),
    );
  }
}

class AddFoodShopScreen extends StatefulWidget {
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
        title: Text('Add Food Shop'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Business Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a business description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _photoController,
                decoration: InputDecoration(labelText: 'Photo URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a photo URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _latitudeController,
                decoration: InputDecoration(labelText: 'Latitude'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a latitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _longitudeController,
                decoration: InputDecoration(labelText: 'Longitude'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a longitude';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _expirationController,
                decoration: InputDecoration(labelText: 'License Expiration Date (YYYY-MM-DD)'),
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
              SizedBox(height: 20),
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
                child: Text('Add Food Shop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}