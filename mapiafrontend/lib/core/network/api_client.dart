import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mapiafrontend/core/config/app_config.dart';

typedef TokenRefreshCallback = Future<String?> Function();

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? Function()? accessTokenProvider,
    TokenRefreshCallback? onUnauthorized,
  }) : _http = httpClient ?? http.Client(),
       _accessTokenProvider = accessTokenProvider,
       _onUnauthorized = onUnauthorized;

  static const _timeout = Duration(seconds: 12);

  final http.Client _http;
  final String? Function()? _accessTokenProvider;
  final TokenRefreshCallback? _onUnauthorized;

  String? Function()? get accessTokenProvider => _accessTokenProvider;

  Uri uri(String path, [Map<String, String?> query = const {}]) {
    final base = Uri.parse(AppConfig.apiBaseUrl);
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final basePath = base.path.endsWith('/') ? base.path : '${base.path}/';
    return base.replace(
      path: '$basePath$cleanPath',
      queryParameters: {
        for (final entry in query.entries)
          if (entry.value != null && entry.value!.trim().isNotEmpty)
            entry.key: entry.value,
      },
    );
  }

  Future<Map<String, dynamic>> getJson(
    String path, [
    Map<String, String?> query = const {},
    String? accessToken,
  ]) async {
    return _request(
      method: 'GET',
      path: path,
      query: query,
      accessToken: accessToken,
    );
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    String? accessToken,
  }) async {
    return _request(
      method: 'POST',
      path: path,
      body: body,
      accessToken: accessToken,
    );
  }

  Future<Map<String, dynamic>> patchJson(
    String path,
    Map<String, dynamic> body, {
    String? accessToken,
  }) async {
    return _request(
      method: 'PATCH',
      path: path,
      body: body,
      accessToken: accessToken,
    );
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    String? accessToken,
  }) async {
    return _request(method: 'DELETE', path: path, accessToken: accessToken);
  }

  Future<Map<String, dynamic>> _request({
    required String method,
    required String path,
    Map<String, String?> query = const {},
    Map<String, dynamic>? body,
    String? accessToken,
    bool retried = false,
  }) async {
    final requestUri = uri(path, query);
    final token = accessToken ?? _accessTokenProvider?.call();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await _send(method, requestUri, headers, body);
      if (response.statusCode == 401 &&
          !retried &&
          _onUnauthorized != null &&
          accessToken == null) {
        final newToken = await _onUnauthorized();
        if (newToken != null && newToken.isNotEmpty) {
          return _request(
            method: method,
            path: path,
            query: query,
            body: body,
            accessToken: newToken,
            retried: true,
          );
        }
      }
      return _decode(response);
    } on TimeoutException {
      throw ApiException('Tiempo de espera agotado: $requestUri', 0);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('No se pudo conectar con $requestUri', 0);
    }
  }

  Future<http.Response> _send(
    String method,
    Uri requestUri,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) async {
    switch (method) {
      case 'GET':
        return _http.get(requestUri, headers: headers).timeout(_timeout);
      case 'DELETE':
        return _http.delete(requestUri, headers: headers).timeout(_timeout);
      case 'PATCH':
        return _http
            .patch(
              requestUri,
              headers: headers,
              body: body == null ? null : jsonEncode(body),
            )
            .timeout(_timeout);
      case 'POST':
      default:
        return _http
            .post(
              requestUri,
              headers: headers,
              body: body == null ? null : jsonEncode(body),
            )
            .timeout(_timeout);
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    var decoded = <String, dynamic>{};
    if (response.body.isNotEmpty) {
      try {
        final raw = jsonDecode(response.body);
        if (raw is Map<String, dynamic>) {
          decoded = raw;
        }
      } catch (_) {
        decoded = {'message': response.body};
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded['message'];
      throw ApiException(
        message is String ? message : 'No se pudo completar la solicitud',
        response.statusCode,
      );
    }
    return decoded;
  }
}

class ApiException implements Exception {
  const ApiException(this.message, this.statusCode);

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
