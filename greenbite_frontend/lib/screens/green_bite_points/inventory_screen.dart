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
        Uri.parse('http://192.168.1.3:8080/api/user/inventory/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawData = jsonDecode(response.body);
        setState(() {
          inventoryItems = rawData
              .map((item) => {
                    "deal_name":
                        item["deal_name"] ?? "Unknown Deal", // ✅ Default value
                    "coupon_code": item["coupon_code"] ??
                        "UNKNOWN_CODE", // ✅ Default value
                    "redeemed": item["redeemed"] ??
                        false, // ✅ Ensure boolean default value
                  })
              .toList();
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

  Future<void> _redeemCoupon(String couponCode) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.3:8080/api/user/inventory/redeem-coupon'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"couponCode": couponCode}), // ✅ Send as JSON
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Coupon $couponCode redeemed!")),
        );

        // ✅ Update the UI after redeeming
        setState(() {
          inventoryItems = inventoryItems.map((item) {
            if (item['coupon_code'] == couponCode) {
              return {...item, 'redeemed': true}; // ✅ Mark as redeemed
            }
            return item;
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to redeem coupon: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error redeeming coupon: $e")),
      );
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
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // ✅ Copy Coupon Code to Clipboard
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Copied: ${item['coupon_code']}"),
                                          ),
                                        );
                                      },
                                      child: Text("Copy"),
                                    ),
                                    SizedBox(width: 8), // Spacing
                                    ElevatedButton(
                                      onPressed: () {
                                        _redeemCoupon(item[
                                            'coupon_code']); // ✅ Call redeem function
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      child: Text("Redeem"),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ));
  }
}
