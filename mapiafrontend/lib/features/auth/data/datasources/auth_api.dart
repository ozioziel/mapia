import 'package:mapiafrontend/core/network/api_client.dart';
import 'package:mapiafrontend/core/network/api_endpoints.dart';
import 'package:mapiafrontend/features/auth/data/models/auth_models.dart';

class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    String? phone,
  }) async {
    final json = await _client.postJson(ApiEndpoints.register, {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    return AuthResponse.fromJson(json);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.postJson(ApiEndpoints.login, {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(json);
  }

  Future<AuthResponse> refresh(String refreshToken) async {
    final json = await _client.postJson(ApiEndpoints.refresh, {
      'refreshToken': refreshToken,
    });
    return AuthResponse.fromJson(json);
  }

  Future<void> logout({required String accessToken}) async {
    await _client.postJson(ApiEndpoints.logout, {}, accessToken: accessToken);
  }

  Future<AuthUser> me({required String accessToken}) async {
    final json = await _client.getJson(ApiEndpoints.me, const {}, accessToken);
    return AuthUser.fromJson(json);
  }
}
