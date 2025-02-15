import 'dart:convert';
import 'package:greenbite_frontend/service/auth_service';
import 'package:http/http.dart' as http;
// Import AuthService
import 'user_profile.dart';

class UserProfileService {
  // ✅ Fetch User Profile
  static Future<UserProfile> fetchUserProfile() async {
    try {
      // Get the user ID from SharedPreferences
      int? userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Fetch user profile using the user ID
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8080/api/users/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfile.fromJson(data);
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  // ✅ Update user profile using PUT request with ID
  static Future<bool> updateUserProfile(UserProfile updatedProfile) async {
    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8080/api/users/update'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(updatedProfile.toJson()),
      );

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
