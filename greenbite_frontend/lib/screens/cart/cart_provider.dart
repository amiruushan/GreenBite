import 'package:flutter/foundation.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';

class CartProvider extends ChangeNotifier {
  final List<FoodItem> _cartItems = [];

  List<FoodItem> get cartItems => _cartItems;

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // ✅ Add to cart (updates quantity if item exists)
  void addToCart(FoodItem item, int selectedQuantity) {
    final existingItemIndex =
        _cartItems.indexWhere((cartItem) => cartItem.name == item.name);

    if (existingItemIndex != -1) {
      // ✅ Convert quantity to int and increase it
      int updatedQuantity =
          (int.tryParse(_cartItems[existingItemIndex].quantity) ?? 1) +
              selectedQuantity;
      _cartItems[existingItemIndex].quantity = updatedQuantity.toString();
    } else {
      // ✅ Add new item with selected quantity
      _cartItems.add(FoodItem(
        id: item.id,
        name: item.name,
        restaurant: item.restaurant,
        photo: item.photo,
        price: item.price,
        description: item.description,
        category: item.category,
        quantity: selectedQuantity.toString(),
        shopId: item.shopId,
        tags: item.tags,
      ));
    }
    notifyListeners();
  }

  // ✅ Fixed: Renamed to `removeItem` (match call in CartScreen)
  void removeItem(FoodItem item) {
    final existingItemIndex =
        _cartItems.indexWhere((cartItem) => cartItem.name == item.name);

    if (existingItemIndex != -1) {
      int currentQuantity =
          int.tryParse(_cartItems[existingItemIndex].quantity) ?? 1;

      if (currentQuantity > 1) {
        // ✅ Reduce quantity instead of removing immediately
        _cartItems[existingItemIndex].quantity =
            (currentQuantity - 1).toString();
      } else {
        // ✅ Remove item if quantity is 1
        _cartItems.removeAt(existingItemIndex);
      }
    }
    notifyListeners();
  }

  // ✅ Calculate total price dynamically
  double totalPrice() {
    return _cartItems.fold(0.0, (sum, item) {
      return sum + (item.price * (int.tryParse(item.quantity) ?? 1));
    });
  }
}
