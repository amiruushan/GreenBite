import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_profile.dart';

class UserProfileService {
  static const String _baseUrl = 'http://127.0.0.1:8080'; // JSON Server URL

  // ✅ Fetch User Profile
  static Future<UserProfile> fetchUserProfile() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/users/2'));

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

  // ✅ FIX: Add this function to update user profile (PUT request)
  static Future<bool> updateUserProfile(UserProfile updatedProfile) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/users/update'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(
            updatedProfile.toJson()), // Ensure `toJson()` exists in UserProfile
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
