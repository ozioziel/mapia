import 'package:mapiafrontend/core/network/api_client.dart';
import 'package:mapiafrontend/core/network/api_endpoints.dart';
import 'package:mapiafrontend/features/map/domain/entities/map_publication_marker_entity.dart';
import 'package:mapiafrontend/features/map/types/alert_map_types.dart';

class MapApi {
  MapApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<AlertMapItem>> fetchAlerts(AlertFilters filters) async {
    final json = await _client.getJson(
      ApiEndpoints.mapAlerts,
      filters.toQuery(),
    );
    final items = json['items'] as List? ?? const [];
    return [
      for (final item in items)
        if (item is Map<String, dynamic>) AlertMapItem.fromJson(item),
    ];
  }

  Future<List<MapPublicationMarkerEntity>> fetchPublications({
    double? north,
    double? south,
    double? east,
    double? west,
  }) async {
    final json = await _client.getJson(ApiEndpoints.mapPublications, {
      'north': north?.toString(),
      'south': south?.toString(),
      'east': east?.toString(),
      'west': west?.toString(),
    });
    final items = json['items'] as List? ?? const [];
    return [
      for (final item in items)
        if (item is Map<String, dynamic>)
          MapPublicationMarkerEntity.fromJson(item),
    ];
  }

  Future<AlertMapSummary> fetchSummary(AlertFilters filters) async {
    final json = await _client.getJson(
      ApiEndpoints.mapSummary,
      filters.toQuery(),
    );
    return AlertMapSummary.fromJson(json);
  }

  Future<AlertFilterOptions> fetchFilters() async {
    final json = await _client.getJson(ApiEndpoints.mapFilters);
    return AlertFilterOptions.fromJson(json);
  }
}
