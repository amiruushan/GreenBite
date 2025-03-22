import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:greenbite_frontend/screens/cart/cart_provider.dart';
import 'package:greenbite_frontend/screens/splash_screen/splash_screen.dart';
import 'package:greenbite_frontend/theme_provider.dart'; // Import ThemeProvider
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Set your Stripe publishable key
    Stripe.publishableKey =
    "pk_test_51Qsh6fBlbt78FKd8ObfV5e9AMLen2F9efKqkjQmQZwtea7KIiPSGDbPcxak2dvfkKMv9E2wXu5YV1eVVPuGm3OzA00LqEk6B3Z";

    // ✅ Apply Stripe settings
    await Stripe.instance.applySettings();
    print("Stripe initialized successfully");
  } catch (e) {
    print("Failed to initialize Stripe: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Green Bite",
      theme: ThemeData.light(), // Light Theme
      darkTheme: ThemeData.dark(), // Dark Theme
      themeMode: themeProvider.themeMode, // Apply theme mode
      home: SplashScreen(),
    );
  }
}