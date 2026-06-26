import 'package:flutter/foundation.dart';
import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';
import 'package:mapiafrontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:mapiafrontend/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:mapiafrontend/features/profile/domain/usecases/logout_usecase.dart';
import 'package:mapiafrontend/features/profile/domain/usecases/send_phone_verification_code_usecase.dart';
import 'package:mapiafrontend/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:mapiafrontend/features/profile/domain/usecases/verify_phone_code_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({required ProfileRepository repository})
    : _getProfileUsecase = GetProfileUsecase(repository),
      _updateProfileUsecase = UpdateProfileUsecase(repository),
      _logoutUsecase = LogoutUsecase(repository),
      _sendPhoneVerificationCodeUsecase = SendPhoneVerificationCodeUsecase(
        repository,
      ),
      _verifyPhoneCodeUsecase = VerifyPhoneCodeUsecase(repository);

  final GetProfileUsecase _getProfileUsecase;
  final UpdateProfileUsecase _updateProfileUsecase;
  final LogoutUsecase _logoutUsecase;
  final SendPhoneVerificationCodeUsecase _sendPhoneVerificationCodeUsecase;
  final VerifyPhoneCodeUsecase _verifyPhoneCodeUsecase;

  ProfileEntity? profile;
  bool isLoading = false;
  bool isSaving = false;
  bool isSendingCode = false;
  bool isVerifyingCode = false;
  String? error;

  Future<void> loadProfile() async {
    isLoading = true;
    error = null;
    profile = null;
    notifyListeners();

    try {
      profile = await _getProfileUsecase();
    } catch (error) {
      this.error = 'No pudimos cargar tu perfil.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String bio,
    String? avatarUrl,
  }) async {
    isSaving = true;
    error = null;
    notifyListeners();

    try {
      profile = await _updateProfileUsecase(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      return true;
    } catch (_) {
      error = 'No pudimos guardar los cambios.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> sendPhoneVerificationCode() async {
    isSendingCode = true;
    error = null;
    notifyListeners();

    try {
      await _sendPhoneVerificationCodeUsecase();
      return true;
    } catch (_) {
      error = 'No pudimos enviar el codigo.';
      return false;
    } finally {
      isSendingCode = false;
      notifyListeners();
    }
  }

  Future<bool> verifyPhoneCode(String code) async {
    isVerifyingCode = true;
    error = null;
    notifyListeners();

    try {
      profile = await _verifyPhoneCodeUsecase(code);
      return true;
    } catch (_) {
      error = 'Codigo invalido o expirado.';
      return false;
    } finally {
      isVerifyingCode = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    await _logoutUsecase();
    profile = null;
    notifyListeners();
    return true;
  }
}

typedef EditProfileProvider = ProfileProvider;
