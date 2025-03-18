import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/vendor/order_details.dart';

class CustomerOrdersPage extends StatefulWidget {
  const CustomerOrdersPage({super.key});

  @override
  _CustomerOrdersPageState createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  bool _isLoading = true;
  String _activeFilter = "All"; // Default filter

  // Sample Data (Replace with actual data)
  final List<Map<String, dynamic>> completedOrders = [
    {
      'id': 1,
      'customer': 'John Doe',
      'status': 'Completed',
      'location': '123 Main Street',
      'items': [
        {'name': 'Burger', 'quantity': 2, 'price': 5.99},
        {'name': 'Fries', 'quantity': 1, 'price': 2.99},
      ],
      'totalPrice': 14.97,
      'orderPlaced': '2025-03-10 10:00',
      'dispatched': '2025-03-10 10:30',
      'delivered': '2025-03-10 11:00',
      'completed': '2025-03-10 11:15',
      'paymentMethod': 'Credit Card',
      'vendor': 'Burger Haven',
      'contact': '+94711234567',
    },
  ];

  final List<Map<String, dynamic>> cancelledOrders = [
    {
      'id': 2,
      'customer': 'Alice Brown',
      'status': 'Cancelled',
      'location': '456 Elm Street',
      'items': [
        {'name': 'Pizza', 'quantity': 1, 'price': 8.99},
      ],
      'totalPrice': 8.99,
      'orderPlaced': '2025-03-09 14:00',
      'cancelled': '2025-03-09 14:30',
      'paymentMethod': 'Cash on Delivery',
      'vendor': 'Pizza Palace',
      'contact': '+94778765432',
    },
  ];

  // Combined list for stats
  List<Map<String, dynamic>> get allOrders => [
        ...completedOrders,
        ...cancelledOrders,
      ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Simulate loading delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  // Apply filter to orders list
  void _applyFilter(String filter) {
    setState(() {
      _activeFilter = filter;
    });
  }

  // Get counts for summary stats
  Map<String, int> getStatusCounts() {
    int completed = completedOrders.length;
    int cancelled = cancelledOrders.length;

    return {'completed': completed, 'cancelled': cancelled};
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusCounts = getStatusCounts();

    return Scaffold(
      backgroundColor: Colors.grey[100], // Softer background
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 117, 237, 123),
        elevation: 0, // No shadow
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 117, 237, 123),
                const Color.fromARGB(255, 100, 200, 100),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle text
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        "Track and manage your food orders",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  // Summary Stats
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          statusCounts['completed']?.toString() ?? '0',
                          'Completed',
                          Colors.green,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey[200],
                        ),
                        _buildStatItem(
                          statusCounts['cancelled']?.toString() ?? '0',
                          'Cancelled',
                          Colors.red,
                        ),
                      ],
                    ),
                  ),

                  // Filter Buttons (same as VendorSalesPage)
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip("All"),
                          const SizedBox(width: 10),
                          _buildFilterChip("Completed"),
                          const SizedBox(width: 10),
                          _buildFilterChip("Cancelled"),
                        ],
                      ),
                    ),
                  ),

                  // Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    child: Text(
                      _activeFilter == "All"
                          ? "All Orders"
                          : "$_activeFilter Orders",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Order List
                  _activeFilter == "All"
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: allOrders.length,
                          itemBuilder: (context, index) {
                            return _buildOrderCard(allOrders[index]);
                          },
                        )
                      : _activeFilter == "Completed"
                          ? completedOrders.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: Text(
                                      "No completed orders found",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: completedOrders.length,
                                  itemBuilder: (context, index) {
                                    return _buildOrderCard(
                                        completedOrders[index]);
                                  },
                                )
                          : cancelledOrders.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: Text(
                                      "No cancelled orders found",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: cancelledOrders.length,
                                  itemBuilder: (context, index) {
                                    return _buildOrderCard(
                                        cancelledOrders[index]);
                                  },
                                ),
                ],
              ),
            ),
    );
  }

  // Build a status count widget
  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // Build filter chip
  Widget _buildFilterChip(String filter) {
    final bool isActive = _activeFilter == filter;
    return InkWell(
      onTap: () => _applyFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.green : Colors.grey[300]!,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[700],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Build order card
  Widget _buildOrderCard(Map<String, dynamic> order) {
    // Get the first item from the order
    final firstItem = order['items'][0];
    final itemText = "${firstItem['quantity']}x ${firstItem['name']}";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(color: getStatusColor(order['status']), width: 5),
        ),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer name and order ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['vendor'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "#${order['id']}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Order items
            Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.green,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(itemText, style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 8),

            // Location
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order['location'],
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Price
            Text(
              "\$${order['totalPrice'].toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            // Status and view details
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(order['status']),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order['status'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsPage(order: order),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text("View Details"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
