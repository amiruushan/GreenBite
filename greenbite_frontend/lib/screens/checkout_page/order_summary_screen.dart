import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:greenbite_frontend/screens/cart/cart_provider.dart';
import 'package:provider/provider.dart';

class OrderSummaryPage extends StatefulWidget {
  final String orderId;
  final String orderTime;
  final double total;
  final int npEarned;
  final String status;
  final double latitude; // User's latitude
  final double longitude; // User's longitude
  final String paymentMethod;

  const OrderSummaryPage({
    Key? key,
    required this.orderId,
    required this.orderTime,
    required this.total,
    required this.npEarned,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  _OrderSummaryPageState createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  String _location = "Loading location...";

  @override
  void initState() {
    super.initState();
    _getAddressFromLatLng(
        widget.latitude, widget.longitude); // Fetch the address
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      setState(() {
        _location = "${place.street}, ${place.locality}, ${place.country}";
      });
    } catch (e) {
      setState(() {
        _location = "Unknown Location";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Summary",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildOrderSummaryCard(theme),
            const SizedBox(height: 20),
            _buildOrderDetails(theme),
            const SizedBox(height: 20),
            _buildStatusSection(theme),
            const SizedBox(height: 20),
            _buildBackToHomeButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color:
          theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Summary",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 10),
            _buildSummaryRow("Order ID", widget.orderId, theme),
            _buildSummaryRow("Order Time", widget.orderTime, theme),
            _buildSummaryRow(
                "Total", " Rs. ${widget.total.toStringAsFixed(2)}", theme),
            _buildSummaryRow("NP Earned", "${widget.npEarned} NP", theme),
            _buildSummaryRow(
                "Location", _location, theme), // Display geocoded address
            _buildSummaryRow("Payment Method", widget.paymentMethod, theme),
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
      color:
          theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
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
            _buildOrderItemsList(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsList(ThemeData theme) {
    final cartProvider = Provider.of<CartProvider>(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cartProvider.cartItems.length,
      itemBuilder: (context, index) {
        final item = cartProvider.cartItems[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.photo,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          subtitle: Text(
            "Rs. ${item.price.toStringAsFixed(2)} x ${item.quantity}",
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusSection(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color:
          theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
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
              widget.status,
              style: TextStyle(
                fontSize: 18,
                color: widget.status == "Confirmed" ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackToHomeButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Back to Home",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onBackground,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}
