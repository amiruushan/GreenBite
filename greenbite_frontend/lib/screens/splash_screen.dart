import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // @override
  // void initState() {
  //   super.initState();

  //   // Navigate to login page with fade animation after 3 seconds
  //   Future.delayed(const Duration(seconds: 3), () {
  //     Navigator.of(context).pushReplacement(_fadeRoute(const LoginPage()));
  //   });
  // }

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
