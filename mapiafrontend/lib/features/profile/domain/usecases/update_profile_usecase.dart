import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';
import 'package:mapiafrontend/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUsecase {
  const UpdateProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call({
    required String name,
    required String username,
    required String bio,
    String? avatarUrl,
  }) {
    return _repository.updateProfile(
      name: name,
      username: username,
      bio: bio,
      avatarUrl: avatarUrl,
    );
  }
}
