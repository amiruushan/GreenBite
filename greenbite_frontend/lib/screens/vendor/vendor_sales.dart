import 'package:flutter/material.dart';
import 'order_details.dart';

class VendorSalesPage extends StatefulWidget {
  @override
  _VendorSalesPageState createState() => _VendorSalesPageState();
}

class _VendorSalesPageState extends State<VendorSalesPage> {
  List<Map<String, dynamic>> sales = [];

  @override
  void initState() {
    super.initState();
    fetchSales();
  }

  // Dummy sales data (Updated with Cancellation Time for Cancelled Orders)
  void fetchSales() async {
    setState(() {
      sales = [
        {
          "id": 1,
          "customer": "John Doe",
          "status": "Completed",
          "items": [
            {"name": "Pizza", "quantity": 2, "price": 12.5},
          ],
          "totalPrice": 25.0,
          "location": "123 Main St, Colombo",
          "orderPlaced": "2025-03-10 14:00",
          "dispatched": "2025-03-10 14:30",
          "delivered": "2025-03-10 15:00",
          "completed": "2025-03-10 15:10",
        },
        {
          "id": 2,
          "customer": "Jane Smith",
          "status": "Ongoing",
          "items": [
            {"name": "Burger", "quantity": 1, "price": 15.0},
          ],
          "totalPrice": 15.0,
          "location": "456 Ocean Ave, Galle",
          "orderPlaced": "2025-03-10 12:00",
        },
        {
          "id": 3,
          "customer": "Michael Lee",
          "status": "Cancelled",
          "items": [
            {"name": "Pasta", "quantity": 3, "price": 10.0},
          ],
          "totalPrice": 30.0,
          "location": "789 Sunset Rd, Kandy",
          "orderPlaced": "2025-03-09 18:00",
          "cancelled": "2025-03-09 18:30",
        },
      ];
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "Ongoing":
        return Colors.yellow;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vendor Sales Overview")),
      body: sales.isEmpty
          ? Center(child: Text("No sales records available"))
          : ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                var sale = sales[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      sale['customer'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Total: \$${sale['totalPrice']}"),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(sale['status']),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        sale['status'],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsPage(order: sale),
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
