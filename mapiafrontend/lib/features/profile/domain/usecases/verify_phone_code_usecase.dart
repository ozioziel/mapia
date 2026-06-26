import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';
import 'package:mapiafrontend/features/profile/domain/repositories/profile_repository.dart';

class VerifyPhoneCodeUsecase {
  const VerifyPhoneCodeUsecase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call(String code) {
    return _repository.verifyPhoneCode(code);
  }
}
