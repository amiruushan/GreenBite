import 'package:flutter/material.dart';

class ManageUsersScreen extends StatefulWidget {
  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  // For now, we'll mock a list of users with demo data
  final List<Map<String, dynamic>> _users = [
    {
      "id": 1,
      "username": "john_doe",
      "email": "john@example.com",
      "firstName": "John",
      "surname": "Doe",
      "district": "Colombo",
      "address": "123 Street, Colombo",
      "role": "Customer",
    }
  ];

  // The selected user (for expanding to show details)
  Map<String, dynamic>? _selectedUser;

  // Mock function for updating user info
  void _updateUser(Map<String, dynamic> user) {
    // Add logic here to update the user (via API call, etc.)
    print("Updating user: ${user['username']}");
  }

  // Mock function for banning a user
  void _banUser(Map<String, dynamic> user) {
    // Add logic here to ban the user (via API call, etc.)
    print("Banning user: ${user['username']}");
  }

  // Mock function for deleting a user
  void _deleteUser(Map<String, dynamic> user) {
    // Add logic here to delete the user (via API call, etc.)
    setState(() {
      _users.remove(user);
      if (_selectedUser == user) {
        _selectedUser = null; // Collapse the user details after deletion
      }
    });
    print("Deleted user: ${user['username']}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Users"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Normal Customers",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedUser == user) {
                          _selectedUser = null; // Collapse the user details
                        } else {
                          _selectedUser = user; // Expand the user details
                        }
                      });
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  user["username"],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  _selectedUser == user
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                            if (_selectedUser == user) ...[
                              SizedBox(height: 10),
                              Text("Email: ${user["email"]}"),
                              Text("First Name: ${user["firstName"]}"),
                              Text("Surname: ${user["surname"]}"),
                              Text("District: ${user["district"]}"),
                              Text("Address: ${user["address"]}"),
                              Text("Role: ${user["role"]}"),
                              SizedBox(height: 10),

                              // Action Buttons for Admin
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _updateUser(user),
                                    child: Text("Update User"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _banUser(user),
                                    child: Text("Ban User"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _deleteUser(user),
                                    child: Text("Delete User"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
