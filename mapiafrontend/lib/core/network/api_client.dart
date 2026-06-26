import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mapiafrontend/core/config/app_config.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  static const _timeout = Duration(seconds: 12);

  final http.Client _http;

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
  ]) async {
    final requestUri = uri(path, query);
    try {
      final response = await _http.get(requestUri).timeout(_timeout);
      return _decode(response);
    } on TimeoutException {
      throw ApiException('Tiempo de espera agotado: $requestUri', 0);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('No se pudo conectar con $requestUri', 0);
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final requestUri = uri(path);
    try {
      final response = await _http
          .post(
            requestUri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _decode(response);
    } on TimeoutException {
      throw ApiException('Tiempo de espera agotado: $requestUri', 0);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('No se pudo conectar con $requestUri', 0);
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    var decoded = <String, dynamic>{};
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body) as Map<String, dynamic>;
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
