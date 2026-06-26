import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MapNewsCategory { evento, bloqueo, corteServicio, venta, noticia }

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
    MapNewsCategory.evento => 'evento',
    MapNewsCategory.bloqueo => 'bloqueo',
    MapNewsCategory.corteServicio => 'corte_servicio',
    MapNewsCategory.venta => 'venta',
    MapNewsCategory.noticia => 'noticia',
  };

  String get label => switch (this) {
    MapNewsCategory.evento => 'Evento',
    MapNewsCategory.bloqueo => 'Bloqueo',
    MapNewsCategory.corteServicio => 'Corte de servicio',
    MapNewsCategory.venta => 'Venta',
    MapNewsCategory.noticia => 'Noticia',
  };

  double get markerHue => switch (this) {
    MapNewsCategory.evento => BitmapDescriptor.hueViolet,
    MapNewsCategory.bloqueo => BitmapDescriptor.hueOrange,
    MapNewsCategory.corteServicio => BitmapDescriptor.hueYellow,
    MapNewsCategory.venta => BitmapDescriptor.hueGreen,
    MapNewsCategory.noticia => BitmapDescriptor.hueAzure,
  };
}

MapNewsCategory mapNewsCategoryFromApi(String? value) {
  return MapNewsCategory.values.firstWhere(
    (category) => category.apiValue == value,
    orElse: () => MapNewsCategory.noticia,
  );
}
