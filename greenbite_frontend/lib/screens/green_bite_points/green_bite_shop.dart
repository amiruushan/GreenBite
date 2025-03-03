import 'package:flutter/material.dart';
import 'package:greenbite_frontend/service/auth_service';

import 'package:http/http.dart' as http;
import 'dart:convert';

class GreenBiteShopScreen extends StatefulWidget {
  @override
  _GreenBiteShopScreenState createState() => _GreenBiteShopScreenState();
}

class _GreenBiteShopScreenState extends State<GreenBiteShopScreen> {
  int greenBitePoints = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPoints();
  }

  Future<void> _fetchPoints() async {
    setState(() {
      isLoading = true;
    });

    try {
      int? userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.2:8080/api/user/points?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          greenBitePoints = data['greenBitePoints'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch points: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching points: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _purchaseDeal(String dealName, int cost) async {
    if (greenBitePoints < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Not enough points!")),
      );
      return;
    }

    try {
      int? userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final response = await http.post(
        Uri.parse('http://192.168.1.2:8080/api/user/purchase-deal'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "dealName": dealName,
          "cost": cost,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          greenBitePoints -= cost;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Deal purchased successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to purchase deal: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error purchasing deal: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Green Bite Shop"),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchPoints,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildDealItem("5 GBP - \$5 Discount Code", Icons.local_offer,
                      Colors.blue, 5),
                  _buildDealItem("10 GBP - \$10 Keells Gift Card",
                      Icons.card_giftcard, Colors.orange, 10),
                  _buildDealItem("15 GBP - Amazon Gift Card",
                      Icons.shopping_bag, Colors.purple, 15),
                  _buildDealItem("20 GBP - Free Meal Voucher", Icons.fastfood,
                      Colors.red, 20),
                ],
              ),
            ),
    );
  }

  Widget _buildDealItem(String title, IconData icon, Color color, int cost) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 40, color: color),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ElevatedButton(
              onPressed: () => _purchaseDeal(title, cost),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("Purchase for $cost GBP"),
            ),
          ],
        ),
      ),
    );
  }
}
