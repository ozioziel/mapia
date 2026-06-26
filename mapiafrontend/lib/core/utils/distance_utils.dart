import 'dart:math' as math;

double calculateDistanceKm({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
}) {
  const earthRadiusKm = 6371.0;
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final startLat = _toRadians(lat1);
  final endLat = _toRadians(lat2);

  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(startLat) *
          math.cos(endLat) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadiusKm * c;
}

double _toRadians(double degrees) => degrees * math.pi / 180;
