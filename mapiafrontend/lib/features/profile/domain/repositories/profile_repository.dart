import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<ProfileEntity> updateProfile({
    required String name,
    required String username,
    required String bio,
    String? avatarUrl,
  });

  Future<void> logout();
}
