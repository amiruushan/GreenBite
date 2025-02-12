import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/user_profile/models/user_profile.dart';
import 'package:greenbite_frontend/screens/user_profile/models/user_profile_service.dart';
import 'package:greenbite_frontend/screens/user_profile/edit_profile_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            NetworkImage(_userProfile!.profilePictureUrl),
                      ),
                      const SizedBox(height: 16),

                      // User Name
                      Text(
                        _userProfile!.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Email
                      Text(
                        _userProfile!.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info Cards
                      _buildInfoCard(
                          Icons.phone, "Phone", _userProfile!.phoneNumber),
                      _buildInfoCard(
                          Icons.location_on, "Address", _userProfile!.address),

                      const SizedBox(height: 20),

                      // Edit Profile Button
                      _buildActionButton(
                        icon: Icons.edit,
                        text: "Edit Profile",
                        color: Colors.blue,
                        onPressed: _editProfile,
                      ),

                      SizedBox(height: 20),

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
    );
  }

  // Widget to display user info
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
