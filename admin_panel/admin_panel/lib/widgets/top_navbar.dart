import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget {
  final String title; // Add a title parameter

  const TopNavBar({super.key, required this.title}); // Accept the title parameter

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title, // Display the title
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
          Row(
            children: [
              Icon(Icons.notifications_none, color: Colors.grey[700]),
              SizedBox(width: 15),
              Icon(Icons.settings, color: Colors.grey[700]),
              SizedBox(width: 15),
              CircleAvatar(backgroundColor: Colors.blueGrey[900], radius: 15),
            ],
          ),
        ],
      ),
    );
  }
}