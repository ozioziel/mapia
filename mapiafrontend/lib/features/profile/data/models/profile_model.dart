import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';

class ProfilePostModel extends ProfilePostEntity {
  const ProfilePostModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.likesCount,
  });
}

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.phoneVerified,
    required super.username,
    required super.bio,
    required super.avatarUrl,
    required super.followersCount,
    required super.followingCount,
    required super.likesCount,
    required super.reputationScore,
    required super.postsCount,
    required super.posts,
    super.location,
    super.createdAt,
  });

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      phone: entity.phone,
      phoneVerified: entity.phoneVerified,
      username: entity.username,
      bio: entity.bio,
      avatarUrl: entity.avatarUrl,
      followersCount: entity.followersCount,
      followingCount: entity.followingCount,
      likesCount: entity.likesCount,
      reputationScore: entity.reputationScore,
      postsCount: entity.postsCount,
      posts: entity.posts,
      location: entity.location,
      createdAt: entity.createdAt,
    );
  }
}
