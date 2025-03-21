import 'package:admin_panel/screens/coupons_screen.dart';
import 'package:admin_panel/screens/customer_screen.dart';
import 'package:admin_panel/screens/food_shop_screen.dart';
import 'package:admin_panel/screens/orders_screen.dart';
import 'package:admin_panel/screens/products_screen.dart';
import 'package:admin_panel/screens/settings_screen.dart';
import 'package:admin_panel/screens/trials_screen.dart';
import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("GreenBite",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          _buildMenuItem(context, "Customers", Icons.people, CustomersScreen()),
          _buildMenuItem(
              context, "Orders", Icons.shopping_cart, OrdersScreen()),
          _buildMenuItem(context, "Products", Icons.store, ProductsScreen()),
          _buildMenuItem(context, "Food Shops", Icons.list, FoodShopScreen()),
          _buildMenuItem(
              context, "Coupons", Icons.card_giftcard, CouponsScreen()),
          _buildMenuItem(context, "Settings", Icons.settings, SettingsScreen()),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String title, IconData icon, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[900]),
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }
}
