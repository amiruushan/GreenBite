import 'package:flutter/material.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';
import '/../widgets/custom_textfield_widget.dart';
import '/../widgets/custom_button_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupScreen extends StatefulWidget {
  final String? userType;

  SignupScreen({this.userType});

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
        SnackBar(
          content: Text("Please fill in all fields before continuing."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You must accept the terms to continue."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare the data to send, including userType
    Map<String, dynamic> signupData = {
      "email": _emailController.text,
      "firstName": _firstNameController.text,
      "surname": _surnameController.text,
      "username": _usernameController.text,
      "password": _passwordController.text,
      "streetAddress": _streetAddressController.text,
      "district": _selectedDistrict,
      "role": widget.userType, // Add userType here
    };

    try {
      var response = await http.post(
        Uri.parse("http://192.168.1.5:8080/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signupData),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              email: _emailController.text, // Pass the email
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
        SnackBar(
          content: Text("Error: Unable to connect to server"),
          backgroundColor: Colors.red,
        ),
      );
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
            Text("Sign Up",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Create your Account with GreenBite.",
                style: TextStyle(color: Colors.black54)),
            SizedBox(height: 20),
            CustomTextField(label: "Email", controller: _emailController),
            SizedBox(height: 10),
            CustomTextField(
                label: "First Name", controller: _firstNameController),
            SizedBox(height: 10),
            CustomTextField(label: "Surname", controller: _surnameController),
            SizedBox(height: 10),
            CustomTextField(label: "Username", controller: _usernameController),
            SizedBox(height: 10),
            CustomTextField(
                label: "Password",
                isPassword: true,
                controller: _passwordController),
            SizedBox(height: 50),
            Text("Your Address Details",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            CustomTextField(
                label: "Street Address", controller: _streetAddressController),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "District"),
              items:
                  ["Colombo", "Galle", "Gampaha", "Ratnapura"].map((district) {
                return DropdownMenuItem(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDistrict = value;
                });
              },
            ),
            SizedBox(height: 10),
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
                Expanded(child: Text("I accept all terms and conditions")),
              ],
            ),
            SizedBox(height: 10),
            CustomButton(
              text: "Continue",
              onPressed: _validateAndProceed,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            ),
            SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmailVerificationScreen(
                        email: _emailController.text, // Pass the email
                      ),
                    ),
                  );
                },
                child: Text("Already a member? Log In",
                    style: TextStyle(color: Colors.green)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
