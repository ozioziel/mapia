import 'package:mapiafrontend/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';
import 'package:mapiafrontend/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._datasource);

  final ProfileRemoteDatasource _datasource;

  @override
  Future<ProfileEntity> getProfile() => _datasource.getProfile();

  @override
  Future<ProfileEntity> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String bio,
    String? avatarUrl,
  }) {
    return _datasource.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      bio: bio,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<void> sendPhoneVerificationCode() {
    return _datasource.sendPhoneVerificationCode();
  }

  @override
  Future<ProfileEntity> verifyPhoneCode(String code) {
    return _datasource.verifyPhoneCode(code);
  }

  @override
  Future<void> logout() async {}
}
