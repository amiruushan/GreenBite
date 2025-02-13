class UserProfile {
  final int id;
  final String username;
  final String email;
  final String profilePictureUrl;
  final String phoneNumber;
  final String address;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePictureUrl,
    required this.phoneNumber,
    required this.address,
  });

  // ✅ Convert JSON to UserProfile
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profilePictureUrl: json['profilePictureUrl'],
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
      "profilePictureUrl": profilePictureUrl,
      "phoneNumber": phoneNumber,
      "address": address,
    };
  }
}
