import 'package:flutter/material.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // For File class
import '../../config.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> vendorProfile;
  final int vendorId;

  const EditProfile(
      {super.key, required this.vendorProfile, required this.vendorId});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _businessDescriptionController;

  bool _isLoading = false;
  File? _imageFile; // To store the selected image file

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the vendor profile data
    _nameController =
        TextEditingController(text: widget.vendorProfile["name"] ?? "");
    _emailController =
        TextEditingController(text: widget.vendorProfile["email"] ?? "");
    _phoneController =
        TextEditingController(text: widget.vendorProfile["phoneNumber"] ?? "");
    _addressController =
        TextEditingController(text: widget.vendorProfile["address"] ?? "");
    _businessDescriptionController = TextEditingController(
        text: widget.vendorProfile["businessDescription"] ?? "");
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _businessDescriptionController.dispose();
    super.dispose();
  }

  // Function to handle form submission (Save)
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    // Retrieve the token
    String? token = await AuthService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No authentication token found")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final updatedProfile = {
      "id": widget.vendorId, // Ensure vendorId is included
      "name": _nameController.text, // Use "name" instead of "username"
      "email": _emailController.text,
      "phoneNumber": _phoneController.text,
      "address": _addressController.text,
      "businessDescription": _businessDescriptionController.text,
    };

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${Config.apiBaseUrl}/api/shop/update/${widget.vendorId}'),
      );

      // Add headers
      request.headers.addAll({
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });

      // Add JSON data
      request.fields['shop'] = jsonEncode(updatedProfile);

      // Add image file if it exists
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            _imageFile!.path,
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context); // Close the screen
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to pick an image from the gallery or camera
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 117, 237, 123),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!) // Use the selected image
                              : NetworkImage(
                                  widget.vendorProfile["photo"] ??
                                      "https://via.placeholder.com/150",
                                ) as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.white, size: 20),
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
                                              leading: const Icon(
                                                  Icons.photo_library),
                                              title: const Text("Gallery"),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _pickImage(ImageSource.gallery);
                                              },
                                            ),
                                            ListTile(
                                              leading:
                                                  const Icon(Icons.camera_alt),
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
                  ),
                  const SizedBox(height: 20),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Business Description
                  TextFormField(
                    controller: _businessDescriptionController,
                    decoration: const InputDecoration(
                      labelText: "Business Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        "Save Profile",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
