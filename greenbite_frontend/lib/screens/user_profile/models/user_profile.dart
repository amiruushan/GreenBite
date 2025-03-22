class UserProfile {
  final int id;
  final String username;
  final String email;
  final String profilePictureUrl;
  final String phoneNumber;
  final String address;
  final int shopId;

  static const String placeholderProfilePictureUrl =
      'https://static.vecteezy.com/system/resources/previews/005/544/718/non_2x/profile-icon-design-free-vector.jpg';
  static const String placeholderUsername = "Unknown User";
  static const String placeholderEmail = "unknown@example.com";
  static const String placeholderPhoneNumber = "000-000-0000";
  static const String placeholderAddress = "No address provided";
  static const int placeholderShopId = 0;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePictureUrl,
    required this.phoneNumber,
    required this.address,
    required this.shopId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      username: json['username'] ?? placeholderUsername,
      email: json['email'] ?? placeholderEmail,
      profilePictureUrl:
          json['profilePictureUrl'] ?? placeholderProfilePictureUrl,
      phoneNumber: json['phoneNumber'] ?? placeholderPhoneNumber,
      address: json['address'] ?? placeholderAddress,
      shopId: json['shopId'] ?? placeholderShopId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username.isNotEmpty ? username : placeholderUsername,
      "email": email.isNotEmpty ? email : placeholderEmail,
      "profilePictureUrl": profilePictureUrl.isNotEmpty
          ? profilePictureUrl
          : placeholderProfilePictureUrl,
      "phoneNumber":
          phoneNumber.isNotEmpty ? phoneNumber : placeholderPhoneNumber,
      "address": address.isNotEmpty ? address : placeholderAddress,
      "shopId": shopId,
    };
  }
}
