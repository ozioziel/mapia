import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';
import 'package:mapiafrontend/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUsecase {
  const UpdateProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call({
    required String firstName,
    required String lastName,
    required String phone,
    required String bio,
    String? avatarUrl,
  }) {
    return _repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      bio: bio,
      avatarUrl: avatarUrl,
    );
  }
}
