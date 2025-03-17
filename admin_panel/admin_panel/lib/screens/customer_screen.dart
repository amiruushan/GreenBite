import 'package:flutter/material.dart';

class CustomersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _blankScreen(context, "Customers");
}

Widget _blankScreen(BuildContext context, String title) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text("$title Page")),
  );
}
