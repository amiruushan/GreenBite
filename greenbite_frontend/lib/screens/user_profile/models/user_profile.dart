class UserProfile {
  final int id;
  final String username;
  final String email;
  final String? profilePictureUrl;
  final String phoneNumber;
  final String address;
  final int shopId;

  static const String placeholderProfilePictureUrl =
      'https://static.vecteezy.com/system/resources/previews/005/544/718/non_2x/profile-icon-design-free-vector.jpg';

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.profilePictureUrl,
    required this.phoneNumber,
    required this.address,
    required this.shopId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profilePictureUrl:
          json['profilePictureUrl'] ?? placeholderProfilePictureUrl,
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      shopId: json['shopId'],
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
      "shopId": shopId,
    };
  }
}
