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
