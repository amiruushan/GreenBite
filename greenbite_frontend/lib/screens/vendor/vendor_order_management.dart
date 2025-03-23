import 'package:flutter/material.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:http/http.dart' as http;

class VendorOrderManagementScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const VendorOrderManagementScreen({Key? key, required this.order})
      : super(key: key);

  @override
  _VendorOrderManagementScreenState createState() =>
      _VendorOrderManagementScreenState();
}

class _VendorOrderManagementScreenState
    extends State<VendorOrderManagementScreen> {
  bool isLoading = false;

  Future<void> _updateOrderStatus(String status) async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await AuthService.getToken();
      if (token == null) {
        throw Exception("No authentication token found");
      }

      final response = await http.put(
        Uri.parse(
            '${Config.apiBaseUrl}/api/orders/${widget.order['id']}/status?status=$status'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order status updated to $status")),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        throw Exception("Failed to update order status: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating order status: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order #${widget.order['id']}",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 117, 237, 123),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderDetails(theme),
            const SizedBox(height: 20),
            _buildStatusSection(theme),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
                "Customer ID", widget.order['customerId'].toString()),
            _buildDetailRow("Total Amount", "\$${widget.order['totalAmount']}"),
            _buildDetailRow("Order Date", widget.order['orderDate'] ?? "N/A"),
            _buildDetailRow("Payment Method", widget.order['paymentMethod']),
            const SizedBox(height: 16),
            Text(
              "Ordered Items",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.order['orderedItems'].length,
              itemBuilder: (context, index) {
                var item = widget.order['orderedItems'][index];
                return ListTile(
                  title: Text("Item ID: ${item['id']}"),
                  subtitle: Text(
                      "Quantity: ${item['quantity']}, Price: \$${item['price'] ?? 'N/A'}"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Status",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.order['status'],
              style: TextStyle(
                fontSize: 18,
                color: getStatusColor(widget.order['status']),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: isLoading ? null : () => _updateOrderStatus("confirmed"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            "Confirm Order",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : () => _updateOrderStatus("cancelled"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            "Cancel Order",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
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

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "confirmed":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
