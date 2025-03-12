import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/home_page/home_page.dart';
import 'package:greenbite_frontend/screens/login/login_screen.dart';
import 'package:greenbite_frontend/screens/vendor/vendor_home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to login page with fade animation after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(_fadeRoute(LoginScreen()));
    });
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration:
          const Duration(milliseconds: 500), // Adjust duration as needed
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  // Function to create fade animation route

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: 250,
          color: Colors.white,
        ),
      ),
    );
  }
}
