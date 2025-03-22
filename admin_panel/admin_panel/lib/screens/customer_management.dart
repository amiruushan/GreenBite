import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      Uri.parse('http://127.0.0.1:8080/api/admin/listUsers'),
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
      return user['username']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          user['email'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Management"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchAndEntriesRow(),
            const SizedBox(height: 16),
            Expanded(child: _buildUserTable(filteredUsers)),
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
            Icon(Icons.people, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Text(
              "User List",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700),
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

  Widget _buildUserTable(List<Map<String, dynamic>> users) {
    return SingleChildScrollView(
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
        rows: users
            .take(_entriesPerPage)
            .map((user) => _buildDataRow(user))
            .toList(),
      ),
    );
  }

  DataRow _buildDataRow(Map<String, dynamic> user) {
    return DataRow(cells: [
      DataCell(Text(user['id'].toString())),
      DataCell(Text(user['username'])),
      DataCell(Text(user['email'])),
      DataCell(Text(user['phoneNumber'])),
      DataCell(Text(user['address'])),
      DataCell(_buildActionButtons(user)),
    ]);
  }

  Widget _buildActionButtons(Map<String, dynamic> user) {
    return Row(
      children: [
        IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(user)),
        IconButton(
            icon: const Icon(Icons.block),
            onPressed: () => _toggleUserStatus(user)),
      ],
    );
  }

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text(
            "Are you sure you want to delete this user? This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
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
              child: const Text("Delete"))
        ],
      ),
    );
  }

  // Function to delete a user via the API
  Future<bool> _deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8080/api/admin/deleteUser/$userId'),
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
    print("Toggle status for user: ${user['username']}");
  }
}
