import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  double totalSales = 0.0;
  List<Map<String, dynamic>> shops = [];
  bool isLoading = true;
  String selectedFilter = "Last 24 Hours";
  Map<String, dynamic>? selectedShop;

  @override
  void initState() {
    super.initState();
    _fetchTotalSales();
    _fetchShops();
  }

  Future<void> _fetchTotalSales() async {
    final (startDate, endDate) = _getDateRange(selectedFilter);
    final url = Uri.parse(
        "http://127.0.0.1:8080/api/sales/total-all?startDate=$startDate&endDate=$endDate");

    try {
      final response = await http.get(url);
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      print("Response headers: ${response.headers}");

      if (response.statusCode == 200) {
        // Parse the response as a double
        final totalSalesValue = double.tryParse(response.body.trim()) ?? 0.0;
        print("Parsed total sales: $totalSalesValue");

        setState(() {
          totalSales = totalSalesValue;
        });
      } else {
        print("Failed to fetch total sales: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching total sales: $e");
    }
  }

  Future<void> _fetchShops() async {
    final url = Uri.parse("http://127.0.0.1:8080/api/admin/listUsers");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          shops = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        print("Failed to fetch shops: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching shops: $e");
    }
  }

  Future<void> _fetchShopSales(String shopId) async {
    final (startDate, endDate) = _getDateRange(selectedFilter);
    final url = Uri.parse("http://127.0.0.1:8080/api/sales/total");
    final body = jsonEncode({
      "shopId": shopId,
      "startDate": startDate,
      "endDate": endDate,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      if (response.statusCode == 200) {
        final totalSalesValue = double.tryParse(response.body.trim()) ?? 0.0;
        setState(() {
          selectedShop = {
            "id": shopId,
            "totalSales": totalSalesValue,
          };
        });
      } else {
        print("Failed to fetch shop sales: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching shop sales: $e");
    }
  }

  (String, String) _getDateRange(String filter) {
    final now = DateTime.now();
    switch (filter) {
      case "Last 24 Hours":
        final startDate = now.subtract(const Duration(days: 1));
        return (startDate.toIso8601String(), now.toIso8601String());
      case "Last 7 Days":
        final startDate = now.subtract(const Duration(days: 7));
        return (startDate.toIso8601String(), now.toIso8601String());
      case "Last 30 Days":
        final startDate = now.subtract(const Duration(days: 30));
        return (startDate.toIso8601String(), now.toIso8601String());
      default:
        return (now.toIso8601String(), now.toIso8601String());
    }
  }

  void _onFilterChanged(String? value) {
    if (value != null) {
      setState(() {
        selectedFilter = value;
      });
      if (selectedShop == null) {
        _fetchTotalSales();
      } else {
        _fetchShopSales(selectedShop!['id']);
      }
    }
  }

  void _onShopSelected(Map<String, dynamic> shop) {
    setState(() {
      selectedShop = shop;
    });
    _fetchShopSales(shop['id']);
  }

  void _goBack() {
    setState(() {
      selectedShop = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Overview"),
        actions: [
          DropdownButton<String>(
            value: selectedFilter,
            items: const [
              DropdownMenuItem(
                  value: "Last 24 Hours", child: Text("Last 24 Hours")),
              DropdownMenuItem(
                  value: "Last 7 Days", child: Text("Last 7 Days")),
              DropdownMenuItem(
                  value: "Last 30 Days", child: Text("Last 30 Days")),
            ],
            onChanged: _onFilterChanged,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : selectedShop == null
              ? _buildMainScreen()
              : _buildShopSalesScreen(),
    );
  }

  Widget _buildMainScreen() {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Total Sales",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "\$${totalSales.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 24, color: Colors.green),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Shops",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shops.length,
            itemBuilder: (context, index) {
              final shop = shops[index];
              return Card(
                child: ListTile(
                  title: Text(shop['name'] ?? "Unknown Shop"),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => _onShopSelected(shop),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShopSalesScreen() {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Shop Sales",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "\$${selectedShop!['totalSales'].toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 24, color: Colors.green),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "Sales Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Add sales details here (e.g., a list of sales)
            ],
          ),
        ),
        ElevatedButton(
          onPressed: _goBack,
          child: const Text("Back to Shops"),
        ),
      ],
    );
  }
}