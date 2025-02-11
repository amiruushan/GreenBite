import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/splash_screen/splash_screen.dart';
import 'package:greenbite_frontend/screens/store_dashboard/store_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "GreenddBite",
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const StoreDashboard(),
    );
  }
}
