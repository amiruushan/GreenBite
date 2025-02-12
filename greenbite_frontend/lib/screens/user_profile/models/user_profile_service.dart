import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_profile.dart'; // Import the UserProfile model

class UserProfileService {
  static const String _baseUrl =
      'http://10.0.2.2:3000'; // Use 10.0.2.2 for Android emulator

  // Fetch user profile data from the JSON server
  static Future<UserProfile> fetchUserProfile() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/userProfile'));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        print('Fetched data: $data'); // Debugging
        return UserProfile.fromJson(data);
      } else {
        print(
            'Failed to load user profile. Status code: ${response.statusCode}');
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      throw Exception('Failed to load user profile');
    }
  }
}
