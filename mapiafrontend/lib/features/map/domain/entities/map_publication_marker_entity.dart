import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapiafrontend/features/posts/data/models/post_model.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class MapPublicationMarkerEntity {
  const MapPublicationMarkerEntity({
    required this.publicationId,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.showOnMap,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.category,
    this.userProfileImageUrl,
    this.userReputation,
    this.address,
    this.locationName,
    this.markerType = 'publication',
  });

  final String publicationId;
  final String title;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final bool showOnMap;
  final String userId;
  final String userName;
  final String? userProfileImageUrl;
  final int? userReputation;
  final String? address;
  final String? locationName;
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
      radiusMeters: _int(json['radiusMeters']),
      showOnMap: json['showOnMap'] != false,
      userId: _string(json['userId']),
      userName: _string(json['userName'], fallback: 'Usuario Mapia'),
      userProfileImageUrl: _nullableString(json['userProfileImageUrl']),
      userReputation: _nullableInt(json['userReputation']),
      address: _nullableString(json['address']),
      locationName: _nullableString(json['locationName']),
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
      radiusMeters: radiusMeters,
      showOnMap: showOnMap,
      address: address,
      locationName: locationName,
      likesCount: 0,
      dislikesCount: 0,
      commentsCount: 0,
      reportsCount: 0,
      isLiked: false,
      userReaction: PostReaction.none,
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

int _int(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
