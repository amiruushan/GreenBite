import 'package:flutter/foundation.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';

class CartProvider extends ChangeNotifier {
  final List<FoodItem> _cartItems = [];

  List<FoodItem> get cartItems => _cartItems;

  // ✅ Ensure this method accepts two arguments
  void addToCart(FoodItem item, int selectedQuantity) {
    final existingItemIndex =
        _cartItems.indexWhere((cartItem) => cartItem.name == item.name);

    if (existingItemIndex != -1) {
      // ✅ Increase quantity by the selected amount
      _cartItems[existingItemIndex].quantity =
          (int.parse(_cartItems[existingItemIndex].quantity) + selectedQuantity)
              .toString();
    } else {
      // ✅ Add the item with the correct quantity
      _cartItems.add(FoodItem(
        id: item.id,
        name: item.name,
        restaurant: item.restaurant,
        photo: item.photo,
        price: item.price,
        description: item.description,
        category: item.category,
        quantity: selectedQuantity.toString(), // ✅ Set correct quantity
        tags: item.tags,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(FoodItem item) {
    _cartItems.removeWhere((cartItem) => cartItem.name == item.name);
    notifyListeners();
  }

  double totalPrice() {
    return _cartItems.fold(0.0, (sum, item) {
      return sum + (item.price * (int.tryParse(item.quantity) ?? 1));
    });
  }
}
