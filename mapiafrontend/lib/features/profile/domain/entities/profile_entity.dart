class ProfilePostEntity {
  const ProfilePostEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.likesCount,
  });

  final String id;
  final String title;
  final String subtitle;
  final int likesCount;
}

class ProfileEntity {
  const ProfileEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.bio,
    required this.avatarUrl,
    required this.followersCount,
    required this.followingCount,
    required this.likesCount,
    required this.postsCount,
    required this.posts,
    this.location,
    this.createdAt,
  });

  final String id;
  final String name;
  final String username;
  final String? bio;
  final String? avatarUrl;
  final int followersCount;
  final int followingCount;
  final int likesCount;
  final int postsCount;
  final List<ProfilePostEntity> posts;
  final String? location;
  final DateTime? createdAt;

  ProfileEntity copyWith({
    String? name,
    String? username,
    String? bio,
    String? avatarUrl,
  }) {
    return ProfileEntity(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      followersCount: followersCount,
      followingCount: followingCount,
      likesCount: likesCount,
      postsCount: postsCount,
      posts: posts,
      location: location,
      createdAt: createdAt,
    );
  }
}
