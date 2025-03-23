import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/common_layout.dart'; // Import the CommonLayout

class CustomerManagement extends StatefulWidget {
  const CustomerManagement({Key? key}) : super(key: key);

  @override
  _CustomerManagementState createState() => _CustomerManagementState();
}

class _CustomerManagementState extends State<CustomerManagement> {
  // List to store users fetched from the backend
  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';
  int _entriesPerPage = 10;

  @override
  void initState() {
    super.initState();
    // Fetch users from the backend when the widget is initialized
    _fetchUsers();
  }

  // Function to fetch users from the backend
  Future<void> _fetchUsers() async {
    final response = await http.get(
      Uri.parse('http://10.190.13.69:8080/api/admin/listUsers'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('Fetched users: $data'); // Debug log
      setState(() {
        _users = data.cast<Map<String, dynamic>>();
      });
    } else {
      print('Failed to load users: ${response.statusCode}'); // Debug log
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _users.where((user) {
      final username = user['username']?.toString().toLowerCase() ?? '';
      final email = user['email']?.toString().toLowerCase() ?? '';
      return username.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase());
    }).toList();

    return CommonLayout(
      title: 'Customer Management', // Title for the TopNavBar
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: TextEditingController(text: _searchQuery),
              decoration: InputDecoration(
                labelText: 'Search by Username or Email',
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
            child: filteredUsers.isEmpty
                ? Center(
              child: Text("No users found."),
            )
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text("ID")),
                  DataColumn(label: Text("Username")),
                  DataColumn(label: Text("Email")),
                  DataColumn(label: Text("Phone Number")),
                  DataColumn(label: Text("Address")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: filteredUsers
                    .take(_entriesPerPage)
                    .map((user) => _buildDataRow(user))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(Map<String, dynamic> user) {
    return DataRow(cells: [
      DataCell(Text(user['id'].toString())), // ID is guaranteed to be non-null
      DataCell(Text(user['username']?.toString() ?? "N/A")), // Handle null username
      DataCell(Text(user['email']?.toString() ?? "N/A")), // Handle null email
      DataCell(Text(user['phoneNumber']?.toString() ?? "N/A")), // Handle null phoneNumber
      DataCell(Text(user['address']?.toString() ?? "N/A")), // Handle null address
      DataCell(_buildActionButtons(user)),
    ]);
  }

  Widget _buildActionButtons(Map<String, dynamic> user) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDelete(user),
        ),
        IconButton(
          icon: Icon(Icons.block, color: Colors.orange),
          onPressed: () => _toggleUserStatus(user),
        ),
      ],
    );
  }

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text(
            "Are you sure you want to delete this user? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            onPressed: () async {
              // Call the API to delete the user
              final success = await _deleteUser(user['id']);
              if (success) {
                // Remove the user from the local list if the API call is successful
                setState(() {
                  _users.removeWhere((u) => u['id'] == user['id']);
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

  // Function to delete a user via the API
  Future<bool> _deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.190.13.69:8080/api/admin/deleteUser/$userId'),
      );

      if (response.statusCode == 200) {
        // User deleted successfully
        print('User deleted successfully');
        return true;
      } else {
        // Handle errors
        print('Failed to delete user: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Handle exceptions (e.g., network errors)
      print('Error deleting user: $e');
      return false;
    }
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    // Since the backend response does not include a "status" field,
    // this function can be updated to send a request to the backend
    // to toggle the user's status (e.g., active/inactive).
    print("Toggle status for user: ${user['username'] ?? 'N/A'}");
  }
}