import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/login/login_screen.dart';
import 'package:greenbite_frontend/screens/vendor/vendor_sales.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../../widgets/vendor_nav_bar.dart';
import 'vendor_home.dart';
import 'list_food.dart';
import 'edit_profile.dart';
import 'package:provider/provider.dart';
import 'package:greenbite_frontend/theme_provider.dart';

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
    String? token = await AuthService.getToken();
    if (token == null) {
      throw Exception("No authentication token found");
    }
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/shop/${widget.vendorId}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
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
            "businessName": data["name"] ?? "",
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load vendor profile: $e")),
      );
    }
  }

  // Function to handle navigation
  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VendorHome(shopId: widget.vendorId),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ListFood(shopId: widget.vendorId),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VendorSalesPage(shopId: widget.vendorId),
        ),
      );
    }
  }

  // Navigate to Edit Profile Screen
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
          "profilePictureUrl": updatedProfile["photo"] ??
              _vendorProfile["profilePictureUrl"] ??
              "",
          "username": updatedProfile["name"] ??
              _vendorProfile["username"] ??
              "Unknown Vendor",
          "email": updatedProfile["email"] ?? _vendorProfile["email"] ?? "",
          "phoneNumber": updatedProfile["tele_number"] ??
              _vendorProfile["phoneNumber"] ??
              "",
          "address":
              updatedProfile["address"] ?? _vendorProfile["address"] ?? "",
          "businessName": updatedProfile["businessName"] ??
              _vendorProfile["businessName"] ??
              "",
          "businessDescription": updatedProfile["businessDescription"] ??
              _vendorProfile["businessDescription"] ??
              "",
        };
      });
    }
  }

  void _signOut() async {
    try {
      await AuthService.removeToken(); // Clear token & user data

      // Navigate to login screen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false, // Remove all routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  // Profile Header
                  _buildProfileHeader(theme),
                  const SizedBox(height: 16),

                  // Dark Mode Toggle
                  _buildDarkModeToggle(themeProvider, theme),
                  const SizedBox(height: 16),

                  // Main Profile Options
                  _buildOptionsContainer(theme, [
                    _buildSectionItem(
                      icon: Icons.edit,
                      text: "Edit Profile",
                      onPressed: _editProfile,
                    ),
                    _buildSectionItem(
                      icon: Icons.logout,
                      text: "Sign Out",
                      onPressed: _signOut,
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // Business Details Options
                  _buildOptionsContainer(theme, [
                    _buildSectionItem(
                      icon: Icons.business,
                      text: "Business Name",
                      subtitle: _vendorProfile["businessName"] ?? "Not set",
                      onPressed: null,
                    ),
                    _buildSectionItem(
                      icon: Icons.description,
                      text: "Business Description",
                      subtitle:
                          _vendorProfile["businessDescription"] ?? "Not set",
                      onPressed: null,
                    ),
                    _buildSectionItem(
                      icon: Icons.phone,
                      text: "Phone Number",
                      subtitle: _vendorProfile["phoneNumber"] ?? "Not set",
                      onPressed: null,
                    ),
                    _buildSectionItem(
                      icon: Icons.location_on,
                      text: "Address",
                      subtitle: _vendorProfile["address"] ?? "Not set",
                      onPressed: null,
                    ),
                  ]),
                ],
              ),
            ),
      bottomNavigationBar: VendorNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        shopId: widget.vendorId,
      ),
    );
  }

  // Profile Header
  Widget _buildProfileHeader(ThemeData theme) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(
            _vendorProfile["profilePictureUrl"] ??
                "https://via.placeholder.com/150",
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _vendorProfile["username"] ?? "Unknown Vendor",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _vendorProfile["email"] ?? "",
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  // Dark Mode Toggle
  Widget _buildDarkModeToggle(ThemeProvider themeProvider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          "Dark Mode",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        value: themeProvider.themeMode == ThemeMode.dark,
        onChanged: (value) {
          themeProvider.toggleTheme(value);
        },
        secondary: Icon(
          Icons.dark_mode,
          color: theme.iconTheme.color,
        ),
      ),
    );
  }

  // Generalized Options Container
  Widget _buildOptionsContainer(ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children
            .expand((widget) =>
                [widget, const Divider(height: 1, indent: 16, endIndent: 16)])
            .toList()
            .sublist(0, children.length * 2 - 1), // Remove last divider
      ),
    );
  }

  // Section Item with Icon, Text, and Divider
  Widget _buildSectionItem({
    required IconData icon,
    required String text,
    String? subtitle,
    VoidCallback? onPressed,
  }) {
    return ListTile(
      onTap: onPressed,
      leading: Icon(icon),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onPressed != null ? const Icon(Icons.arrow_forward_ios) : null,
    );
  }
}
