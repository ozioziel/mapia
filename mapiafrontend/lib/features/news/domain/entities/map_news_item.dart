import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MapNewsCategory {
  bloqueo,
  accidente,
  seguridad,
  transporte,
  clima,
  desastre,
  servicios,
  ambiente,
  evento,
  otroRelevante,
}

class MapNewsItem {
  const MapNewsItem({
    required this.id,
    required this.title,
    required this.publishedAt,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.createdBy,
    required this.locationStatus,
    this.description,
    this.source,
    this.url,
    this.locationText,
  });

  final String id;
  final String title;
  final String? description;
  final String? source;
  final String? url;
  final DateTime publishedAt;
  final String? locationText;
  final double latitude;
  final double longitude;
  final MapNewsCategory category;
  final String createdBy;
  final String locationStatus;

  LatLng get position => LatLng(latitude, longitude);

  factory MapNewsItem.fromJson(Map<String, dynamic> json) {
    return MapNewsItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Novedad',
      description: json['description'] as String?,
      source: json['source'] as String?,
      url: json['url'] as String?,
      publishedAt:
          DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
          DateTime.now(),
      locationText: json['locationText'] as String?,
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
      category: mapNewsCategoryFromApi(json['category'] as String?),
      createdBy: json['createdBy'] as String? ?? 'rss',
      locationStatus: json['locationStatus'] as String? ?? 'localized',
    );
  }
}

extension MapNewsCategoryUi on MapNewsCategory {
  String get apiValue => switch (this) {
    MapNewsCategory.bloqueo => 'bloqueo',
    MapNewsCategory.accidente => 'accidente',
    MapNewsCategory.seguridad => 'seguridad',
    MapNewsCategory.transporte => 'transporte',
    MapNewsCategory.clima => 'clima',
    MapNewsCategory.desastre => 'desastre',
    MapNewsCategory.servicios => 'servicios',
    MapNewsCategory.ambiente => 'ambiente',
    MapNewsCategory.evento => 'evento',
    MapNewsCategory.otroRelevante => 'otro_relevante',
  };

  String get label => switch (this) {
    MapNewsCategory.bloqueo => 'Bloqueo',
    MapNewsCategory.accidente => 'Accidente',
    MapNewsCategory.seguridad => 'Seguridad',
    MapNewsCategory.transporte => 'Transporte',
    MapNewsCategory.clima => 'Clima',
    MapNewsCategory.desastre => 'Emergencia',
    MapNewsCategory.servicios => 'Servicios',
    MapNewsCategory.ambiente => 'Ambiente',
    MapNewsCategory.evento => 'Evento',
    MapNewsCategory.otroRelevante => 'Novedad',
  };

  double get markerHue => switch (this) {
    MapNewsCategory.bloqueo => BitmapDescriptor.hueOrange,
    MapNewsCategory.accidente => BitmapDescriptor.hueRed,
    MapNewsCategory.seguridad => BitmapDescriptor.hueMagenta,
    MapNewsCategory.transporte => BitmapDescriptor.hueBlue,
    MapNewsCategory.clima => BitmapDescriptor.hueCyan,
    MapNewsCategory.desastre => BitmapDescriptor.hueMagenta,
    MapNewsCategory.servicios => BitmapDescriptor.hueYellow,
    MapNewsCategory.ambiente => BitmapDescriptor.hueGreen,
    MapNewsCategory.evento => BitmapDescriptor.hueViolet,
    MapNewsCategory.otroRelevante => BitmapDescriptor.hueAzure,
  };
}

MapNewsCategory mapNewsCategoryFromApi(String? value) {
  return MapNewsCategory.values.firstWhere(
    (category) => category.apiValue == value,
    orElse: () => MapNewsCategory.otroRelevante,
  );
}
