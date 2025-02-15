import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool isPassword;
  final Color borderColor;
  final Color labelColor;
  final Icon? icon;
  final TextEditingController? controller; // Made optional (nullable)

  const CustomTextField({
    super.key,
    required this.label,
    this.controller, // Now optional
    this.isPassword = false,
    this.borderColor = Colors.grey,
    this.labelColor = Colors.black,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // Will be null if not provided
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        prefixIcon: icon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}
