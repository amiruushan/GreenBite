import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VendorManagement extends StatefulWidget {
  const VendorManagement({super.key});

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
      final name = vendor['name']?.toLowerCase() ?? '';
      final address = vendor['address']?.toLowerCase() ?? '';
      final email = vendor['email']?.toLowerCase() ?? '';
      final businessDescription =
          vendor['businessDescription']?.toLowerCase() ?? '';

      return name.contains(_searchQuery.toLowerCase()) ||
          address.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase()) ||
          businessDescription.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Management"),
        backgroundColor: const Color(0xFF87F031), // Green color
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
            Icon(Icons.store, color: const Color(0xFF87F031)), // Green color
            const SizedBox(width: 8),
            Text(
              "Vendor List",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF87F031)), // Green color
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
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
        columns: const [
          DataColumn(label: Text("Shop ID")),
          DataColumn(label: Text("Profile Photo")),
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Address")),
          DataColumn(label: Text("Email")),
          DataColumn(label: Text("Business Description")),
          DataColumn(label: Text("Actions")), // Add Actions column
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
      DataCell(Text(vendor['shopId'].toString())),
      DataCell(
        CircleAvatar(
          backgroundImage: NetworkImage(vendor['photo'] ?? ''),
        ),
      ),
      DataCell(Text(vendor['name'] ?? 'N/A')),
      DataCell(Text(vendor['address'] ?? 'N/A')),
      DataCell(Text(vendor['email'] ?? 'N/A')),
      DataCell(Text(vendor['businessDescription'] ?? 'N/A')),
      DataCell(_buildActionButtons(vendor)), // Add action buttons
    ]);
  }

  Widget _buildActionButtons(Map<String, dynamic> vendor) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.delete,
              color: Color(0xFF87F031)), // Green color
          onPressed: () => _confirmDelete(vendor),
        ),
        IconButton(
          icon: const Icon(Icons.block,
              color: Color(0xFF87F031)), // Green color
          onPressed: () => _toggleVendorStatus(vendor),
        ),
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
            child: const Text("Cancel",
                style:
                    TextStyle(color: Color(0xFF87F031))), // Green color
          ),
          ElevatedButton(
            onPressed: () async {
              // Call the API to delete the vendor
              final success = await _deleteVendor(vendor['shopId']);
              if (success) {
                // Remove the vendor from the local list if the API call is successful
                setState(() {
                  _vendors.removeWhere((v) => v['shopId'] == vendor['shopId']);
                });
              }
              Navigator.pop(context); // Close the dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF87F031), // Green color
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // Function to delete a vendor via the API
  Future<bool> _deleteVendor(int shopId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8080/api/admin/deleteFoodShop/$shopId'),
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
    // Since the backend response does not include a "status" field,
    // this function can be updated to send a request to the backend
    // to toggle the vendor's status (e.g., active/inactive).
    print("Toggle status for vendor: ${vendor['name']}");
  }
}
