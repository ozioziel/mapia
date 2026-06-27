import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:image_picker/image_picker.dart';
import 'package:mapiafrontend/core/network/api_client.dart';
import 'package:mapiafrontend/core/network/api_endpoints.dart';

class ProfileApi {
  ProfileApi({required ApiClient client}) : _client = client;

  final ApiClient _client;

  Future<Map<String, dynamic>> getProfile() {
    return _client.getJson(ApiEndpoints.profileMe);
  }

  Future<Map<String, dynamic>> patchProfile(Map<String, dynamic> body) {
    return _client.patchJson(ApiEndpoints.profileMe, body);
  }

  Future<Map<String, dynamic>> uploadAvatar(XFile image) async {
    final request = http.MultipartRequest(
      'POST',
      _client.uri(ApiEndpoints.profileAvatar),
    );
    final token = _client.accessTokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        await image.readAsBytes(),
        filename: image.name,
        contentType: _imageMediaType(image.name),
      ),
    );

    late final http.Response response;
    try {
      final streamed = await request.send().timeout(
        const Duration(seconds: 20),
      );
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const ApiException('Tiempo de espera agotado al subir avatar.', 0);
    } catch (_) {
      throw const ApiException('No se pudo subir el avatar.', 0);
    }

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        decoded['message'] as String? ?? 'No se pudo subir el avatar.',
        response.statusCode,
      );
    }
    return decoded;
  }

  Future<void> sendPhoneCode(String phone) async {
    await _client.postJson(ApiEndpoints.profilePhoneSend, {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyPhoneCode(String code) {
    return _client.postJson(ApiEndpoints.profilePhoneVerify, {'code': code});
  }

  Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    final json = await _client.getJson(ApiEndpoints.myPosts, {
      'limit': '20',
      'page': '1',
    });
    final data = json['data'] as List? ?? const [];
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) item,
    ];
  }
}

MediaType _imageMediaType(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return MediaType('image', 'png');
  if (lower.endsWith('.webp')) return MediaType('image', 'webp');
  return MediaType('image', 'jpeg');
}
