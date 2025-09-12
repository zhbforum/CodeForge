class Profile {
  const Profile({
    required this.id,
    required this.displayName,
    this.bio,
    this.avatarUrl,
  });
  final String id;
  final String displayName;
  final String? bio;
  final String? avatarUrl;

  Profile copyWith({String? displayName, String? bio, String? avatarUrl}) =>
      Profile(
        id: id,
        displayName: displayName ?? this.displayName,
        bio: bio ?? this.bio,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}
