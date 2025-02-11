import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/cart/cart_provider.dart';
import 'package:greenbite_frontend/screens/splash_screen/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
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
