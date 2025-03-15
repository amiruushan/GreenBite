import 'package:admin_panel/widgets/sidebar.dart';
import 'package:admin_panel/widgets/top_navbar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideBar(),
          Expanded(
            child: Column(
              children: [
                TopNavBar(),
                Expanded(
                  child: Center(child: Text("Home Page")),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
