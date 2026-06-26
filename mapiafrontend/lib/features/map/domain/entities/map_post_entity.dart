import 'package:flutter/material.dart';

enum MapPostCategory {
  foodDeal,
  event,
  news,
  traffic,
  blockade,
  accident,
  serviceCut,
  security,
  sale,
  lostFound,
  other,
}

class MapPostEntity {
  const MapPostEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.locationName,
    required this.timeAgo,
    required this.category,
    required this.status,
    required this.trustScore,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.mapX,
    required this.mapY,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final String author;
  final String locationName;
  final String timeAgo;
  final MapPostCategory category;
  final String status;
  final int trustScore;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final double mapX;
  final double mapY;
  final String? imageUrl;
}

extension MapPostCategoryStyle on MapPostCategory {
  String get label {
    return switch (this) {
      MapPostCategory.foodDeal => 'Comida barata',
      MapPostCategory.event => 'Evento',
      MapPostCategory.news => 'Novedad',
      MapPostCategory.traffic => 'Tráfico',
      MapPostCategory.blockade => 'Bloqueo',
      MapPostCategory.accident => 'Accidente',
      MapPostCategory.serviceCut => 'Corte de servicio',
      MapPostCategory.security => 'Seguridad',
      MapPostCategory.sale => 'Venta',
      MapPostCategory.lostFound => 'Perdido/encontrado',
      MapPostCategory.other => 'Otro',
    };
  }

  IconData get icon {
    return switch (this) {
      MapPostCategory.foodDeal => Icons.restaurant_rounded,
      MapPostCategory.event => Icons.celebration_rounded,
      MapPostCategory.news => Icons.campaign_rounded,
      MapPostCategory.traffic => Icons.traffic_rounded,
      MapPostCategory.blockade => Icons.block_rounded,
      MapPostCategory.accident => Icons.car_crash_rounded,
      MapPostCategory.serviceCut => Icons.power_settings_new_rounded,
      MapPostCategory.security => Icons.shield_outlined,
      MapPostCategory.sale => Icons.sell_rounded,
      MapPostCategory.lostFound => Icons.manage_search_rounded,
      MapPostCategory.other => Icons.place_rounded,
    };
  }

  Color get color {
    return switch (this) {
      MapPostCategory.foodDeal => const Color(0xFF0B8063),
      MapPostCategory.event => const Color(0xFF7B61FF),
      MapPostCategory.news => const Color(0xFF1A73E8),
      MapPostCategory.traffic => const Color(0xFFFFA000),
      MapPostCategory.blockade => const Color(0xFFE53935),
      MapPostCategory.accident => const Color(0xFFE53935),
      MapPostCategory.serviceCut => const Color(0xFF7B61FF),
      MapPostCategory.security => const Color(0xFF0B8063),
      MapPostCategory.sale => const Color(0xFFFFA000),
      MapPostCategory.lostFound => const Color(0xFF1A73E8),
      MapPostCategory.other => const Color(0xFF607D8B),
    };
  }
}
