import 'package:flutter/material.dart';
import 'package:greenbite_frontend/widgets/custom_button_widget.dart';

class OTPEmailVerificationScreen extends StatelessWidget {
  const OTPEmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Email", style: TextStyle(color: Colors.black)),
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
            Text("Verify Your Email",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(
                "We have sent a verification code to your email address. Please enter the code to verify your email.",
                style: TextStyle(color: Colors.black54)),
            SizedBox(height: 20),
            ListTile(
              title: Text("Email"),
              subtitle: Text("example@example.com"),
              leading: Icon(Icons.email),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: "Enter OTP",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            CustomButton(
              text: "Verify",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NextScreen(),
                  ),
                );
              },
              backgroundColor: Colors.green,
              textColor: Colors.white,
            ),
            SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {
                  // Add logic to resend OTP
                },
                child:
                    Text("Resend OTP", style: TextStyle(color: Colors.green)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for the next screen after verification
class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Next Screen"),
      ),
      body: Center(
        child: Text("Email Verified Successfully!"),
      ),
    );
  }
}
