class User {
  final String id;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? googleId;

  User({
    required this.id,
    this.displayName,
    this.email,
    this.photoUrl,
    this.googleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      displayName: json['name'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photourl'] as String?,
      googleId: json['google_id'] as String?,
    );
  }
}
