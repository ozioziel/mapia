import 'package:mapiafrontend/features/profile/data/datasources/profile_mock_datasource.dart';
import 'package:mapiafrontend/features/profile/data/models/profile_model.dart';
import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';
import 'package:mapiafrontend/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._datasource);

  final ProfileMockDatasource _datasource;

  @override
  Future<ProfileEntity> getProfile() {
    return _datasource.getProfile();
  }

  @override
  Future<ProfileEntity> updateProfile({
    required String name,
    required String username,
    required String bio,
    String? avatarUrl,
  }) async {
    final current = await _datasource.getProfile();
    final normalizedUsername = username.trim().startsWith('@')
        ? username.trim()
        : '@${username.trim()}';

    return _datasource.updateProfile(
      ProfileModel.fromEntity(
        current.copyWith(
          name: name.trim(),
          username: normalizedUsername,
          bio: bio.trim(),
          avatarUrl: avatarUrl,
        ),
      ),
    );
  }

  @override
  Future<void> logout() {
    return _datasource.clearSession();
  }
}
