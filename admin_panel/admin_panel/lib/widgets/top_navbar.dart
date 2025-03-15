import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Search for customer, product, order etc...",
              style: TextStyle(color: Colors.grey)),
          Row(
            children: [
              Icon(Icons.notifications_none, color: Colors.grey[700]),
              SizedBox(width: 15),
              Icon(Icons.settings, color: Colors.grey[700]),
              SizedBox(width: 15),
              CircleAvatar(backgroundColor: Colors.blueGrey[900], radius: 15),
            ],
          )
        ],
      ),
    );
  }
}
