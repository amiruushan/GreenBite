class UserProfile {
  final String name;
  final String email;
  final String profilePictureUrl;
  final String phoneNumber;
  final String address;

  UserProfile({
    required this.name,
    required this.email,
    required this.profilePictureUrl,
    required this.phoneNumber,
    required this.address,
  });

  // Factory method to create a UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      email: json['email'],
      profilePictureUrl: json['profilePictureUrl'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
    );
  }
}
