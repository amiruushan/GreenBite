import 'package:flutter/material.dart';
import 'package:greenbite_frontend/service/auth_service';

import 'package:http/http.dart' as http;
import 'dart:convert';

class InventoryScreen extends StatefulWidget {
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

  Future<void> _fetchInventory() async {
    setState(() {
      isLoading = true;
    });

    try {
      int? userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User ID not found');

      final response = await http.get(
        Uri.parse('http://192.168.1.2:8080/api/user/inventory?userId=$userId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          inventoryItems = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to fetch inventory: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching inventory: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Inventory"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : inventoryItems.isEmpty
              ? Center(child: Text("No items in inventory"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: inventoryItems.length,
                  itemBuilder: (context, index) {
                    final item = inventoryItems[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(item['deal_name']),
                        subtitle: Text("Code: ${item['coupon_code']}"),
                        trailing: item['redeemed']
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : ElevatedButton(
                                onPressed: () {
                                  // Copy coupon code to clipboard
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Copied: ${item['coupon_code']}"),
                                    ),
                                  );
                                },
                                child: Text("Copy Code"),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
