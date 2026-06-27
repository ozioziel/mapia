import 'package:flutter/foundation.dart';
import 'package:mapiafrontend/features/auth/data/datasources/auth_api.dart';
import 'package:mapiafrontend/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mapiafrontend/features/auth/data/models/auth_models.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthApi? authApi, AuthLocalDatasource? localDatasource})
    : _authApi = authApi ?? AuthApi(),
      _localDatasource = localDatasource ?? const AuthLocalDatasource();

  final AuthApi _authApi;
  final AuthLocalDatasource _localDatasource;

  AuthSession? _session;
  bool _isLoading = true;
  String? _error;

  AuthSession? get session => _session;
  AuthUser? get user => _session?.user;
  String? get accessToken => _session?.tokens.accessToken;
  bool get isAuthenticated => _session != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> bootstrap() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final stored = await _localDatasource.readSession();
    if (stored == null) {
      _session = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final user = await _authApi.me(accessToken: stored.tokens.accessToken);
      _session = AuthSession(user: user, tokens: stored.tokens);
      await _localDatasource.saveSession(_session!);
    } catch (_) {
      try {
        final refreshed = await _authApi.refresh(stored.tokens.refreshToken);
        _session = AuthSession(user: refreshed.user, tokens: refreshed.tokens);
        await _localDatasource.saveSession(_session!);
      } catch (_) {
        await _localDatasource.clearSession();
        _session = null;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _error = null;
    notifyListeners();
    try {
      final response = await _authApi.login(email: email, password: password);
      _session = AuthSession(user: response.user, tokens: response.tokens);
      await _localDatasource.saveSession(_session!);
      notifyListeners();
      return true;
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    String? phone,
  }) async {
    _error = null;
    notifyListeners();
    try {
      final response = await _authApi.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        username: username,
        phone: phone,
      );
      _session = AuthSession(user: response.user, tokens: response.tokens);
      await _localDatasource.saveSession(_session!);
      notifyListeners();
      return true;
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<String?> refreshAccessToken() async {
    final refreshToken = _session?.tokens.refreshToken;
    if (refreshToken == null) return null;
    try {
      final response = await _authApi.refresh(refreshToken);
      _session = AuthSession(user: response.user, tokens: response.tokens);
      await _localDatasource.saveSession(_session!);
      notifyListeners();
      return _session!.tokens.accessToken;
    } catch (_) {
      await logout();
      return null;
    }
  }

  Future<void> logout() async {
    final token = _session?.tokens.accessToken;
    if (token != null) {
      try {
        await _authApi.logout(accessToken: token);
      } catch (_) {}
    }
    await _localDatasource.clearSession();
    _session = null;
    notifyListeners();
  }
}
