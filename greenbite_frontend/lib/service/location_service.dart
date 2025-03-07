import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:greenbite_frontend/service/auth_service';
import 'package:http/http.dart' as http;
import 'package:greenbite_frontend/config.dart';

class LocationService {
  // Get current position using geolocator
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Return the current position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Call the backend API to update the user location
  static Future<void> updateUserLocation(int userId) async {
    try {
      final position = await getCurrentLocation();
      final double latitude = position.latitude;
      final double longitude = position.longitude;

      // Build the JSON payload
      final Map<String, dynamic> payload = {
        "userId": userId,
        "latitude": latitude,
        "longitude": longitude,
      };
      String? token = await AuthService.getToken(); // Retrieve token
      if (token == null) {
        print("No token found");
        return;
      }
      // Send a PUT request to your backend endpoint
      final response = await http.put(
        Uri.parse('${Config.apiBaseUrl}/api/users/updateLocation'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json", // Add this line
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print("User location updated successfully");
      } else {
        print("Failed to update location. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating location: $e");
    }
  }
}
