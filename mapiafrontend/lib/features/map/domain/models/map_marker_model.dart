import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapiafrontend/features/map/domain/models/map_filter_model.dart';

enum MapPointSourceType {
  backendAlert,
  backendNews,
  backendPost,
  backendRoute,
  backendPlace,
}

class MapMarkerModel {
  const MapMarkerModel({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.sourceType,
    this.description,
    this.imageUrl,
    this.createdAt,
    this.metadata = const {},
  });

  final String id;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final MapFilterCategory category;
  final MapPointSourceType sourceType;
  final String? imageUrl;
  final DateTime? createdAt;
  final Map<String, Object?> metadata;

  LatLng get position => LatLng(latitude, longitude);
}
