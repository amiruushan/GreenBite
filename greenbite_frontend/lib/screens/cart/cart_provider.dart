import 'package:flutter/foundation.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';

class CartProvider extends ChangeNotifier {
  final List<FoodItem> _cartItems = [];
  double discountAmount = 0.0;
  String? selectedCoupon;

  List<FoodItem> get cartItems => _cartItems;

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void applyCoupon(String coupon, double discount, String dealName) {
    print(
        "Applying coupon: $coupon with discount: $discount and deal name: $dealName");
    selectedCoupon = coupon;
    discountAmount = discount;
    notifyListeners();
  }

  void clearCoupon() {
    print("Clearing coupon");
    selectedCoupon = null;
    discountAmount = 0.0;
    notifyListeners();
  }

  // ✅ Add to cart (uses ID instead of name to distinguish items)
  void addToCart(FoodItem item, int selectedQuantity) {
    final existingItemIndex =
        _cartItems.indexWhere((cartItem) => cartItem.id == item.id);

    if (existingItemIndex != -1) {
      // ✅ Increase quantity if item exists
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
        latitude: item.latitude,
        longitude: item.longitude,
      ));
    }
    notifyListeners();
  }

  // ✅ Remove item (uses ID instead of name)
  void removeItem(FoodItem item) {
    final existingItemIndex =
        _cartItems.indexWhere((cartItem) => cartItem.id == item.id);

    if (existingItemIndex != -1) {
      int currentQuantity =
          int.tryParse(_cartItems[existingItemIndex].quantity) ?? 1;

      if (currentQuantity > 1) {
        // ✅ Reduce quantity if more than 1
        _cartItems[existingItemIndex].quantity =
            (currentQuantity - 1).toString();
      } else {
        // ✅ Remove item if quantity is 1
        _cartItems.removeAt(existingItemIndex);
      }
    }
    notifyListeners();
  }

  // ✅ Calculate total price
  double totalPrice() {
    return _cartItems.fold(0.0, (sum, item) {
      return sum + (item.price * (int.tryParse(item.quantity) ?? 1));
    });
  }
}
