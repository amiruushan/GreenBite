import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:greenbite_frontend/screens/cart/cart_provider.dart';
import 'package:greenbite_frontend/screens/splash_screen/splash_screen.dart';
import 'package:greenbite_frontend/screens/vendor/vendor_home.dart';
import 'package:greenbite_frontend/screens/vendor/vendor_profile.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Set your Stripe publishable key
  Stripe.publishableKey =
      "pk_test_51Qsh6fBlbt78FKd8ObfV5e9AMLen2F9efKqkjQmQZwtea7KIiPSGDbPcxak2dvfkKMv9E2wXu5YV1eVVPuGm3OzA00LqEk6B3Z";

  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Green Bite",
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
