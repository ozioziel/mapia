import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:mapiafrontend/features/auth/data/models/auth_models.dart';

class AuthLocalDatasource {
  const AuthLocalDatasource();

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _userKey = 'auth_user_json';

  Future<AuthSession?> readSession() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);
    final userJson = prefs.getString(_userKey);
    if (accessToken == null ||
        refreshToken == null ||
        userJson == null ||
        userJson.isEmpty) {
      return null;
    }
    try {
      final user = AuthUser.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
      return AuthSession(
        user: user,
        tokens: AuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, session.tokens.accessToken);
    await prefs.setString(_refreshTokenKey, session.tokens.refreshToken);
    await prefs.setString(
      _userKey,
      jsonEncode({
        'id': session.user.id,
        'email': session.user.email,
        'role': session.user.role,
        'username': session.user.username,
        'name': session.user.name,
        'firstName': session.user.firstName,
        'lastName': session.user.lastName,
        'phone': session.user.phone,
        'phoneVerified': session.user.phoneVerified,
      }),
    );
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }
}
