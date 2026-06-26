import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';
import 'package:mapiafrontend/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUsecase {
  const GetProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call() {
    return _repository.getProfile();
  }
}
