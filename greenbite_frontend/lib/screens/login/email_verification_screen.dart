import 'package:flutter/material.dart';
import 'login_screen.dart';
import '/../widgets/custom_button_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailVerificationScreen extends StatefulWidget {
  final String email; // Add email parameter

  const EmailVerificationScreen({super.key, required this.email});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  String otp = ""; // Initialize with an empty string

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Verification",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Enter 6-digit code sent to email",
                style: TextStyle(color: Colors.black54)),
            Text(widget.email,
                style:
                    TextStyle(color: Colors.black54)), // Use the passed email
            SizedBox(height: 20),
            OTPField(
              onOTPEntered: (enteredOTP) {
                setState(() {
                  otp = enteredOTP; // Update OTP value
                });
              },
            ),
            SizedBox(height: 10),
            Align(
                alignment: Alignment.centerRight,
                child: Text("Resend code in 0:40")),
            SizedBox(height: 20),
            CustomButton(
              text: "Continue",
              onPressed: () async {
                // Prepare the email and OTP
                String email = widget.email; // Use the passed email
                String otp = this.otp; // Use the OTP entered by the user

                // Create the JSON payload
                Map<String, String> data = {
                  "email": email,
                  "verificationCode": otp,
                };

                // Send the data to the backend
                try {
                  final response = await http.post(
                    Uri.parse('http://127.0.0.1:8080/auth/verify'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode(data),
                  );

                  if (response.statusCode == 200) {
                    // If the server returns a 200 OK response, navigate to LoginScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  } else {
                    // Handle error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: ${response.body}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Request failed: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              backgroundColor: Colors.green,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class OTPField extends StatefulWidget {
  final Function(String) onOTPEntered; // Callback to return OTP

  const OTPField({super.key, required this.onOTPEntered});

  @override
  _OTPFieldState createState() => _OTPFieldState();
}

class _OTPFieldState extends State<OTPField> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onKeyPressed(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
    }
  }

  String _getOTP() {
    return _controllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: 50,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration:
                InputDecoration(counterText: "", border: OutlineInputBorder()),
            onChanged: (value) {
              _onKeyPressed(value, index);
              widget.onOTPEntered(_getOTP()); // Pass OTP to parent
            },
            onSubmitted: (_) {
              if (index < 5) _focusNodes[index + 1].requestFocus();
            },
            onEditingComplete: () {
              if (index > 0 && _controllers[index].text.isEmpty) {
                _focusNodes[index - 1].requestFocus();
              }
            },
          ),
        ),
      ),
    );
  }
}
