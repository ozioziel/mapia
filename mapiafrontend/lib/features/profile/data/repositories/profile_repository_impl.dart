import 'package:mapiafrontend/features/profile/data/datasources/profile_mock_datasource.dart';
import 'package:mapiafrontend/features/profile/data/models/profile_model.dart';
import 'package:mapiafrontend/features/profile/data/services/otp_service.dart';
import 'package:mapiafrontend/features/profile/domain/entities/profile_entity.dart';
import 'package:mapiafrontend/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._datasource, {OtpService? otpService})
    : _otpService = otpService ?? OtpService();

  final ProfileMockDatasource _datasource;
  final OtpService _otpService;

  @override
  Future<ProfileEntity> getProfile() {
    return _datasource.getProfile();
  }

  @override
  Future<ProfileEntity> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String bio,
    String? avatarUrl,
  }) async {
    final current = await _datasource.getProfile();
    final normalizedPhone = phone.trim();
    final phoneChanged = current.phone.trim() != normalizedPhone;

    return _datasource.updateProfile(
      ProfileModel.fromEntity(
        current.copyWith(
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          phone: normalizedPhone,
          phoneVerified: phoneChanged ? false : current.phoneVerified,
          bio: bio.trim(),
          avatarUrl: avatarUrl,
        ),
      ),
    );
  }

  @override
  Future<void> sendPhoneVerificationCode() async {
    final current = await _datasource.getProfile();
    return _otpService.sendCode(current.phone);
  }

  @override
  Future<ProfileEntity> verifyPhoneCode(String code) async {
    final current = await _datasource.getProfile();
    final valid = await _otpService.verifyCode(
      phone: current.phone,
      code: code,
    );
    if (!valid) {
      throw StateError('Codigo OTP invalido o expirado.');
    }
    return _datasource.markPhoneVerified();
  }

  @override
  Future<void> logout() {
    return _datasource.clearSession();
  }
}
