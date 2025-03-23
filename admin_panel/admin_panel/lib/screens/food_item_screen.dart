import 'package:flutter/material.dart';
import '../model/food_item_model.dart';
import '../service/food_item_service.dart';
import '../widgets/common_layout.dart'; // Import the CommonLayout

class FoodItemsScreen extends StatefulWidget {
  @override
  _FoodItemsScreenState createState() => _FoodItemsScreenState();
}

class _FoodItemsScreenState extends State<FoodItemsScreen> {
  final FoodItemService _foodItemService = FoodItemService();
  List<FoodItem> _foodItems = [];
  List<FoodItem> _filteredFoodItems = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    try {
      List<FoodItem> items = await _foodItemService.getFoodItems();
      print("Loaded food items: ${items.length}"); // Debug log
      setState(() {
        _foodItems = items;
        _filteredFoodItems = items;
      });
    } catch (e) {
      print("Error loading food items: $e"); // Debug log
    }
  }

  void _searchFoodItemsByShop(int shopId) async {
    try {
      List<FoodItem> items = await _foodItemService.getFoodItemsByShop(shopId);
      print("Filtered food items by shop: ${items.length}"); // Debug log
      setState(() {
        _filteredFoodItems = items;
      });
    } catch (e) {
      print("Error filtering food items: $e"); // Debug log
    }
  }

  void _deleteFoodItem(int id) async {
    try {
      await _foodItemService.deleteFoodItem(id);
      _loadFoodItems();
    } catch (e) {
      print("Error deleting food item: $e"); // Debug log
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: 'Food Items', // Title for the TopNavBar
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Shop ID',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    int shopId = int.tryParse(_searchController.text) ?? 0;
                    if (shopId > 0) {
                      _searchFoodItemsByShop(shopId);
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Expanded(
            child: _filteredFoodItems.isEmpty
                ? Center(
              child: Text("No food items found."),
            )
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Photo')),
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Shop ID')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Tags')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _filteredFoodItems.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        item.photo.isNotEmpty
                            ? Image.network(
                          item.photo,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text("Image not loading"); // Fallback text
                          },
                        )
                            : Text("No image"), // If photo URL is empty
                      ),
                      DataCell(Text(item.id.toString())),
                      DataCell(Text(item.name)),
                      DataCell(Text(item.description)),
                      DataCell(Text('\$${item.price.toStringAsFixed(2)}')),
                      DataCell(Text(item.quantity.toString())),
                      DataCell(Text(item.shopId.toString())),
                      DataCell(Text(item.category)),
                      DataCell(
                        Text(
                          item.tags.join(', '), // Convert list of tags to a comma-separated string
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteFoodItem(item.id);
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}