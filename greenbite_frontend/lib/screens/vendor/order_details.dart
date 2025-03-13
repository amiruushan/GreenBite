import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;

  OrderDetailsPage({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order Details")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Customer: ${order['customer']}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Delivery Location: ${order['location']}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Order Items:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Column(
              children: order['items'].map<Widget>((item) {
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text(
                    "Quantity: ${item['quantity']} - \$${item['price']} each",
                  ),
                );
              }).toList(),
            ),
            Divider(),
            Text(
              "Total Price: \$${order['totalPrice']}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Common for all (Order Placement Time)
            _buildTimestampRow("Order Placed", order['orderPlaced']),

            // Only for Ongoing Orders
            if (order['status'] == "Ongoing") ...[
              SizedBox(height: 10),
              Text(
                "🚀 Order is still ongoing",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],

            // Only for Cancelled Orders
            if (order['status'] == "Cancelled") ...[
              SizedBox(height: 10),
              _buildTimestampRow("Cancelled", order['cancelled'] ?? "Unknown"),
            ],

            // Only for Completed Orders
            if (order['status'] == "Completed") ...[
              SizedBox(height: 10),
              _buildTimestampRow(
                "Dispatched",
                order['dispatched'] ?? "Unknown",
              ),
              _buildTimestampRow("Delivered", order['delivered'] ?? "Unknown"),
              _buildTimestampRow("Completed", order['completed'] ?? "Unknown"),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampRow(String label, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 10),
          Text("$label: $time", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
