import 'package:flutter/material.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/service/auth_service';
import 'package:greenbite_frontend/screens/green_bite_points/inventory_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GreenBiteShopScreen extends StatefulWidget {
  const GreenBiteShopScreen({super.key});

  @override
  _GreenBiteShopScreenState createState() => _GreenBiteShopScreenState();
}

class _GreenBiteShopScreenState extends State<GreenBiteShopScreen> {
  int greenBitePoints = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> deals = [];

  @override
  void initState() {
    super.initState();
    _fetchPoints();
    _fetchDeals();
  }

  Future<Map<String, String>> _getHeaders() async {
    String? token = await AuthService.getToken();
    if (token == null) throw Exception("No JWT token found.");
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<void> _fetchPoints() async {
    setState(() => isLoading = true);
    try {
      int? userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User ID not found');

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/users/points?userId=$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          greenBitePoints = data['greenBitePoints'];
        });
      } else {
        _showSnackBar("Failed to fetch points: ${response.body}");
      }
    } catch (e) {
      _showSnackBar("Error fetching points: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchDeals() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/deals'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          deals = List<Map<String, dynamic>>.from(data);
        });
      } else {
        _showSnackBar("Failed to fetch deals: ${response.body}");
      }
    } catch (e) {
      _showSnackBar("Error fetching deals: $e");
    }
  }

  Future<void> _purchaseDeal(int dealId, String couponCode) async {
    int dealCost =
        deals.firstWhere((deal) => deal["id"] == dealId)["cost"] as int;

    if (greenBitePoints < dealCost) {
      _showSnackBar("Not enough points!");
      return;
    }

    try {
      int? userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User ID not found');

      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/user/inventory/purchase-deal'),
        headers: await _getHeaders(),
        body: jsonEncode(
            {"userId": userId, "couponId": dealId, "couponCode": couponCode}),
      );

      if (response.statusCode == 200) {
        setState(() {
          greenBitePoints -= dealCost;
        });
        _showSnackBar("Deal purchased successfully!");
        _fetchDeals();
      } else {
        _showSnackBar("Failed to purchase deal: ${response.body}");
      }
    } catch (e) {
      _showSnackBar("Error purchasing deal: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text("Green Bite Shop",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.inventory_2, color: Colors.white),
            tooltip: "My Inventory",
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => InventoryScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchPoints,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildPointsCard(),
                  SizedBox(height: 20),
                  _buildDealsGrid(),
                  SizedBox(height: 20),
                  _buildHowItWorksCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: _glassmorphismDecoration(),
      child: Column(
        children: [
          Text("Your Green Bite Points",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("$greenBitePoints GBP",
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case "local_offer":
        return Icons.local_offer;
      case "card_giftcard":
        return Icons.card_giftcard;
      case "shopping_bag":
        return Icons.shopping_bag;
      case "fastfood":
        return Icons.fastfood;
      default:
        return Icons.local_offer; // Default icon
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case "blue":
        return Colors.blue;
      case "orange":
        return Colors.orange;
      case "purple":
        return Colors.purple;
      case "red":
        return Colors.red;
      default:
        return Colors.green; // Default color
    }
  }

  Widget _buildDealsGrid() {
    return Expanded(
      child: GridView.builder(
        itemCount: deals.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final deal = deals[index];
          return _buildDealItem(
            deal["title"],
            _getIcon(deal["icon"]),
            _getColor(deal["color"]),
            deal["cost"],
            deal["id"],
            deal["discount"],
          );
        },
      ),
    );
  }

  Widget _buildDealItem(String title, IconData icon, Color color, int cost,
      int dealId, double discount) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 40, color: color),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text("Discount: \$$discount",
                style: TextStyle(fontSize: 12, color: Colors.green.shade700)),
            ElevatedButton(
              onPressed: () => _purchaseDeal(dealId, ""),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("Buy for $cost GBP"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: _glassmorphismDecoration(),
      child: Column(
        children: [
          Text("How It Works",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          SizedBox(height: 10),
          _buildBulletPoint("Earn GBP by making eco-friendly purchases"),
          _buildBulletPoint("Use GBP to buy exclusive deals & discounts"),
          _buildBulletPoint("Redeem your coupon at checkout"),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 18),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  BoxDecoration _glassmorphismDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withOpacity(0.9),
      boxShadow: [
        BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2)
      ],
    );
  }
}
