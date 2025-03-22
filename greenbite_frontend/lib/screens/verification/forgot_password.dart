import 'package:flutter/material.dart';
import 'email_verification_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final String email;

  const ForgotPasswordScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color:
              isDarkMode ? Colors.white : Colors.black, // Adaptive icon color
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Forgot Password?",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? Colors.white
                    : Colors.black, // Adaptive text color
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Enter your email to reset your password.",
              style: TextStyle(
                color: isDarkMode
                    ? Colors.grey[400]
                    : Colors.black54, // Adaptive text color
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Email Reset Option
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmailVerificationScreen(
                      email: email,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey[800]
                      : Colors.white, // Adaptive container color
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (!isDarkMode)
                      const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email, size: 30, color: Colors.green),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black, // Adaptive text color
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Send reset link to email",
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.black54, // Adaptive text color
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: isDarkMode
                          ? Colors.grey[400]
                          : Colors.black54, // Adaptive icon color
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
