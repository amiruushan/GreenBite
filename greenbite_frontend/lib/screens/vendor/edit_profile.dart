import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> vendorProfile;
  final int vendorId;

  const EditProfile({super.key, required this.vendorProfile, required this.vendorId});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Controllers for form fields
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _businessNameController;
  late TextEditingController _businessDescriptionController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the vendor profile data
    _usernameController = TextEditingController(text: widget.vendorProfile["username"] ?? "");
    _emailController = TextEditingController(text: widget.vendorProfile["email"] ?? "");
    _phoneController = TextEditingController(text: widget.vendorProfile["phoneNumber"] ?? "");
    _addressController = TextEditingController(text: widget.vendorProfile["address"] ?? "");
    _businessNameController = TextEditingController(text: widget.vendorProfile["businessName"] ?? "");
    _businessDescriptionController = TextEditingController(text: widget.vendorProfile["businessDescription"] ?? "");
  }

  @override
  void dispose() {
    // Dispose controllers
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    super.dispose();
  }

  // Function to handle form submission (Save)
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    final updatedProfile = {
      "id": widget.vendorId, // Ensure vendorId is included
      "name": _usernameController.text,
      "email": _emailController.text,
      "tele_number": _phoneController.text,
      "address": _addressController.text,
      "businessName": _businessNameController.text,
      "businessDescription": _businessDescriptionController.text,
    };

    try {
      final response = await http.put(
        Uri.parse('${Config.apiBaseUrl}/api/shop/update'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updatedProfile),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        try {
          Navigator.pop(context, responseData); // Return updated profile data
        } catch (e) {
          print("Error returning updated profile: $e");
          Navigator.pop(context); // Close the screen without returning data
        }
      } else {
        throw Exception('Failed to update profile: ${response.body}');
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
            // Username
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
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

            // Business Name
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                labelText: "Business Name",
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