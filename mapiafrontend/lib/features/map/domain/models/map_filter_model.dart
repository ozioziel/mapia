import 'package:flutter/material.dart';

enum MapFilterCategory {
  touristAttractions,
  restaurants,
  importantPlaces,
  news,
  userPosts,
  routes,
  citizenReports,
}

extension MapFilterCategoryUi on MapFilterCategory {
  String get label => switch (this) {
    MapFilterCategory.touristAttractions => 'Atractivos',
    MapFilterCategory.restaurants => 'Restaurantes',
    MapFilterCategory.importantPlaces => 'Lugares',
    MapFilterCategory.news => 'Noticias',
    MapFilterCategory.userPosts => 'Publicaciones',
    MapFilterCategory.routes => 'Rutas',
    MapFilterCategory.citizenReports => 'Alertas',
  };

  IconData get icon => switch (this) {
    MapFilterCategory.touristAttractions => Icons.travel_explore_rounded,
    MapFilterCategory.restaurants => Icons.restaurant_rounded,
    MapFilterCategory.importantPlaces => Icons.flag_rounded,
    MapFilterCategory.news => Icons.campaign_rounded,
    MapFilterCategory.userPosts => Icons.forum_rounded,
    MapFilterCategory.routes => Icons.alt_route_rounded,
    MapFilterCategory.citizenReports => Icons.report_problem_rounded,
  };
}

class MapLayerFilters {
  const MapLayerFilters({this.activeCategories = const {}});

  final Set<MapFilterCategory> activeCategories;

  bool get isEmpty => activeCategories.isEmpty;

  int get activeCount => activeCategories.length;

  bool allows(MapFilterCategory category) {
    return activeCategories.isEmpty || activeCategories.contains(category);
  }

  MapLayerFilters toggled(MapFilterCategory category) {
    final next = {...activeCategories};
    if (!next.add(category)) {
      next.remove(category);
    }
    return MapLayerFilters(activeCategories: next);
  }

  MapLayerFilters clear() => const MapLayerFilters();
}
