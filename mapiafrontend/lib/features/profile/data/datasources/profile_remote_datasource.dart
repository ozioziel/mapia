import 'package:mapiafrontend/features/profile/data/datasources/profile_api.dart';
import 'package:mapiafrontend/features/profile/data/models/profile_model.dart';
import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';

class ProfileRemoteDatasource {
  ProfileRemoteDatasource({
    required ProfileApi api,
    required this.userEmail,
    required this.userId,
  }) : _api = api;

  final ProfileApi _api;
  final String userEmail;
  final String userId;

  Future<ProfileEntity> getProfile() async {
    final profileJson = await _api.getProfile();
    final posts = await _api.getUserPosts(userId);
    return _mapProfile(profileJson, posts);
  }

  Future<ProfileEntity> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String bio,
    String? avatarUrl,
  }) async {
    final profileJson = await _api.patchProfile({
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'bio': bio,
    });
    final posts = await _api.getUserPosts(userId);
    final entity = _mapProfile(profileJson, posts);
    if (avatarUrl != null) {
      return entity.copyWith(avatarUrl: avatarUrl);
    }
    return entity;
  }

  Future<void> sendPhoneVerificationCode() async {
    final profile = await _api.getProfile();
    final phone = profile['phone'] as String?;
    if (phone == null || phone.trim().isEmpty) {
      throw StateError('Agrega un telefono antes de verificar.');
    }
    await _api.sendPhoneCode(phone.trim());
  }

  Future<ProfileEntity> verifyPhoneCode(String code) async {
    final profileJson = await _api.verifyPhoneCode(code);
    final posts = await _api.getUserPosts(userId);
    return _mapProfile(profileJson, posts);
  }

  ProfileEntity _mapProfile(
    Map<String, dynamic> json,
    List<Map<String, dynamic>> posts,
  ) {
    final username = json['username'] as String? ?? '';
    return ProfileModel(
      id: json['userId'] as String? ?? userId,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: userEmail,
      phone: json['phone'] as String? ?? '',
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      username: username.startsWith('@') ? username : '@$username',
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      reputationScore:
          (json['reputationScore'] as num?)?.toInt() ??
          (json['likesCount'] as num?)?.toInt() ??
          0,
      postsCount: (json['postsCount'] as num?)?.toInt() ?? posts.length,
      posts: [
        for (final post in posts)
          ProfilePostEntity(
            id: post['id'] as String? ?? '',
            title: post['title'] as String? ?? 'Publicacion',
            subtitle:
                post['address'] as String? ?? post['type'] as String? ?? '',
            likesCount: (post['likesCount'] as num?)?.toInt() ?? 0,
          ),
      ],
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}
