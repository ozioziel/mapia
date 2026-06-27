import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class PostModel {
  const PostModel._();

  static PostEntity fromJson(Map<String, dynamic> json) {
    final author = json['author'];
    final media = json['media'] as List? ?? const [];
    Map<String, dynamic>? firstMedia;
    for (final item in media) {
      if (item is Map<String, dynamic>) {
        firstMedia = item;
        break;
      }
    }

    return PostEntity(
      id: _string(json['id']),
      title: _string(json['title'], fallback: 'Publicacion'),
      description: _string(json['description']),
      type: postTypeFromApi(_string(json['type'])),
      authorName: author is Map<String, dynamic>
          ? _string(author['name'], fallback: 'Usuario Mapia')
          : 'Usuario Mapia',
      authorAvatarUrl: author is Map<String, dynamic>
          ? _nullableString(author['avatarUrl'])
          : null,
      authorReputation: author is Map<String, dynamic>
          ? _nullableInt(author['reputation'])
          : null,
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      address: _nullableString(json['address']),
      mediaUrl: firstMedia == null ? null : _nullableString(firstMedia['url']),
      mediaType: firstMedia == null
          ? PostMediaType.none
          : mediaTypeFromApi(_string(firstMedia['type'])),
      likesCount: _int(json['likesCount']),
      commentsCount: _int(json['commentsCount']),
      isLiked: json['isLiked'] == true,
      isVerified: json['isVerified'] == true,
      createdAt:
          DateTime.tryParse(_string(json['createdAt'])) ?? DateTime.now(),
    );
  }
}

PostType postTypeFromApi(String value) {
  return switch (value.toUpperCase()) {
    'NEWS' => PostType.news,
    'NOVELTY' => PostType.novelty,
    'PARTY' => PostType.party,
    'FOOD_DEAL' => PostType.foodDeal,
    'SALE' => PostType.sale,
    'TRAFFIC' => PostType.traffic,
    'BLOCKADE' => PostType.blockade,
    'ACCIDENT' => PostType.accident,
    'SERVICE_CUT' => PostType.serviceCut,
    'SECURITY' => PostType.security,
    'LOST_FOUND' => PostType.lostFound,
    _ => PostType.other,
  };
}

String postTypeToApi(PostType type) {
  return switch (type) {
    PostType.news => 'NEWS',
    PostType.novelty => 'NOVELTY',
    PostType.party => 'PARTY',
    PostType.foodDeal => 'FOOD_DEAL',
    PostType.sale => 'SALE',
    PostType.traffic => 'TRAFFIC',
    PostType.blockade => 'BLOCKADE',
    PostType.accident => 'ACCIDENT',
    PostType.serviceCut => 'SERVICE_CUT',
    PostType.security => 'SECURITY',
    PostType.lostFound => 'LOST_FOUND',
    PostType.other => 'OTHER',
  };
}

PostMediaType mediaTypeFromApi(String value) {
  return switch (value.toUpperCase()) {
    'IMAGE' => PostMediaType.image,
    'VIDEO' => PostMediaType.video,
    _ => PostMediaType.none,
  };
}

String _string(Object? value, {String fallback = ''}) =>
    value is String && value.isNotEmpty ? value : fallback;

String? _nullableString(Object? value) =>
    value is String && value.isNotEmpty ? value : null;

double _double(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _int(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _nullableInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
