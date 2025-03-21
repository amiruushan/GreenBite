import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VendorManagement extends StatefulWidget {
  const VendorManagement({Key? key}) : super(key: key);

  @override
  _VendorManagementState createState() => _VendorManagementState();
}

class _VendorManagementState extends State<VendorManagement> {
  // List to store vendors fetched from the backend
  List<Map<String, dynamic>> _vendors = [];
  String _searchQuery = '';
  int _entriesPerPage = 10;

  @override
  void initState() {
    super.initState();
    // Fetch vendors from the backend when the widget is initialized
    _fetchVendors();
  }

  // Function to fetch vendors from the backend
  Future<void> _fetchVendors() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8080/api/admin/listFoodShops'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('Fetched vendors: $data'); // Debug log
      setState(() {
        _vendors = data.cast<Map<String, dynamic>>();
      });
    } else {
      print('Failed to load vendors: ${response.statusCode}'); // Debug log
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredVendors = _vendors.where((vendor) {
      final businessName = vendor['businessName']?.toLowerCase() ?? '';
      final email = vendor['email']?.toLowerCase() ?? '';
      final contactName = vendor['contactName']?.toLowerCase() ?? '';

      return businessName.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase()) ||
          contactName.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Management"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchAndEntriesRow(),
            const SizedBox(height: 16),
            Expanded(child: _buildVendorTable(filteredVendors)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.store, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Text(
              "Vendor List",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700),
            ),
          ],
        ),
        const Text("Welcome!", style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildSearchAndEntriesRow() {
    return Row(
      children: [
        DropdownButton<int>(
          value: _entriesPerPage,
          items: [10, 25, 50]
              .map((value) =>
                  DropdownMenuItem(value: value, child: Text("$value entries")))
              .toList(),
          onChanged: (value) => setState(() => _entriesPerPage = value ?? 10),
        ),
        const Spacer(),
        SizedBox(
          width: 200,
          child: TextField(
            onChanged: (query) => setState(() => _searchQuery = query),
            decoration: InputDecoration(
              hintText: 'Search...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorTable(List<Map<String, dynamic>> vendors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
        columns: const [
          DataColumn(label: Text("SL")),
          DataColumn(label: Text("Business Name")),
          DataColumn(label: Text("Contact Name")),
          DataColumn(label: Text("Email")),
          DataColumn(label: Text("Mobile")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Created")),
          DataColumn(label: Text("Actions")),
        ],
        rows: vendors
            .take(_entriesPerPage)
            .map((vendor) => _buildDataRow(vendor))
            .toList(),
      ),
    );
  }

  DataRow _buildDataRow(Map<String, dynamic> vendor) {
    return DataRow(cells: [
      DataCell(Text(vendor['id'].toString())),
      DataCell(Text(vendor['businessName'] ?? 'N/A')),
      DataCell(Text(vendor['contactName'] ?? 'N/A')),
      DataCell(Text(vendor['email'] ?? 'N/A')),
      DataCell(Text(vendor['mobile'] ?? 'N/A')),
      DataCell(_buildStatusBadge(vendor['status'] ?? 'N/A')),
      DataCell(Text(vendor['created'] ?? 'N/A')),
      DataCell(_buildActionButtons(vendor)),
    ]);
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status == 'Active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: isActive ? Colors.green.shade100 : Colors.red.shade100,
          borderRadius: BorderRadius.circular(4)),
      child: Text(status,
          style: TextStyle(
              color: isActive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12)),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> vendor) {
    return Row(
      children: [
        IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(vendor)),
        IconButton(
            icon: const Icon(Icons.block),
            onPressed: () => _toggleVendorStatus(vendor)),
      ],
    );
  }

  void _confirmDelete(Map<String, dynamic> vendor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text(
            "Are you sure you want to delete this vendor? This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () async {
                // Call the API to delete the vendor
                final success = await _deleteVendor(vendor['id']);
                if (success) {
                  // Remove the vendor from the local list if the API call is successful
                  setState(() {
                    _vendors.removeWhere((v) => v['id'] == vendor['id']);
                  });
                }
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Delete"))
        ],
      ),
    );
  }

  // Function to delete a vendor via the API
  Future<bool> _deleteVendor(int foodShopId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8080/api/admin/deleteFoodShop/$foodShopId'),
      );

      if (response.statusCode == 200) {
        // Vendor deleted successfully
        print('Vendor deleted successfully');
        return true;
      } else {
        // Handle errors
        print('Failed to delete vendor: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., network errors)
      print('Error deleting vendor: $e');
      return false;
    }
  }

  void _toggleVendorStatus(Map<String, dynamic> vendor) {
    setState(() {
      final index = _vendors.indexWhere((v) => v['id'] == vendor['id']);
      if (index != -1) {
        final isActive = _vendors[index]['status'] == 'Active';
        _vendors[index]['status'] = isActive ? 'Inactive' : 'Active';
      }
    });
  }
}
