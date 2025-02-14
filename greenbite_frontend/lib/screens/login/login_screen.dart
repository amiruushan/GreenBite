import 'package:flutter/material.dart';
import 'package:greenbite_frontend/widgets/custom_button_widget.dart';
import 'package:greenbite_frontend/widgets/custom_textfield_widget.dart';
import 'user_type_validation_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Log In",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Log into your Registered Account.",
                style: TextStyle(color: Colors.black54)),
            SizedBox(height: 20),
            CustomTextField(label: "Email"),
            SizedBox(height: 15),
            CustomTextField(label: "Password", isPassword: true),
            SizedBox(height: 25),
            CustomButton(
              text: "Continue",
              onPressed: () {},
              backgroundColor: Colors.green,
              textColor: Colors.white,
            ),
            SizedBox(height: 15),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UserTypeValidationScreen())); // Navigate to Sign Up
                },
                child: Text("New member? Register",
                    style: TextStyle(color: Colors.green)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
