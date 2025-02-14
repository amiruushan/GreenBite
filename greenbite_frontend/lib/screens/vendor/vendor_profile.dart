import 'package:flutter/material.dart';
import '../../widgets/vendor_nav_bar.dart';
import 'vendor_home.dart';
import 'list_food.dart';
import 'orders.dart';

class VendorProfile extends StatefulWidget {
  const VendorProfile({super.key});

  @override
  State<VendorProfile> createState() => _VendorProfileState();
}

class _VendorProfileState extends State<VendorProfile> {
  final int _selectedIndex = 3; // Set to 3 for Profile screen

  // Dummy vendor profile data
  final Map<String, dynamic> _vendorProfile = {
    "profilePictureUrl":
    "https://lh3.googleusercontent.com/p/AF1QipOv6Va9c7dh1Tml4WiUHs2o5PO0jKF6vZlvLk_U=s680-w680-h510",
    "username": "Street Za",
    "email": "streetza@example.com",
    "phoneNumber": "+1 123 456 7890",
    "address": "123 Green Street, Organic City",
    "businessName": "Street Za Organic Foods",
    "businessDescription": "Best organic and fresh produce in town.",
  };

  // Function to handle navigation
  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VendorHome()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ListFood()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Orders()),
      );
    }
  }

  // ✅ Navigate to Edit Screen (Placeholder)
  Future<void> _editProfile() async {
    print("Edit profile clicked"); // TODO: Implement edit profile logic
  }

  // ✅ Sign Out (Placeholder)
  void _signOut() {
    print("Vendor signed out"); // TODO: Implement real sign-out logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signed out successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 117, 237, 123),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(_vendorProfile["profilePictureUrl"]),
            ),
            const SizedBox(height: 16),

            // Vendor Name
            Text(
              _vendorProfile["username"],
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Email
            Text(
              _vendorProfile["email"],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Business Name
            _buildInfoCard(
                Icons.business, "Business Name", _vendorProfile["businessName"]),
            // Business Description
            _buildInfoCard(Icons.description, "Business Description",
                _vendorProfile["businessDescription"]),
            // Phone Number
            _buildInfoCard(
                Icons.phone, "Phone", _vendorProfile["phoneNumber"]),
            // Address
            _buildInfoCard(
                Icons.location_on, "Address", _vendorProfile["address"]),

            const SizedBox(height: 20),

            // Edit Profile Button
            _buildActionButton(
              icon: Icons.edit,
              text: "Edit Profile",
              color: Colors.blue,
              onPressed: _editProfile,
            ),

            const SizedBox(height: 20),

            // Sign Out Button
            _buildActionButton(
              icon: Icons.logout,
              text: "Sign Out",
              color: Colors.red,
              onPressed: _signOut,
            ),
          ],
        ),
      ),
      bottomNavigationBar: VendorNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Widget to display vendor info
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  // Widget to display buttons
  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text,
            style: const TextStyle(fontSize: 18, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: color,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}