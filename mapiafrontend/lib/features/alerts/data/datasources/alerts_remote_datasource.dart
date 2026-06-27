import 'dart:math' as math;

import 'package:mapiafrontend/core/utils/distance_utils.dart';
import 'package:mapiafrontend/features/alerts/data/models/nearby_alert_group_model.dart';
import 'package:mapiafrontend/features/alerts/domain/entities/nearby_alert_group_entity.dart';
import 'package:mapiafrontend/features/location/domain/entities/location_entity.dart';
import 'package:mapiafrontend/features/map/domain/entities/map_publication_marker_entity.dart';
import 'package:mapiafrontend/features/map/services/map_api.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

/// Datasource real de "alertas cercanas": agrupa publicaciones reales del
/// backend (vía /map/publications) por categoría, filtrando por distancia.
class AlertsRemoteDatasource {
  const AlertsRemoteDatasource({required MapApi mapApi}) : _mapApi = mapApi;

  final MapApi _mapApi;

  Future<List<MapPublicationMarkerEntity>> _nearby(
    AppLocationEntity location,
    double radiusKm,
  ) async {
    final dLat = radiusKm / 111.0;
    final cosLat = math.cos(location.latitude * math.pi / 180).abs();
    final dLng = radiusKm / (111.0 * (cosLat < 0.01 ? 0.01 : cosLat));

    final publications = await _mapApi.fetchPublications(
      north: location.latitude + dLat,
      south: location.latitude - dLat,
      east: location.longitude + dLng,
      west: location.longitude - dLng,
    );

    return publications.where((p) {
      final km = calculateDistanceKm(
        lat1: location.latitude,
        lon1: location.longitude,
        lat2: p.latitude,
        lon2: p.longitude,
      );
      return km <= radiusKm;
    }).toList();
  }

  Future<List<NearbyAlertGroupEntity>> getNearbyAlertGroups({
    required AppLocationEntity location,
    required double radiusKm,
  }) async {
    final items = await _nearby(location, radiusKm);
    final counts = <PostType, int>{};
    for (final item in items) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }
    final groups = [
      for (final entry in counts.entries)
        NearbyAlertGroupModel.fromPosts(
          type: entry.key,
          count: entry.value,
          radiusKm: radiusKm,
        ),
    ];
    groups.sort((a, b) => b.count.compareTo(a.count));
    return groups;
  }

  Future<List<PostEntity>> getNearbyPostsByType({
    required PostType type,
    required AppLocationEntity location,
    required double radiusKm,
  }) async {
    final items = await _nearby(location, radiusKm);
    return items
        .where((item) => item.category == type)
        .map((item) => item.toPreviewPost())
        .toList();
  }
}
