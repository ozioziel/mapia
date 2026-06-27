import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapiafrontend/features/posts/data/models/post_model.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class MapPublicationMarkerEntity {
  const MapPublicationMarkerEntity({
    required this.publicationId,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.category,
    this.userProfileImageUrl,
    this.userReputation,
    this.markerType = 'publication',
  });

  final String publicationId;
  final String title;
  final double latitude;
  final double longitude;
  final String userId;
  final String userName;
  final String? userProfileImageUrl;
  final int? userReputation;
  final DateTime createdAt;
  final PostType category;
  final String markerType;

  LatLng get position => LatLng(latitude, longitude);

  factory MapPublicationMarkerEntity.fromJson(Map<String, dynamic> json) {
    return MapPublicationMarkerEntity(
      publicationId: _string(json['publicationId']),
      title: _string(json['title'], fallback: 'Publicacion'),
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      userId: _string(json['userId']),
      userName: _string(json['userName'], fallback: 'Usuario Mapia'),
      userProfileImageUrl: _nullableString(json['userProfileImageUrl']),
      userReputation: _nullableInt(json['userReputation']),
      createdAt:
          DateTime.tryParse(_string(json['createdAt'])) ?? DateTime.now(),
      category: postTypeFromApi(_string(json['category'])),
      markerType: _string(json['markerType'], fallback: 'publication'),
    );
  }

  PostEntity toPreviewPost() {
    return PostEntity(
      id: publicationId,
      title: title,
      description: '',
      type: category,
      authorName: userName,
      authorAvatarUrl: userProfileImageUrl,
      authorReputation: userReputation,
      latitude: latitude,
      longitude: longitude,
      likesCount: 0,
      commentsCount: 0,
      isLiked: false,
      isVerified: false,
      createdAt: createdAt,
    );
  }
}

String _string(Object? value, {String fallback = ''}) =>
    value is String && value.isNotEmpty ? value : fallback;

String? _nullableString(Object? value) =>
    value is String && value.isNotEmpty ? value : null;

double _double(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int? _nullableInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
