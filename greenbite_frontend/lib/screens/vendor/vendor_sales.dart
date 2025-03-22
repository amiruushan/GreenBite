import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
import '../../widgets/vendor_nav_bar.dart';
import 'vendor_home.dart';
import 'list_food.dart';
import 'vendor_profile.dart';

class VendorSalesPage extends StatefulWidget {
  final int? shopId; // Make shopId optional

  const VendorSalesPage({super.key, this.shopId}); // Remove required keyword

  @override
  State<VendorSalesPage> createState() => _VendorSalesPageState();
}

class _VendorSalesPageState extends State<VendorSalesPage> {
  final int _selectedIndex = 2; // Set to 2 for Orders screen
  List<Map<String, dynamic>> sales = [];
  bool isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    _fetchTokenAndSales();
  }

  // Function to handle navigation
  void _onItemTapped(int index) {
    if (index == 0) {
      if (widget.shopId == null) {
        print("Shop ID is null. Cannot navigate to VendorHome.");
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VendorHome(shopId: widget.shopId!), // Pass shopId
        ),
      );
    } else if (index == 1) {
      if (widget.shopId == null) {
        print("Shop ID is null. Cannot navigate to ListFood.");
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ListFood(shopId: widget.shopId!), // Pass shopId
        ),
      );
    } else if (index == 3) {
      if (widget.shopId == null) {
        print("Shop ID is null. Cannot navigate to VendorProfile.");
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VendorProfile(vendorId: widget.shopId!), // Pass shopId
        ),
      );
    }
  }

  Future<void> _fetchTokenAndSales() async {
    token = await AuthService.getToken(); // Retrieve token

    if (token == null) {
      print("No token found");
      return;
    }

    print("Token retrieved: $token"); // Print token for debugging
    await fetchSales();
  }

  Future<void> fetchSales() async {
    if (widget.shopId == null) {
      print("Shop ID is null. Cannot fetch sales.");
      return;
    }

    final String url =
        "${Config.apiBaseUrl}/api/orders/shop_order/${widget.shopId}"; // Use widget.shopId

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Use the retrieved token
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          sales = data.map((order) {
            return {
              "id": order["id"],
              "customerId": order["customerId"],
              "status": order["status"].toUpperCase(),
              "totalAmount": order["totalAmount"],
              "orderDate": order["orderDate"],
              "paymentMethod": order["paymentMethod"],
              "orderedItems":
                  jsonDecode(order["orderedItemsJson"]), // Parse ordered items
            };
          }).toList();
          isLoading = false;
        });
      } else {
        print("Failed to load sales. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching sales: $e");
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sales Overview",
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 117, 237, 123),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sales.isEmpty
              ? const Center(child: Text("No sales records available"))
              : ListView.builder(
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    var sale = sales[index];
                    return _buildOrderButton(sale);
                  },
                ),
      bottomNavigationBar: VendorNavBar(
        shopId: widget.shopId!,
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildOrderButton(Map<String, dynamic> sale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ElevatedButton(
        onPressed: () => _showOrderDetails(sale),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order #${sale['id']}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: getStatusColor(sale['status']),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  sale['status'],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the bottom sheet to expand
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Fit content height
            children: [
              const Text(
                "Order Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow("Order ID", sale['id'].toString()),
              _buildDetailRow("Customer ID", sale['customerId'].toString()),
              _buildDetailRow("Status", sale['status']),
              _buildDetailRow("Total Amount", "\$${sale['totalAmount']}"),
              _buildDetailRow("Order Date", sale['orderDate'] ?? "N/A"),
              _buildDetailRow("Payment Method", sale['paymentMethod']),
              const SizedBox(height: 16),
              const Text(
                "Ordered Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true, // Fit content height
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scrolling
                itemCount: sale['orderedItems'].length,
                itemBuilder: (context, index) {
                  var item = sale['orderedItems'][index];
                  return ListTile(
                    title: Text("Item ID: ${item['id']}"),
                    subtitle: Text(
                        "Quantity: ${item['quantity']}, Price: \$${item['price'] ?? 'N/A'}"),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context), // Close bottom sheet
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
