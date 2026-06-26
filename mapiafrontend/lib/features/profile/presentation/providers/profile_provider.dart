import 'package:flutter/foundation.dart';
import 'package:mapiafrontend/features/profile/data/datasources/profile_mock_datasource.dart';
import 'package:mapiafrontend/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';
import 'package:mapiafrontend/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:mapiafrontend/features/profile/domain/usecases/logout_usecase.dart';
import 'package:mapiafrontend/features/profile/domain/usecases/update_profile_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    GetProfileUsecase? getProfileUsecase,
    UpdateProfileUsecase? updateProfileUsecase,
    LogoutUsecase? logoutUsecase,
  }) : _getProfileUsecase = getProfileUsecase ?? _defaultGetProfileUsecase,
       _updateProfileUsecase =
           updateProfileUsecase ?? _defaultUpdateProfileUsecase,
       _logoutUsecase = logoutUsecase ?? _defaultLogoutUsecase;

  static final _repository = ProfileRepositoryImpl(ProfileMockDatasource());
  static final _defaultGetProfileUsecase = GetProfileUsecase(_repository);
  static final _defaultUpdateProfileUsecase = UpdateProfileUsecase(_repository);
  static final _defaultLogoutUsecase = LogoutUsecase(_repository);

  final GetProfileUsecase _getProfileUsecase;
  final UpdateProfileUsecase _updateProfileUsecase;
  final LogoutUsecase _logoutUsecase;

  ProfileEntity? profile;
  bool isLoading = false;
  bool isSaving = false;
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
    required String name,
    required String username,
    required String bio,
    String? avatarUrl,
  }) async {
    isSaving = true;
    error = null;
    notifyListeners();

    try {
      profile = await _updateProfileUsecase(
        name: name,
        username: username,
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
