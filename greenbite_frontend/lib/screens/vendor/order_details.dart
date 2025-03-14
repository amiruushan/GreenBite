import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;

  OrderDetailsPage({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Details"),
        backgroundColor: Colors.green, // Matching header color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Name with Status Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['customer'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  _buildStatusTag(order['status']),
                ],
              ),
              SizedBox(height: 10),

              // Delivery Location
              _buildInfoRow(
                Icons.location_on,
                "Delivery Location",
                order['location'],
              ),

              // Order Items Section
              SizedBox(height: 10),
              Text(
                "Order Items:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Column(
                children: order['items'].map<Widget>((item) {
                  return _buildOrderItem(item);
                }).toList(),
              ),
              Divider(),

              // Total Price
              _buildInfoRow(
                Icons.attach_money,
                "Total Price",
                "\$${order['totalPrice']}",
              ),

              SizedBox(height: 10),

              // Order Timeline
              _buildTimestampRow("Order Placed", order['orderPlaced']),

              if (order['status'] == "Ongoing") ...[
                _buildInfoText("🚀 Order is still ongoing"),
              ],
              if (order['status'] == "Cancelled") ...[
                _buildTimestampRow(
                  "Cancelled",
                  order['cancelled'] ?? "Unknown",
                ),
              ],
              if (order['status'] == "Completed") ...[
                _buildTimestampRow(
                  "Dispatched",
                  order['dispatched'] ?? "Unknown",
                ),
                _buildTimestampRow(
                  "Delivered",
                  order['delivered'] ?? "Unknown",
                ),
                _buildTimestampRow(
                  "Completed",
                  order['completed'] ?? "Unknown",
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build Order Item List
  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(Icons.fastfood, color: Colors.green),
        title: Text(
          item['name'],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Quantity: ${item['quantity']} - \$${item['price']} each",
        ),
      ),
    );
  }

  // Helper to build an info row
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.green),
        SizedBox(width: 10),
        Expanded(child: Text("$label: $value", style: TextStyle(fontSize: 16))),
      ],
    );
  }

  // Helper to build a timestamp row
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

  // Helper to build a status tag
  Widget _buildStatusTag(String status) {
    Color bgColor;
    switch (status) {
      case "Ongoing":
        bgColor = Colors.orange;
        break;
      case "Cancelled":
        bgColor = Colors.red;
        break;
      case "Completed":
        bgColor = Colors.green;
        break;
      default:
        bgColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper to build additional info text
  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
