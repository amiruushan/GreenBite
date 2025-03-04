import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/home_page/home_page.dart';
import 'package:greenbite_frontend/screens/login/signup_screen.dart';
import 'package:greenbite_frontend/service/auth_service';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart'; // ✅ Add Lottie for animations
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> login() async {
    setState(() {
      _isLoading = true; // Show loading spinner
    });

    final String url = "http://192.168.1.3:8080/auth/login";

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
      String token = responseData['token']; // Extract token
      String email = emailController.text; // Extract email

      // Save token and email
      await AuthService.saveToken(token);
      await AuthService.saveEmail(email);

      print("Login Successful: $token");
      print("Email: $email");

      // Fetch and save user ID
      await _fetchAndSaveUserId(email);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      print("Login Failed: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid credentials!")),
      );
    }

    setState(() {
      _isLoading = false; // Hide loading spinner
    });
  }

  Future<void> _fetchAndSaveUserId(String email) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.3:8080/auth/getUserID?email=$email'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        int userId = responseData['userId']; // Extract user ID
        await AuthService.saveUserId(userId); // Save user ID
        print("User ID: $userId");
      } else {
        print("Failed to fetch user ID: ${response.body}");
      }
    } catch (e) {
      print("Error fetching user ID: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40), // Top spacin

            const SizedBox(height: 10),

            // ✅ Title & Subtitle
            Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Login to your account and explore delicious meals.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 30),

            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  "https://assets.bonappetit.com/photos/63ff8b59e1f4511cb9dc2df6/16:9/w_2560%2Cc_limit/The%2520State%2520of%2520New%2520American%2520Restaurants.jpg",
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // ✅ Email Text Field
            _CustomTextField(
              controller: emailController,
              label: "Email",
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 15),

            // ✅ Password Text Field
            _CustomTextField(
              controller: passwordController,
              label: "Password",
              isPassword: true,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 25),

            // ✅ Login Button
            _isLoading
                ? const CircularProgressIndicator()
                : _CustomButton(
                    text: "Continue",
                    onPressed: login,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    shadow: true,
                  ),
            const SizedBox(height: 15),

            // ✅ Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "New member? ",
                  style: TextStyle(color: Colors.black87),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignupScreen()));
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

/// ✅ **Custom Text Field Component**
class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final IconData? prefixIcon;

  const _CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.green) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}

/// ✅ **Custom Button Component**
class _CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool shadow;

  const _CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.shadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: shadow ? 5 : 0, // ✅ Apply shadow if true
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
