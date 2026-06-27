import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapiafrontend/core/network/api_client.dart';
import 'package:mapiafrontend/core/network/api_endpoints.dart';

class RouteBlockade {
  const RouteBlockade({
    required this.position,
    required this.title,
    required this.category,
    required this.radiusMeters,
  });

  final LatLng position;
  final String title;
  final String category;
  final int radiusMeters;

  factory RouteBlockade.fromJson(Map<String, dynamic> json) {
    return RouteBlockade(
      position: LatLng(
        (json['lat'] as num?)?.toDouble() ?? 0,
        (json['lng'] as num?)?.toDouble() ?? 0,
      ),
      title: json['title'] as String? ?? 'Bloqueo',
      category: json['category'] as String? ?? 'bloqueo',
      radiusMeters: (json['radiusMeters'] as num?)?.toInt() ?? 0,
    );
  }
}

class RouteResult {
  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.avoidedBlockades,
    required this.blockadesOnRoute,
    required this.blockades,
    required this.alternativesCount,
  });

  final List<LatLng> points;
  final int distanceMeters;
  final int durationSeconds;
  final bool avoidedBlockades;
  final int blockadesOnRoute;
  final List<RouteBlockade> blockades;
  final int alternativesCount;

  String get distanceText => distanceMeters >= 1000
      ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
      : '$distanceMeters m';

  String get durationText {
    final min = (durationSeconds / 60).round();
    if (min < 60) return '$min min';
    final h = min ~/ 60;
    final m = min % 60;
    return m == 0 ? '$h h' : '$h h $m min';
  }

  factory RouteResult.fromJson(Map<String, dynamic> json) {
    return RouteResult(
      points: [
        for (final p in (json['points'] as List? ?? const []))
          if (p is Map<String, dynamic>)
            LatLng(
              (p['lat'] as num?)?.toDouble() ?? 0,
              (p['lng'] as num?)?.toDouble() ?? 0,
            ),
      ],
      distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      avoidedBlockades: json['avoidedBlockades'] as bool? ?? false,
      blockadesOnRoute: (json['blockadesOnRoute'] as num?)?.toInt() ?? 0,
      alternativesCount: (json['alternativesCount'] as num?)?.toInt() ?? 0,
      blockades: [
        for (final b in (json['blockades'] as List? ?? const []))
          if (b is Map<String, dynamic>) RouteBlockade.fromJson(b),
      ],
    );
  }
}

class RoutingApi {
  RoutingApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<RouteResult> route({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final json = await _client.postJson(ApiEndpoints.mapRoute, {
      'originLat': origin.latitude,
      'originLng': origin.longitude,
      'destLat': destination.latitude,
      'destLng': destination.longitude,
    });
    return RouteResult.fromJson(json);
  }
}
