import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../../widgets/vendor_nav_bar.dart';
import 'vendor_home.dart';
import 'list_food.dart';
import 'orders.dart';
import 'edit_profile.dart'; // Import the EditProfile screen

class VendorProfile extends StatefulWidget {
  final int vendorId;

  const VendorProfile({super.key, required this.vendorId});

  @override
  State<VendorProfile> createState() => _VendorProfileState();
}

class _VendorProfileState extends State<VendorProfile> {
  final int _selectedIndex = 3; // Set to 3 for Profile screen
  Map<String, dynamic> _vendorProfile = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVendorProfile();
  }

  // Fetch vendor profile data from backend
  Future<void> _fetchVendorProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/shop/${widget.vendorId}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _vendorProfile = {
            "profilePictureUrl": data["photo"] ?? "",
            "username": data["name"] ?? "Unknown Vendor",
            "email": data["email"] ?? "",
            "phoneNumber": data["phoneNumber"] ?? "",
            "address": data["address"] ?? "",
            "businessName": data["businessName"] ?? "",
            "businessDescription": data["businessDescription"] ?? "",
          };
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load vendor profile");
      }
    } catch (e) {
      print("Error fetching vendor profile: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  // ✅ Navigate to Edit Profile Screen
  Future<void> _editProfile() async {
    final updatedProfile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(
          vendorProfile: _vendorProfile,
          vendorId: widget.vendorId,
        ),
      ),
    );

    if (updatedProfile != null && updatedProfile is Map<String, dynamic>) {
      setState(() {
        _vendorProfile = {
          "profilePictureUrl": updatedProfile["photo"] ?? _vendorProfile["profilePictureUrl"] ?? "",
          "username": updatedProfile["name"] ?? _vendorProfile["username"] ?? "Unknown Vendor",
          "email": updatedProfile["email"] ?? _vendorProfile["email"] ?? "",
          "phoneNumber": updatedProfile["tele_number"] ?? _vendorProfile["phoneNumber"] ?? "",
          "address": updatedProfile["address"] ?? _vendorProfile["address"] ?? "",
          "businessName": updatedProfile["businessName"] ?? _vendorProfile["businessName"] ?? "",
          "businessDescription": updatedProfile["businessDescription"] ?? _vendorProfile["businessDescription"] ?? "",
        };
      });
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                _vendorProfile["profilePictureUrl"] ?? "https://via.placeholder.com/150",
              ),
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