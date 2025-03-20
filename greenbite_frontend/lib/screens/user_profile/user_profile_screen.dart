import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/green_bite_points/green_bite_shop.dart';
import 'package:greenbite_frontend/screens/user_profile/models/user_profile.dart';
import 'package:greenbite_frontend/screens/user_profile/models/user_profile_service.dart';
import 'package:greenbite_frontend/screens/user_profile/edit_profile_screen.dart';
import 'package:greenbite_frontend/screens/vendor/vendor_home.dart';
import 'package:greenbite_frontend/screens/green_bite_points/green_bite_points_screen.dart';

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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VendorHome()),
    );
  }

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
          ? const Center(child: Text('Failed to load user profile', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSectionItem(
                    icon: Icons.edit,
                    text: "Edit Profile",
                    onPressed: _editProfile,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
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
                      onPressed: () {
                        // No logic needed for now
                      },
                    ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildSectionItem(
                    icon: Icons.logout,
                    text: "Sign Out",
                    onPressed: _signOut,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
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
                              builder: (context) => GreenBiteShopScreen()));
                    },
                  ),
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

  Widget _buildProfileHeader() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              _userProfile?.profilePictureUrl ?? UserProfile.placeholderProfilePictureUrl,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userProfile!.username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
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