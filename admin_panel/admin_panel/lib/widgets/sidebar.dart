import 'package:admin_panel/screens/customer_management.dart';
import 'package:admin_panel/screens/customer_screen.dart';
import 'package:admin_panel/screens/orders_screen.dart';
import 'package:admin_panel/screens/products_screen.dart';
import 'package:admin_panel/screens/settings_screen.dart';
import 'package:admin_panel/screens/trials_screen.dart';
import 'package:admin_panel/screens/vendor_management.dart';
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
          _buildMenuItem(
              context, "Customers", Icons.people, CustomerManagement()),
          _buildMenuItem(context, "Shops", Icons.people, VendorManagement()),
          _buildMenuItem(
              context, "Orders", Icons.shopping_cart, OrdersScreen()),
          _buildMenuItem(context, "Products", Icons.store, ProductsScreen()),
          _buildMenuItem(context, "Trials", Icons.list, TrialsScreen()),
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
