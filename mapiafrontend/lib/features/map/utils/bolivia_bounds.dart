import 'package:google_maps_flutter/google_maps_flutter.dart';

const boliviaCenter = LatLng(-16.2902, -63.5887);

const boliviaBounds = LatLngBounds(
  southwest: LatLng(-22.9, -69.7),
  northeast: LatLng(-9.6, -57.4),
);

bool isInsideBolivia(double lat, double lng) {
  return lat >= -22.9 && lat <= -9.6 && lng >= -69.7 && lng <= -57.4;
}
