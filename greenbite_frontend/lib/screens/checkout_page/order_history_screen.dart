import 'package:flutter/material.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/screens/checkout_page/order_summary_screen.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchOrderHistory();
  }

  Future<void> fetchOrderHistory() async {
    try {
      String? token = await AuthService.getToken();
      int? userId = await AuthService.getUserId();
      if (token == null || userId == null) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/orders/user_orders/$userId'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          orders = data;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch order history");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load order history: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order History",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          "Order ID: ${order['id']}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        subtitle: Text(
                          "Total: \$${order['totalAmount'].toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderSummaryPage(
                                orderId: order['id'].toString(),
                                orderTime: order['orderDate'].toString(),
                                total: order['totalAmount'],
                                npEarned:
                                    0, // You can fetch this from the backend if available
                                status: order['status'],
                                latitude: order['latitude'],
                                longitude: order['longitude'],
                                paymentMethod: order['paymentMethod'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
