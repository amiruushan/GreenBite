import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/login/email_verification_screen.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart'; // ✅ Animation support
import 'dart:convert';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _streetAddressController = TextEditingController();
  String? _selectedDistrict;
  bool termsAccepted = false;
  bool _isLoading = false; // ✅ Loading state

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _streetAddressController.dispose();
    super.dispose();
  }

  void _validateAndProceed() async {
    if (_emailController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _streetAddressController.text.isEmpty ||
        _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields before continuing."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must accept the terms to continue."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> signupData = {
      "email": _emailController.text,
      "firstName": _firstNameController.text,
      "surname": _surnameController.text,
      "username": _usernameController.text,
      "password": _passwordController.text,
      "streetAddress": _streetAddressController.text,
      "district": _selectedDistrict,
    };

    try {
      var response = await http.post(
        Uri.parse("http://192.168.1.3:8080/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signupData),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              email: _emailController.text,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Signup failed: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Unable to connect to server"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
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
            const SizedBox(height: 30), // Top spacing

            const SizedBox(height: 10),

            // ✅ Title & Subtitle
            Text(
              "Create an Account",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Sign up to start ordering delicious meals.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 25),

            // ✅ Name Fields
            _CustomTextField(
              label: "First Name",
              controller: _firstNameController,
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 10),
            _CustomTextField(
              label: "Surname",
              controller: _surnameController,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 10),

            // ✅ Email & Username
            _CustomTextField(
              label: "Email",
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 10),
            _CustomTextField(
              label: "Username",
              controller: _usernameController,
              prefixIcon: Icons.account_circle_outlined,
            ),
            const SizedBox(height: 10),

            // ✅ Password Field
            _CustomTextField(
              label: "Password",
              isPassword: true,
              controller: _passwordController,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 10),
            _CustomTextField(
              label: "Street Address",
              controller: _streetAddressController,
              prefixIcon: Icons.home_outlined,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "District",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ["Colombo", "Galle", "Gampaha", "Ratnapura"]
                  .map((district) => DropdownMenuItem(
                        value: district,
                        child: Text(district),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDistrict = value;
                });
              },
            ),
            const SizedBox(height: 10),

            // ✅ Terms & Conditions
            Row(
              children: [
                Checkbox(
                  value: termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      termsAccepted = value!;
                    });
                  },
                ),
                const Expanded(
                    child: Text("I accept all terms and conditions")),
              ],
            ),
            const SizedBox(height: 15),

            // ✅ Signup Button
            _isLoading
                ? const CircularProgressIndicator()
                : _CustomButton(
                    text: "Continue",
                    onPressed: _validateAndProceed,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    shadow: true,
                  ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

/// ✅ **Custom Text Field**
class _CustomTextField extends StatelessWidget {
  final String label;
  final bool isPassword;
  final IconData? prefixIcon;
  final TextEditingController controller;

  const _CustomTextField({
    super.key,
    required this.label,
    required this.controller,
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

/// ✅ **Custom Button**
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: shadow ? 5 : 0,
        ),
        child: Text(
          text, // Display the text here
          style: TextStyle(
            fontSize: 16, // Adjust the font size if needed
            fontWeight: FontWeight.bold, // Make it bold if necessary
          ),
        ),
      ),
    );
  }
}
