import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/green_bite_points/green_bite_shop.dart';
import 'package:greenbite_frontend/screens/user_profile/models/user_profile.dart';
import 'package:greenbite_frontend/screens/user_profile/models/user_profile_service.dart';
import 'package:greenbite_frontend/screens/user_profile/edit_profile_screen.dart';
import 'package:greenbite_frontend/screens/vendor/vendor_home.dart'; // Import the VendorHome screen
import 'package:greenbite_frontend/screens/green_bite_points/green_bite_points_screen.dart'; // Import Green Bite Points screen

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

  // ✅ Fetch user profile data
  Future<void> _fetchUserProfile() async {
    try {
      final userProfile = await UserProfileService.fetchUserProfile();
      setState(() {
        _userProfile = userProfile;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching user profile: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ Navigate to Edit Screen & Update UI After Saving
  Future<void> _editProfile() async {
    final updatedProfile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userProfile: _userProfile!),
      ),
    );

    // ✅ If user saved changes, update UI
    if (updatedProfile != null && updatedProfile is UserProfile) {
      setState(() {
        _userProfile = updatedProfile;
      });
    }
  }

  // ✅ Sign Out (Placeholder)
  void _signOut() {
    print("User signed out"); // TODO: Implement real sign-out logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signed out successfully!")),
    );
  }

  // ✅ Switch to Vendor View
  void _switchToVendor() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VendorHome()),
    );
  }

  // ✅ Navigate to Green Bite Points Page
  void _goToGreenBitePoints() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GreenBitePointsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                  child: Text('Failed to load user profile',
                      style: TextStyle(fontSize: 18, color: Colors.grey)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Picture and Name Section
                      _buildProfileHeader(),
                      const SizedBox(height: 20),

                      // Main Container with Grey Background and Rounded Corners
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100, // Light grey background
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                        ),
                        child: Column(
                          children: [
                            // Edit Profile Section
                            _buildSectionItem(
                              icon: Icons.edit,
                              text: "Edit Profile",
                              onPressed: _editProfile,
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),

                            // Switch to Vendor Section
                            _buildSectionItem(
                              icon: Icons.store,
                              text: "Switch to Vendor",
                              onPressed: _switchToVendor,
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),

                            // Sign Out Section
                            _buildSectionItem(
                              icon: Icons.logout,
                              text: "Sign Out",
                              onPressed: _signOut,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Additional Options Container
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100, // Light grey background
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                        ),
                        child: Column(
                          children: [
                            // Green Bite Points Section
                            _buildSectionItem(
                              icon: Icons.emoji_events,
                              text: "Green Bite Points",
                              onPressed: _goToGreenBitePoints,
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),

                            _buildSectionItem(
                              icon: Icons.store,
                              text: "Green Bite Shop",
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            GreenBiteShopScreen()));
                              },
                            ),

                            // About Us Section
                            _buildSectionItem(
                              icon: Icons.info,
                              text: "About Us",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Profile Header with Profile Picture and Name
  Widget _buildProfileHeader() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              _userProfile?.profilePictureUrl ??
                  UserProfile
                      .placeholderProfilePictureUrl, // Fallback to placeholder
            ),
          ),
          const SizedBox(width: 16), // Spacing between image and text

          // User Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username
              Text(
                _userProfile!.username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),

              // Email
              Text(
                _userProfile!.email,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section Item with Icon, Text and Divider
  Widget _buildSectionItem({
    required IconData icon,
    required String text,
    VoidCallback? onPressed,
  }) {
    return ListTile(
      onTap: onPressed,
      leading: Icon(icon, color: Colors.green),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
    );
  }
}
