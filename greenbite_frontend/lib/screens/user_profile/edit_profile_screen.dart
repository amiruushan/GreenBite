import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import the image_picker package
import 'package:greenbite_frontend/screens/user_profile/models/user_profile.dart';
import 'package:greenbite_frontend/screens/user_profile/models/user_profile_service.dart';
import 'dart:io'; // For File class

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
  File? _imageFile; // To store the selected image file

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
      profilePictureUrl: _imageFile != null
          ? _imageFile!.path
          : widget.userProfile.profilePictureUrl, // Use new image if selected
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    bool success =
        await UserProfileService.updateUserProfile(updatedProfile, _imageFile);

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

  // ✅ Function to pick an image from the gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent, // ✅ Transparent AppBar
        elevation: 0, // ✅ Remove shadow
        iconTheme: IconThemeData(
          color: theme.colorScheme.onSurface, // ✅ Icons adapt to theme
        ),
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
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!) // Use the selected image
                      : NetworkImage(
                          widget.userProfile.profilePictureUrl ??
                              UserProfile.placeholderProfilePictureUrl,
                        ) as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary, // ✅ Theme-based color
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit,
                          color: theme.colorScheme.onPrimary,
                          size: 20), // ✅ Theme-based color
                      onPressed: () {
                        // Show a dialog to choose between gallery and camera
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Choose Image Source"),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text("Gallery"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickImage(ImageSource.gallery);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text("Camera"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickImage(ImageSource.camera);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ Input Fields
            _buildTextField("Full Name", _nameController, Icons.person, theme),
            _buildTextField(
                "Email Address", _emailController, Icons.email, theme),
            _buildTextField(
                "Phone Number", _phoneController, Icons.phone, theme),
            _buildTextField(
                "Home Address", _addressController, Icons.location_on, theme),
            const SizedBox(height: 20),

            // ✅ Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveProfile,
                icon: _isSaving
                    ? CircularProgressIndicator(
                        color:
                            theme.colorScheme.onPrimary) // ✅ Theme-based color
                    : Icon(Icons.save,
                        color:
                            theme.colorScheme.onPrimary), // ✅ Theme-based color
                label: Text("Save Changes",
                    style: TextStyle(
                        fontSize: 18,
                        color: theme
                            .colorScheme.onPrimary)), // ✅ Theme-based color
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.primary, // ✅ Theme-based color
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
  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: TextStyle(
            color: theme.colorScheme.onSurface), // ✅ Theme-based color
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: theme.colorScheme.onSurface
                  .withOpacity(0.7)), // ✅ Theme-based color
          prefixIcon: Icon(icon,
              color: theme.colorScheme.primary), // ✅ Theme-based color
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: theme.colorScheme.surface, // ✅ Theme-based color
        ),
      ),
    );
  }
}
