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

  void fetchSales() {
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
          "paymentMethod": "Credit Card",
          "vendor": "Pizza Palace",
          "contact": "+94711234567",
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
          "paymentMethod": "Cash on Delivery",
          "vendor": "Burger Haven",
          "contact": "+94778765432",
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
          "paymentMethod": "Debit Card",
          "vendor": "Pasta Paradise",
          "contact": "+94776543210",
        },
      ];
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "Ongoing":
        return Colors.orange;
      case "Cancelled":
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
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 117, 237, 123),
      ),
      body: sales.isEmpty
          ? const Center(child: Text("No sales records available"))
          : ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                var sale = sales[index];
                return _buildOrderCard(sale);
              },
            ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> sale) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Name
            Text(
              sale['customer'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Order Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(sale['status']),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    sale['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // View Details Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(order: sale),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white, // Text color
                    backgroundColor: Colors.blue, // Button background
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text("View Details"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
