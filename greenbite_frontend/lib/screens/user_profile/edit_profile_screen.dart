import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/user_profile/models/user_profile.dart';
import 'package:greenbite_frontend/screens/user_profile/models/user_profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfileScreen({super.key, required this.userProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.username);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _phoneController =
        TextEditingController(text: widget.userProfile.phoneNumber);
    _addressController =
        TextEditingController(text: widget.userProfile.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ✅ Save changes (PUT request)
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final updatedProfile = UserProfile(
      id: widget.userProfile.id, // ✅ Keep the same ID
      username: _nameController.text.trim(),
      email: _emailController.text.trim(),
      profilePictureUrl:
          widget.userProfile.profilePictureUrl, // Keep existing picture
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    bool success = await UserProfileService.updateUserProfile(updatedProfile);

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.pop(context, updatedProfile); // Return updated profile
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ✅ Profile Picture Update Option
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    widget.userProfile.profilePictureUrl ??
                        UserProfile.placeholderProfilePictureUrl,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon:
                          const Icon(Icons.edit, color: Colors.white, size: 20),
                      onPressed: () {
                        // TODO: Implement profile picture change functionality
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ Input Fields
            _buildTextField("Full Name", _nameController, Icons.person),
            _buildTextField("Email Address", _emailController, Icons.email),
            _buildTextField("Phone Number", _phoneController, Icons.phone),
            _buildTextField(
                "Home Address", _addressController, Icons.location_on),
            const SizedBox(height: 20),

            // ✅ Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveProfile,
                icon: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.save, color: Colors.white),
                label: const Text("Save Changes",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Custom Text Field with Icon
  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}
