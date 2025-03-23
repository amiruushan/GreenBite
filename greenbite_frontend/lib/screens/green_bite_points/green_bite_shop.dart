import 'package:flutter/material.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // ✅ Theme-based background
      appBar: AppBar(
        title: Text(
          "Green Bite Shop",
          style: TextStyle(
            color: theme.colorScheme.onSurface, // ✅ Adaptive text color
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // ✅ Transparent AppBar
        elevation: 0, // ✅ Remove shadow
        iconTheme: IconThemeData(
          color: theme.colorScheme.onSurface, // ✅ Icons adapt to theme
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.inventory_2,
              color: theme.colorScheme.onSurface, // ✅ Action icons adapt
            ),
            tooltip: "My Inventory",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InventoryScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: theme.colorScheme.onSurface, // ✅ Action icons adapt
            ),
            onPressed: _fetchPoints,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary, // ✅ Theme-based color
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildPointsCard(theme),
                  const SizedBox(height: 20),
                  _buildDealsGrid(theme),
                  const SizedBox(height: 20),
                  _buildHowItWorksCard(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildPointsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassmorphismDecoration(theme),
      child: Column(
        children: [
          Text(
            "Your Green Bite Points",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface, // ✅ Adaptive text color
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$greenBitePoints GBP",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary, // ✅ Theme-based color
            ),
          ),
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

  Widget _buildDealsGrid(ThemeData theme) {
    return Expanded(
      child: GridView.builder(
        itemCount: deals.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
            theme,
          );
        },
      ),
    );
  }

  Widget _buildDealItem(String title, IconData icon, Color color, int cost,
      int dealId, double discount, ThemeData theme) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface, // ✅ Theme-based card color
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 40, color: color),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface, // ✅ Adaptive text color
              ),
            ),
            Text(
              "Discount: Rs. $discount",
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.primary, // ✅ Theme-based color
              ),
            ),
            ElevatedButton(
              onPressed: () => _purchaseDeal(dealId, ""),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    theme.colorScheme.primary, // ✅ Theme-based color
                foregroundColor:
                    theme.colorScheme.onPrimary, // ✅ Theme-based color
              ),
              child: Text("Buy for $cost GBP"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassmorphismDecoration(theme),
      child: Column(
        children: [
          Text(
            "How It Works",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary, // ✅ Theme-based color
            ),
          ),
          const SizedBox(height: 10),
          _buildBulletPoint("Earn GBP by making eco-friendly purchases", theme),
          _buildBulletPoint(
              "Use GBP to buy exclusive deals & discounts", theme),
          _buildBulletPoint("Redeem your coupon at checkout", theme),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.check_circle,
            color: theme.colorScheme.primary, size: 18), // ✅ Theme-based color
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface
                .withOpacity(0.7), // ✅ Adaptive text color
          ),
        ),
      ],
    );
  }

  BoxDecoration _glassmorphismDecoration(ThemeData theme) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.surface.withOpacity(0.6),
          theme.colorScheme.surface.withOpacity(0.3),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.primary.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    );
  }
}
