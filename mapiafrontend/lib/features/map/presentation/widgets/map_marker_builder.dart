import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapiafrontend/features/map/domain/entities/map_publication_marker_entity.dart';
import 'package:mapiafrontend/features/map/types/alert_map_types.dart';
import 'package:mapiafrontend/features/map/utils/alert_marker_icons.dart';
import 'package:mapiafrontend/features/map/utils/severity.dart';
import 'package:mapiafrontend/features/news/domain/entities/map_news_item.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class MapMarkerBuilder {
  const MapMarkerBuilder({
    required this.alerts,
    required this.news,
    required this.publications,
    required this.selectedAlert,
    required this.selectedNews,
    required this.selectedPublication,
    required this.alertMarkerIcons,
    required this.onAlertSelected,
    required this.onNewsSelected,
    required this.onPublicationSelected,
  });

  final List<AlertMapItem> alerts;
  final List<MapNewsItem> news;
  final List<MapPublicationMarkerEntity> publications;
  final AlertMapItem? selectedAlert;
  final MapNewsItem? selectedNews;
  final MapPublicationMarkerEntity? selectedPublication;
  final AlertMapMarkerIcons? alertMarkerIcons;
  final ValueChanged<AlertMapItem> onAlertSelected;
  final ValueChanged<MapNewsItem> onNewsSelected;
  final ValueChanged<MapPublicationMarkerEntity> onPublicationSelected;

  Set<Marker> markers() {
    return {
      for (final alert in alerts) _alertMarker(alert),
      for (final item in news) _newsMarker(item),
      for (final item in publications) _publicationMarker(item),
    };
  }

  Set<Circle> circles() {
    return {
      for (final alert in alerts) _alertCircle(alert),
      for (final item in news) _newsCircle(item),
      for (final item in publications) _publicationCircle(item),
    };
  }

  Marker _alertMarker(AlertMapItem alert) {
    return Marker(
      markerId: MarkerId('alert_${alert.id}'),
      position: alert.position,
      infoWindow: InfoWindow(
        title: alert.isMine ? 'Tu evento: ${alert.title}' : alert.title,
        snippet: alert.product ?? alert.alertType.label,
      ),
      icon:
          alertMarkerIcons?.iconFor(alert.alertType, isMine: alert.isMine) ??
          BitmapDescriptor.defaultMarkerWithHue(
            alert.isMine
                ? BitmapDescriptor.hueAzure
                : markerHue(alert.severity),
          ),
      onTap: () => onAlertSelected(alert),
    );
  }

  Marker _newsMarker(MapNewsItem item) {
    return Marker(
      markerId: MarkerId('news_${item.id}'),
      position: item.position,
      infoWindow: InfoWindow(title: item.title, snippet: item.category.label),
      icon: BitmapDescriptor.defaultMarkerWithHue(item.category.markerHue),
      onTap: () => onNewsSelected(item),
    );
  }

  Marker _publicationMarker(MapPublicationMarkerEntity item) {
    return Marker(
      markerId: MarkerId('publication_${item.publicationId}'),
      position: item.position,
      infoWindow: InfoWindow.noText,
      icon: BitmapDescriptor.defaultMarkerWithHue(_postHue(item.category)),
      onTap: () => onPublicationSelected(item),
    );
  }

  Circle _alertCircle(AlertMapItem alert) {
    final isSelected = selectedAlert?.id == alert.id;
    return Circle(
      circleId: CircleId('alert_circle_${alert.id}'),
      center: alert.position,
      radius: isSelected ? 760 : 520,
      fillColor: severityColor(
        alert.severity,
      ).withValues(alpha: isSelected ? 0.32 : 0.22),
      strokeColor: Colors.white,
      strokeWidth: isSelected ? 4 : 3,
      consumeTapEvents: true,
      onTap: () => onAlertSelected(alert),
    );
  }

  Circle _newsCircle(MapNewsItem item) {
    final isSelected = selectedNews?.id == item.id;
    return Circle(
      circleId: CircleId('news_circle_${item.id}'),
      center: item.position,
      radius: isSelected ? 620 : 420,
      fillColor: const Color(
        0xFF2563EB,
      ).withValues(alpha: isSelected ? 0.2 : 0.1),
      strokeColor: Colors.white,
      strokeWidth: isSelected ? 4 : 2,
      consumeTapEvents: true,
      onTap: () => onNewsSelected(item),
    );
  }

  Circle _publicationCircle(MapPublicationMarkerEntity item) {
    final isSelected = selectedPublication?.publicationId == item.publicationId;
    return Circle(
      circleId: CircleId('publication_circle_${item.publicationId}'),
      center: item.position,
      radius: isSelected ? 620 : 380,
      fillColor: item.category.option.color.withValues(
        alpha: isSelected ? 0.2 : 0.1,
      ),
      strokeColor: Colors.white,
      strokeWidth: isSelected ? 4 : 2,
      consumeTapEvents: true,
      onTap: () => onPublicationSelected(item),
    );
  }

  double _postHue(PostType category) {
    return switch (category.option.color) {
      const Color(0xFFE53935) => BitmapDescriptor.hueRed,
      const Color(0xFFFFA000) => BitmapDescriptor.hueYellow,
      const Color(0xFF0B8063) => BitmapDescriptor.hueGreen,
      const Color(0xFF7B61FF) => BitmapDescriptor.hueViolet,
      const Color(0xFF607D8B) => BitmapDescriptor.hueAzure,
      _ => BitmapDescriptor.hueBlue,
    };
  }
}
