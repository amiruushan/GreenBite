import 'dart:convert';
import 'dart:io';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:http/http.dart' as http;
// Import AuthService
import 'user_profile.dart';

class UserProfileService {
  //  Fetch User Profile
  static Future<UserProfile> fetchUserProfile() async {
    try {
      int? userId = await AuthService.getUserId(); // Retrieve user ID
      if (userId == null) {
        print("No user ID found");
      }
      // Replace with your actual API endpoint
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/users/$userId'),
        headers: {
          "Authorization": "Bearer ${await AuthService.getToken()}",
        },
      );

      print("API Response Status Code: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfile.fromJson(data);
      } else {
        throw Exception(
            'Failed to load user profile. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      throw Exception('Failed to load user profile: $e');
    }
  }

  static Future<bool> updateUserProfile(
      UserProfile updatedProfile, File? imageFile) async {
    try {
      String? token = await AuthService.getToken(); // Retrieve token
      if (token == null) {
        print("No token found");
        return false;
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${Config.apiBaseUrl}/api/users/update'),
      );

      request.headers["Authorization"] = "Bearer $token";

      // Convert UserProfile to JSON and add it as a field
      final userJson = jsonEncode(updatedProfile.toJson());
      request.fields['user'] = userJson;

      // Add image file if it exists
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePicture',
            imageFile.path,
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update profile. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
}
