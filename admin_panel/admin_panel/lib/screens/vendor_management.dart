import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/common_layout.dart'; // Import the CommonLayout

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
      Uri.parse('http://10.190.13.69:8080/api/admin/listFoodShops'),
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
      final name = vendor['name']?.toString().toLowerCase() ?? '';
      final address = vendor['address']?.toString().toLowerCase() ?? '';
      final email = vendor['email']?.toString().toLowerCase() ?? '';
      final businessDescription =
          vendor['businessDescription']?.toString().toLowerCase() ?? '';

      return name.contains(_searchQuery.toLowerCase()) ||
          address.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase()) ||
          businessDescription.contains(_searchQuery.toLowerCase());
    }).toList();

    return CommonLayout(
      title: 'Vendor Management', // Title for the TopNavBar
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: TextEditingController(text: _searchQuery),
              decoration: InputDecoration(
                labelText: 'Search by Name, Address, or Email',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      // Trigger search when the search icon is pressed
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          Expanded(
            child: filteredVendors.isEmpty
                ? Center(
              child: Text("No vendors found."),
            )
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text('Shop ID')),
                  DataColumn(label: Text('Profile Photo')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Business Description')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: filteredVendors
                    .take(_entriesPerPage)
                    .map((vendor) => _buildDataRow(vendor))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(Map<String, dynamic> vendor) {
    return DataRow(cells: [
      DataCell(Text(vendor['shopId'].toString())), // Shop ID is guaranteed to be non-null
      DataCell(
        vendor['photo'] != null && vendor['photo'].isNotEmpty
            ? CircleAvatar(
          backgroundImage: NetworkImage(vendor['photo']),
        )
            : Text("No photo"), // Handle null or empty photo
      ),
      DataCell(Text(vendor['name']?.toString() ?? "N/A")), // Handle null name
      DataCell(Text(vendor['address']?.toString() ?? "N/A")), // Handle null address
      DataCell(Text(vendor['email']?.toString() ?? "N/A")), // Handle null email
      DataCell(Text(vendor['businessDescription']?.toString() ?? "N/A")), // Handle null businessDescription
      DataCell(_buildActionButtons(vendor)),
    ]);
  }

  Widget _buildActionButtons(Map<String, dynamic> vendor) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDelete(vendor),
        ),
        IconButton(
          icon: Icon(Icons.block, color: Colors.orange),
          onPressed: () => _toggleVendorStatus(vendor),
        ),
      ],
    );
  }

  void _confirmDelete(Map<String, dynamic> vendor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text(
            "Are you sure you want to delete this vendor? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.green)),
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
              backgroundColor: Colors.green,
            ),
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  // Function to delete a vendor via the API
  Future<bool> _deleteVendor(int shopId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.190.13.69:8080/api/admin/deleteFoodShop/$shopId'),
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
    print("Toggle status for vendor: ${vendor['name'] ?? 'N/A'}");
  }
}