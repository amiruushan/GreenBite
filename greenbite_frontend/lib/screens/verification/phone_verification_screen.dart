import 'package:flutter/material.dart';
import 'package:greenbite_frontend/widgets/custom_button_widget.dart';
import '../login/login_screen.dart';

class PhoneVerificationScreen extends StatelessWidget {
  const PhoneVerificationScreen({super.key});

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
            Text("Enter 6-digit code sent to phone number",
                style: TextStyle(color: Colors.black54)),
            Text("XXXXXX0316", style: TextStyle(color: Colors.black54)),
            SizedBox(height: 20),
            OTPField(), // Replacing Row with the OTPField widget
            SizedBox(height: 10),
            Align(
                alignment: Alignment.centerRight,
                child: Text("Resend code in 0:40")),
            SizedBox(height: 20),
            CustomButton(
              text: "Continue",
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LoginScreen())); // Navigate to Login after OTP
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
            onChanged: (value) => _onKeyPressed(value, index),
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
