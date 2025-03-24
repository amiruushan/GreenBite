import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:greenbite_frontend/config.dart';

class CustomerOrdersPage extends StatefulWidget {
  const CustomerOrdersPage({super.key});

  @override
  _CustomerOrdersPageState createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final String url = "${Config.apiBaseUrl}/api/orders/user_orders/1";
    String? token = await AuthService.getToken(); // Retrieve token

    if (token == null) {
      print("No token found");
      return;
    }

    print("Token retrieved: $token"); // Print token for debugging

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Add the token here
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          orders = responseData.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        print("Failed to fetch orders: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching orders: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("Order #${orders[index]['id']}"),
                  subtitle: Text("Total: Rs. ${orders[index]['totalAmount']}"),
                );
              },
            ),
    );
  }
}
