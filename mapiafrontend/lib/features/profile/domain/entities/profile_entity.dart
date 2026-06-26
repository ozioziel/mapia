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
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.phoneVerified,
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
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final bool phoneVerified;
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

  String get name => '$firstName $lastName'.trim();

  bool get canPublish => phoneVerified;

  ProfileEntity copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    bool? phoneVerified,
    String? username,
    String? bio,
    String? avatarUrl,
  }) {
    return ProfileEntity(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
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
