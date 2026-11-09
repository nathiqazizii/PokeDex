class Profile {
  final String id;
  final String username;
  final DateTime? createdAt;

  const Profile({required this.id, required this.username, this.createdAt});

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        username: (json['username'] as String?) ?? '',
        createdAt: json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at'] as String),
      );
}
