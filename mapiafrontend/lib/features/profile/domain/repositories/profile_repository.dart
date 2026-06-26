import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<ProfileEntity> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String bio,
    String? avatarUrl,
  });

  Future<void> sendPhoneVerificationCode();

  Future<ProfileEntity> verifyPhoneCode(String code);

  Future<void> logout();
}
