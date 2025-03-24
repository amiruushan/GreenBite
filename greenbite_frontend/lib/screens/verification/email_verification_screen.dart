import 'package:flutter/material.dart';
import 'package:greenbite_frontend/config.dart';
import '../login/login_screen.dart';
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: isDarkMode ? Colors.white : Colors.black),
      ),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Verification",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Enter 6-digit code sent to email",
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.black54,
              ),
            ),
            Text(
              widget.email,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            OTPField(
              onOTPEntered: (enteredOTP) {
                setState(() {
                  otp = enteredOTP; // Update OTP value
                });
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Resend code in 0:40",
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _CustomButton(
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
                    Uri.parse('${Config.apiBaseUrl}/auth/verify'),
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
              shadow: true,
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            decoration: InputDecoration(
              counterText: "",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                ),
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
            ),
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

/// ✅ **Custom Button Component**
class _CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool shadow;

  const _CustomButton({
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
