class Profile {

  const Profile({
    required this.id,
    this.username,
    this.fullName,
    this.bio,
    this.avatarUrl,
    this.updatedAt,
  });

  factory Profile.fromMap(Map<String, dynamic> m) {
    return Profile(
      id: m['id'] as String,
      username: m['username'] as String?,
      fullName: m['full_name'] as String?,
      bio: m['bio'] as String?,
      avatarUrl: m['avatar_url'] as String?,
      updatedAt: m['updated_at'] == null
          ? null
          : DateTime.tryParse(m['updated_at'] as String),
    );
  }
  final String id;
  final String? username;
  final String? fullName;
  final String? bio;
  final String? avatarUrl;
  final DateTime? updatedAt;

  Profile copyWith({
    String? id,
    String? username,
    String? fullName,
    String? bio,
    String? avatarUrl,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toUpdateMap() => {
        if (username != null) 'username': username,
        if (fullName != null) 'full_name': fullName,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
}
