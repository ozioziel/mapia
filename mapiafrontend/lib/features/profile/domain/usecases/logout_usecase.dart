import 'package:mapiafrontend/features/profile/domain/repositories/profile_repository.dart';

class LogoutUsecase {
  const LogoutUsecase(this._repository);

  final ProfileRepository _repository;

  Future<void> call() {
    return _repository.logout();
  }
}
