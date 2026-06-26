
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mapiafrontend/core/config/app_config.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

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
    final response = await _http.get(uri(path, query));
    return _decode(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _http.post(
      uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
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
