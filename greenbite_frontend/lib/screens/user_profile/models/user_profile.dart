class UserProfile {
  final int id;
  final String username;
  final String email;
  final String? profilePictureUrl; // Make it nullable
  final String phoneNumber;
  final String address;

  // Default placeholder URL
  static const String placeholderProfilePictureUrl =
      'https://static.vecteezy.com/system/resources/previews/005/544/718/non_2x/profile-icon-design-free-vector.jpg';

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.profilePictureUrl, // Accept null
    required this.phoneNumber,
    required this.address,
  });

  // ✅ Convert JSON to UserProfile
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profilePictureUrl: json['profilePictureUrl'] ??
          placeholderProfilePictureUrl, // Use placeholder if null
      phoneNumber: json['phoneNumber'],
      address: json['address'],
    );
  }

  // ✅ Convert UserProfile to JSON (Fix for update function)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "profilePictureUrl": profilePictureUrl ??
          placeholderProfilePictureUrl, // Use placeholder if null
      "phoneNumber": phoneNumber,
      "address": address,
    };
  }
}
