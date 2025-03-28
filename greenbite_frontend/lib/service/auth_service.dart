import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'auth_email';
  static const String _userIdKey = 'auth_user_id';
  static String? _cachedToken; // In-memory cache
  static String? _cachedEmail; // In-memory cache
  static int? _cachedUserId; // In-memory cache

  // Save token and cache it
  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _cachedToken = token; // Store in cache
  }

  // Save email and cache it
  static Future<void> saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    _cachedEmail = email; // Store in cache
  }

  // Save user ID and cache it
  static Future<void> saveUserId(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    _cachedUserId = userId; // Store in cache
  }

  // Get token: First check cache, if not found, load from SharedPreferences
  static Future<String?> getToken() async {
    if (_cachedToken != null) {
      return _cachedToken; // Return cached token if available
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey); // Load from storage
    return _cachedToken;
  }

  // Get email: First check cache, if not found, load from SharedPreferences
  static Future<String?> getEmail() async {
    if (_cachedEmail != null) {
      return _cachedEmail; // Return cached email if available
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _cachedEmail = prefs.getString(_emailKey); // Load from storage
    return _cachedEmail;
  }

  // Get user ID: First check cache, if not found, load from SharedPreferences
  static Future<int?> getUserId() async {
    if (_cachedUserId != null) {
      return _cachedUserId; // Return cached user ID if available
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _cachedUserId = prefs.getInt(_userIdKey); // Load from storage
    return _cachedUserId;
  }

  // Remove token, email, and user ID (for logout)
  static Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_userIdKey);
    _cachedToken = null; // Clear cache
    _cachedEmail = null; // Clear cache
    _cachedUserId = null; // Clear cache
  }
}
