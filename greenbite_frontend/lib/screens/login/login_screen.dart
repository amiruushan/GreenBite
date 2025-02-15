import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:greenbite_frontend/screens/home_page/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'email_verification_screen.dart';
import 'user_type_validation_screen.dart';
import 'package:greenbite_frontend/service/auth_service';
import '/../widgets/custom_textfield_widget.dart';
import '/../widgets/custom_button_widget.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final String url = "http://127.0.0.1:8080/auth/login";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text,
        "password": passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String token = responseData['token']; // Assuming token is in response
      AuthService.saveToken(token);
      // Save token in SharedPreferences

      print("Login Successful: $token");
      print("Login Successful: ${response.body}");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      print("Login Failed: ${response.body}");
      // Handle login failure
    }
  }

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
            CustomTextField(controller: emailController, label: "Email"),
            SizedBox(height: 15),
            CustomTextField(
                controller: passwordController,
                label: "Password",
                isPassword: true),
            SizedBox(height: 25),
            CustomButton(
              text: "Continue",
              onPressed: login, // Call login function
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
                          builder: (context) => UserTypeValidationScreen()));
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
