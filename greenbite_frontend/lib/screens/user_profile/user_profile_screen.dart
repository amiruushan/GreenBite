import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:greenbite_frontend/screens/green_bite_points/green_bite_shop.dart';
import 'package:greenbite_frontend/screens/user_profile/about_us_screen.dart';
import 'package:greenbite_frontend/screens/user_profile/models/user_profile.dart';
import 'package:greenbite_frontend/screens/user_profile/models/user_profile_service.dart';
import 'package:greenbite_frontend/screens/user_profile/edit_profile_screen.dart';
import 'package:greenbite_frontend/screens/vendor/vendor_home.dart';
import 'package:greenbite_frontend/screens/green_bite_points/green_bite_points_screen.dart';

import 'package:provider/provider.dart';
import 'package:greenbite_frontend/theme_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userProfile = await UserProfileService.fetchUserProfile();
      print("Fetched User Profile - shopId: ${userProfile.shopId}"); // Debug print
      setState(() {
        _userProfile = userProfile;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching user profile: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load user profile: $e")),
      );
    }
  }

  Future<void> _editProfile() async {
    final updatedProfile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userProfile: _userProfile!),
      ),
    );

    if (updatedProfile != null && updatedProfile is UserProfile) {
      setState(() {
        _userProfile = updatedProfile;
      });
    }
  }

  void _signOut() {
    print("User signed out");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signed out successfully!")),
    );
  }

  void _switchToVendor() {
    if (_userProfile != null && _userProfile!.shopId > 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VendorHome(shopId: _userProfile!.shopId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No shop associated with this account!")),
      );
    }
  }

  void _goToGreenBitePoints() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GreenBitePointsScreen()),
    );
  }

  // Function to open Google Form
  Future<void> _openGoogleForm() async {
    const googleFormUrl = 'https://docs.google.com/forms/d/e/1FAIpQLScchqRC_6TOEEjo9qwfHGWf29jetYCSFnUvom1LrVNpUHomQA/viewform?usp=sharing';
    if (await canLaunch(googleFormUrl)) {
      await launch(googleFormUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch the form.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context); // ✅ Get theme for adaptive colors

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.withOpacity(0.7), Colors.green.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
          ? const Center(
        child: Text(
          'Failed to load user profile',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            // ✅ Profile Header
            _buildProfileHeader(theme),
            const SizedBox(height: 16),

            // ✅ Dark Mode Toggle
            _buildDarkModeToggle(themeProvider, theme),
            const SizedBox(height: 16),

            // ✅ Main Profile Options
            _buildOptionsContainer(theme, [
              _buildSectionItem(
                icon: Icons.edit,
                text: "Edit Profile",
                onPressed: _editProfile,
              ),
              if (_userProfile!.shopId > 0)
                _buildSectionItem(
                  icon: Icons.store,
                  text: "Switch to Vendor",
                  onPressed: _switchToVendor,
                ),
              if (_userProfile!.shopId <= 0)
                _buildSectionItem(
                  icon: Icons.add_business,
                  text: "Create a Shop",
                  onPressed: _openGoogleForm, // Updated to open Google Form
                ),
              _buildSectionItem(
                icon: Icons.logout,
                text: "Sign Out",
                onPressed: _signOut,
              ),
            ]),

            const SizedBox(height: 16),

            // ✅ Additional Options
            _buildOptionsContainer(theme, [
              _buildSectionItem(
                icon: Icons.emoji_events,
                text: "Green Bite Points",
                onPressed: _goToGreenBitePoints,
              ),
              _buildSectionItem(
                icon: Icons.shopping_bag,
                text: "Green Bite Shop",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GreenBiteShopScreen()),
                  );
                },
              ),
              _buildSectionItem(
                icon: Icons.info,
                text: "About Us",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutUsScreen()),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ✅ Profile Header
  Widget _buildProfileHeader(ThemeData theme) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(
            _userProfile?.profilePictureUrl ?? UserProfile.placeholderProfilePictureUrl,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _userProfile!.username,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userProfile!.email,
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  // ✅ Dark Mode Toggle
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

  // ✅ Generalized Options Container
  Widget _buildOptionsContainer(ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children
            .expand((widget) => [widget, const Divider(height: 1, indent: 16, endIndent: 16)])
            .toList()
            .sublist(0, children.length * 2 - 1), // Remove last divider
      ),
    );
  }

  // ✅ Section Item with Icon, Text, and Divider
  Widget _buildSectionItem({
    required IconData icon,
    required String text,
    VoidCallback? onPressed,
  }) {
    return ListTile(
      onTap: onPressed,
      leading: Icon(icon),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
    );
  }
}