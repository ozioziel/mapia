import 'package:mapiafrontend/core/network/api_client.dart';

class PlaceSuggestion {
  const PlaceSuggestion({required this.placeId, required this.description});
  final String placeId;
  final String description;

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) => PlaceSuggestion(
    placeId: json['placeId'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );
}

class PlaceDetails {
  const PlaceDetails({
    required this.lat,
    required this.lng,
    required this.name,
    required this.address,
  });
  final double lat;
  final double lng;
  final String name;
  final String address;

  factory PlaceDetails.fromJson(Map<String, dynamic> json) => PlaceDetails(
    lat: (json['lat'] as num?)?.toDouble() ?? 0,
    lng: (json['lng'] as num?)?.toDouble() ?? 0,
    name: json['name'] as String? ?? '',
    address: json['address'] as String? ?? '',
  );
}

/// Búsqueda de lugares y reverse geocoding (la API key vive en el backend).
class PlacesApi {
  PlacesApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<PlaceSuggestion>> autocomplete(
    String query, {
    double? lat,
    double? lng,
  }) async {
    final json = await _client.getJson('/map/places/autocomplete', {
      'q': query,
      'lat': lat?.toString(),
      'lng': lng?.toString(),
    });
    final items = json['items'] as List? ?? const [];
    return [
      for (final it in items)
        if (it is Map<String, dynamic>) PlaceSuggestion.fromJson(it),
    ];
  }

  Future<PlaceDetails> details(String placeId) async {
    final json = await _client.getJson('/map/places/details', {
      'placeId': placeId,
    });
    return PlaceDetails.fromJson(json);
  }

  Future<String> reverseGeocode(double lat, double lng) async {
    final json = await _client.getJson('/map/geocode/reverse', {
      'lat': lat.toString(),
      'lng': lng.toString(),
    });
    return json['address'] as String? ?? '';
  }
}
