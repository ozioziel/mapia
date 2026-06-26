import 'package:flutter/foundation.dart';
import 'package:mapiafrontend/features/profile/data/datasources/profile_mock_datasource.dart';
import 'package:mapiafrontend/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';
import 'package:mapiafrontend/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:mapiafrontend/features/profile/domain/usecases/logout_usecase.dart';
import 'package:mapiafrontend/features/profile/domain/usecases/send_phone_verification_code_usecase.dart';
import 'package:mapiafrontend/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:mapiafrontend/features/profile/domain/usecases/verify_phone_code_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    GetProfileUsecase? getProfileUsecase,
    UpdateProfileUsecase? updateProfileUsecase,
    LogoutUsecase? logoutUsecase,
    SendPhoneVerificationCodeUsecase? sendPhoneVerificationCodeUsecase,
    VerifyPhoneCodeUsecase? verifyPhoneCodeUsecase,
  }) : _getProfileUsecase = getProfileUsecase ?? _defaultGetProfileUsecase,
       _updateProfileUsecase =
           updateProfileUsecase ?? _defaultUpdateProfileUsecase,
       _logoutUsecase = logoutUsecase ?? _defaultLogoutUsecase,
       _sendPhoneVerificationCodeUsecase =
           sendPhoneVerificationCodeUsecase ??
           _defaultSendPhoneVerificationCodeUsecase,
       _verifyPhoneCodeUsecase =
           verifyPhoneCodeUsecase ?? _defaultVerifyPhoneCodeUsecase;

  static final _repository = ProfileRepositoryImpl(ProfileMockDatasource());
  static final _defaultGetProfileUsecase = GetProfileUsecase(_repository);
  static final _defaultUpdateProfileUsecase = UpdateProfileUsecase(_repository);
  static final _defaultLogoutUsecase = LogoutUsecase(_repository);
  static final _defaultSendPhoneVerificationCodeUsecase =
      SendPhoneVerificationCodeUsecase(_repository);
  static final _defaultVerifyPhoneCodeUsecase = VerifyPhoneCodeUsecase(
    _repository,
  );

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
    notifyListeners();

    try {
      profile = await _getProfileUsecase();
    } catch (_) {
      error = 'No pudimos cargar tu perfil.';
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
    isSaving = true;
    error = null;
    notifyListeners();

    try {
      await _logoutUsecase();
      return true;
    } catch (_) {
      error = 'No pudimos cerrar sesion.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}

typedef EditProfileProvider = ProfileProvider;
