import 'package:mapiafrontend/features/profile/domain/repositories/profile_repository.dart';

class SendPhoneVerificationCodeUsecase {
  const SendPhoneVerificationCodeUsecase(this._repository);

  final ProfileRepository _repository;

  Future<void> call() {
    return _repository.sendPhoneVerificationCode();
  }
}
