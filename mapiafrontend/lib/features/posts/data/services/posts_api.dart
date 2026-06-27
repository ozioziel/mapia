import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:image_picker/image_picker.dart';
import 'package:mapiafrontend/core/network/api_client.dart';
import 'package:mapiafrontend/core/network/api_endpoints.dart';
import 'package:mapiafrontend/features/posts/data/models/post_model.dart';
import 'package:mapiafrontend/features/posts/domain/entities/comment_entity.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class PostsApi {
  PostsApi({ApiClient? client, http.Client? httpClient})
    : _client = client ?? ApiClient(),
      _http = httpClient ?? http.Client();

  final ApiClient _client;
  final http.Client _http;

  MediaType _imageMediaType(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.png')) return MediaType('image', 'png');
    if (n.endsWith('.webp')) return MediaType('image', 'webp');
    return MediaType('image', 'jpeg');
  }

  Future<List<PostEntity>> fetchPosts({int page = 1, int limit = 50}) async {
    final json = await _client.getJson(ApiEndpoints.publications, {
      'page': '$page',
      'limit': '$limit',
    });
    final items = json['data'] as List? ?? const [];
    return [
      for (final item in items)
        if (item is Map<String, dynamic>) PostModel.fromJson(item),
    ];
  }

  /// Crea una publicación real (POST /posts) con imágenes opcionales.
  /// Requiere ApiClient autenticado.
  Future<PostEntity> createPost({
    required String title,
    required String description,
    required PostType type,
    required double latitude,
    required double longitude,
    String? address,
    String? locationName,
    int? radiusMeters,
    bool showOnMap = true,
    List<XFile> images = const [],
  }) async {
    final request = http.MultipartRequest('POST', _client.uri('/posts'));

    final token = _client.accessTokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['type'] = postTypeToApi(type);
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    if (address != null && address.trim().isNotEmpty) {
      request.fields['address'] = address.trim();
    }
    if (locationName != null && locationName.trim().isNotEmpty) {
      request.fields['locationName'] = locationName.trim();
    }
    if (radiusMeters != null) {
      request.fields['radiusMeters'] = radiusMeters.toString();
    }
    request.fields['showOnMap'] = showOnMap.toString();

    for (final image in images) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'images',
          await image.readAsBytes(),
          filename: image.name,
          contentType: _imageMediaType(image.name),
        ),
      );
    }

    final streamed = await _http.send(request).timeout(const Duration(seconds: 40));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        response.body.isEmpty ? 'No se pudo publicar' : response.body,
      );
    }
    return PostModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<PostEntity> createAlertPost({
    required String title,
    required double latitude,
    required double longitude,
    required String alertType,
    required String severity,
    String? description,
    String? address,
    String? locationName,
    int? radiusMeters,
    bool showOnMap = true,
    List<XFile> images = const [],
    String? product,
    String? department,
    String? municipality,
    String? zone,
    double? price,
    String? sourceText,
    double? confidence,
    String? category,
  }) async {
    final request = http.MultipartRequest('POST', _client.uri('/posts'));

    final token = _client.accessTokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['title'] = title;
    request.fields['type'] = 'ALERT';
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['alertType'] = alertType;
    request.fields['severity'] = severity;
    request.fields['showOnMap'] = showOnMap.toString();
    
    if (description != null && description.trim().isNotEmpty) request.fields['description'] = description.trim();
    if (address != null && address.trim().isNotEmpty) request.fields['address'] = address.trim();
    if (locationName != null && locationName.trim().isNotEmpty) request.fields['locationName'] = locationName.trim();
    if (radiusMeters != null) request.fields['radiusMeters'] = radiusMeters.toString();
    if (product != null && product.trim().isNotEmpty) request.fields['product'] = product.trim();
    if (department != null && department.trim().isNotEmpty) request.fields['department'] = department.trim();
    if (municipality != null && municipality.trim().isNotEmpty) request.fields['municipality'] = municipality.trim();
    if (zone != null && zone.trim().isNotEmpty) request.fields['zone'] = zone.trim();
    if (price != null) request.fields['price'] = price.toString();
    if (sourceText != null && sourceText.trim().isNotEmpty) request.fields['sourceText'] = sourceText.trim();
    if (confidence != null) request.fields['confidence'] = confidence.toString();
    if (category != null && category.trim().isNotEmpty) request.fields['category'] = category.trim();

    for (final image in images) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'images',
          await image.readAsBytes(),
          filename: image.name,
          contentType: _imageMediaType(image.name),
        ),
      );
    }

    final streamed = await _http.send(request).timeout(const Duration(seconds: 40));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        response.body.isEmpty ? 'No se pudo publicar alerta' : response.body,
      );
    }
    return PostModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<PostEntity> fetchPostById(String postId) async {
    final json = await _client.getJson(ApiEndpoints.postById(postId));
    return PostModel.fromJson(json);
  }

  Future<List<CommentEntity>> fetchComments(String postId) async {
    final json = await _client.getJson(ApiEndpoints.postComments(postId), {
      'page': '1',
      'limit': '50',
    });
    final items = json['data'] as List? ?? const [];
    return [
      for (final item in items)
        if (item is Map<String, dynamic>) _commentFromJson(postId, item),
    ];
  }

  Future<PostEntity> setReaction(String postId, PostReaction reaction) async {
    await _client.postJson(ApiEndpoints.postReactions(postId), {
      'type': reactionToApi(reaction),
    });
    return fetchPostById(postId);
  }

  Future<PostEntity> removeReaction(String postId) async {
    await _client.delete(ApiEndpoints.postReactions(postId));
    return fetchPostById(postId);
  }

  Future<CommentEntity> createComment(String postId, String content) async {
    final json = await _client.postJson(ApiEndpoints.postComments(postId), {
      'content': content,
    });
    return _commentFromJson(postId, json);
  }

  Future<void> reportFalseInformation(String postId) async {
    await _client.postJson(ApiEndpoints.postReports(postId), {
      'reason': 'FALSE_INFORMATION',
      'description': 'Reportado como informacion falsa desde publicaciones.',
    });
  }

  CommentEntity _commentFromJson(String postId, Map<String, dynamic> json) {
    final author = json['author'];
    final profile = author is Map<String, dynamic> ? author['profile'] : null;
    final authorName = profile is Map<String, dynamic>
        ? _string(profile['name'], fallback: 'Usuario Mapia')
        : 'Usuario Mapia';
    return CommentEntity(
      id: _string(json['id']),
      postId: _string(json['postId'], fallback: postId),
      authorName: authorName,
      authorAvatarUrl: profile is Map<String, dynamic>
          ? _nullableString(profile['avatarUrl'])
          : null,
      content: _string(json['content']),
      createdAt:
          DateTime.tryParse(_string(json['createdAt'])) ?? DateTime.now(),
    );
  }
}

String _string(Object? value, {String fallback = ''}) =>
    value is String && value.isNotEmpty ? value : fallback;

String? _nullableString(Object? value) =>
    value is String && value.isNotEmpty ? value : null;
