import 'package:admin_panel/widgets/sidebar.dart';
import 'package:admin_panel/widgets/top_navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const CommonLayout({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideBar(),
          Expanded(
            child: Column(
              children: [
                TopNavBar(title: title), // Pass the title to TopNavBar
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}