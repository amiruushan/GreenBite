import 'package:flutter/material.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<dynamic> inventoryItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<Map<String, String>> _getHeaders() async {
    String? token = await AuthService.getToken();
    if (token == null) throw Exception("No JWT token found.");
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<void> _fetchInventory() async {
    setState(() => isLoading = true);

    try {
      int? userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User ID not found');

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/user/inventory/$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawData = jsonDecode(response.body);

        setState(() {
          inventoryItems = rawData
              .map((item) => {
                    "deal_name": item["deal_name"] ?? "Unknown Deal",
                    "coupon_code": item["coupon_code"] ?? "UNKNOWN_CODE",
                    "redeemed": item["redeemed"] ?? false,
                    "icon": item["icon"] ?? "local_offer",
                    "color": item["color"] ?? "green",
                  })
              .toList()
              .reversed
              .toList(); // ✅ Most recent coupons appear at the top
        });
      } else {
        _showSnackBar("Failed to fetch inventory: ${response.body}");
      }
    } catch (e) {
      _showSnackBar("Error fetching inventory: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _redeemCoupon(String couponCode) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/user/inventory/redeem-coupon'),
        headers: await _getHeaders(),
        body: jsonEncode({"couponCode": couponCode}),
      );

      if (response.statusCode == 200) {
        _showSnackBar("Coupon $couponCode redeemed!");

        setState(() {
          inventoryItems = inventoryItems.map((item) {
            if (item['coupon_code'] == couponCode) {
              return {...item, 'redeemed': true};
            }
            return item;
          }).toList();
        });
      } else {
        _showSnackBar("Failed to redeem coupon: ${response.body}");
      }
    } catch (e) {
      _showSnackBar("Error redeeming coupon: $e");
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
          "My Inventory",
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
              Icons.refresh,
              color: theme.colorScheme.onSurface, // ✅ Action icons adapt
            ),
            onPressed: _fetchInventory,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary, // ✅ Theme-based color
              ),
            )
          : inventoryItems.isEmpty
              ? Center(
                  child: Text(
                    "No items in inventory",
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.onSurface, // ✅ Theme-based color
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: inventoryItems.length,
                  itemBuilder: (context, index) {
                    final item = inventoryItems[index];
                    return _buildInventoryItem(
                      item["deal_name"],
                      item["coupon_code"],
                      item["redeemed"],
                      item["icon"],
                      item["color"],
                    );
                  },
                ),
    );
  }

  Widget _buildInventoryItem(String dealName, String couponCode, bool redeemed,
      String icon, String color) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface, // ✅ Theme-based card background
      child: ListTile(
        leading: Icon(
          _getIcon(icon),
          color: _getColor(color),
          size: 30,
        ),
        title: Text(
          dealName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface, // ✅ Theme-based text color
          ),
        ),
        subtitle: Text(
          "Code: $couponCode",
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface
                .withOpacity(0.7), // ✅ Theme-based text color
          ),
        ),
        trailing: redeemed
            ? Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary, // ✅ Theme-based color
              )
            : ElevatedButton(
                onPressed: () => _redeemCoupon(couponCode),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.error, // ✅ Theme-based color
                ),
                child: Text(
                  "Redeem",
                  style: TextStyle(
                    color:
                        theme.colorScheme.onError, // ✅ Theme-based text color
                  ),
                ),
              ),
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
        return Icons.local_offer;
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
        return Colors.green;
    }
  }
}
