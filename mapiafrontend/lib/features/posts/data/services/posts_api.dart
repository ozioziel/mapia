import 'package:mapiafrontend/core/network/api_client.dart';
import 'package:mapiafrontend/core/network/api_endpoints.dart';
import 'package:mapiafrontend/features/posts/data/models/post_model.dart';
import 'package:mapiafrontend/features/posts/domain/entities/comment_entity.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class PostsApi {
  PostsApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

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
