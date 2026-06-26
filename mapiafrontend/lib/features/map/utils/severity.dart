import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapiafrontend/features/map/types/alert_map_types.dart';

Color severityColor(AlertSeverity severity) {
  return switch (severity) {
    AlertSeverity.normal => const Color(0xFF22C55E),
    AlertSeverity.low => const Color(0xFFEAB308),
    AlertSeverity.medium => const Color(0xFFF97316),
    AlertSeverity.high => const Color(0xFFEF4444),
  };
}

double markerHue(AlertSeverity severity) {
  return switch (severity) {
    AlertSeverity.normal => BitmapDescriptor.hueGreen,
    AlertSeverity.low => BitmapDescriptor.hueYellow,
    AlertSeverity.medium => BitmapDescriptor.hueOrange,
    AlertSeverity.high => BitmapDescriptor.hueRed,
  };
}
