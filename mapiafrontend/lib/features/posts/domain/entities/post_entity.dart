import 'package:flutter/material.dart';

enum PostType {
  news,
  novelty,
  party,
  foodDeal,
  sale,
  traffic,
  blockade,
  accident,
  serviceCut,
  security,
  lostFound,
  other,
}

enum PostMediaType { image, video, none }

enum PostReaction { like, dislike, none }

class PostEntity {
  const PostEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.authorName,
    required this.latitude,
    required this.longitude,
    required this.likesCount,
    required this.dislikesCount,
    required this.commentsCount,
    required this.reportsCount,
    required this.isLiked,
    required this.userReaction,
    required this.isVerified,
    required this.createdAt,
    this.authorAvatarUrl,
    this.authorReputation,
    this.address,
    this.mediaUrl,
    this.mediaType = PostMediaType.none,
  });

  final String id;
  final String title;
  final String description;
  final PostType type;
  final String authorName;
  final String? authorAvatarUrl;
  final int? authorReputation;
  final double latitude;
  final double longitude;
  final String? address;
  final String? mediaUrl;
  final PostMediaType mediaType;
  final int likesCount;
  final int dislikesCount;
  final int commentsCount;
  final int reportsCount;
  final bool isLiked;
  final PostReaction userReaction;
  final bool isVerified;
  final DateTime createdAt;

  PostEntity copyWith({
    int? likesCount,
    int? dislikesCount,
    int? commentsCount,
    int? reportsCount,
    bool? isLiked,
    PostReaction? userReaction,
  }) {
    return PostEntity(
      id: id,
      title: title,
      description: description,
      type: type,
      authorName: authorName,
      latitude: latitude,
      longitude: longitude,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      reportsCount: reportsCount ?? this.reportsCount,
      isLiked: isLiked ?? this.isLiked,
      userReaction: userReaction ?? this.userReaction,
      isVerified: isVerified,
      createdAt: createdAt,
      authorAvatarUrl: authorAvatarUrl,
      authorReputation: authorReputation,
      address: address,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
    );
  }
}

class PostTypeOption {
  const PostTypeOption({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.description,
  });

  final PostType type;
  final String label;
  final IconData icon;
  final Color color;
  final String description;
}

extension PostTypeDetails on PostType {
  PostTypeOption get option {
    return switch (this) {
      PostType.news => const PostTypeOption(
        type: PostType.news,
        label: 'Noticia',
        icon: Icons.campaign_rounded,
        color: Color(0xFF1A73E8),
        description: 'Algo importante para el barrio',
      ),
      PostType.novelty => const PostTypeOption(
        type: PostType.novelty,
        label: 'Novedad',
        icon: Icons.auto_awesome_rounded,
        color: Color(0xFF1A73E8),
        description: 'Algo curioso o útil que pasa cerca',
      ),
      PostType.party => const PostTypeOption(
        type: PostType.party,
        label: 'Fiesta / evento',
        icon: Icons.celebration_rounded,
        color: Color(0xFF7B61FF),
        description: 'Actividades, ferias o encuentros',
      ),
      PostType.foodDeal => const PostTypeOption(
        type: PostType.foodDeal,
        label: 'Comida barata',
        icon: Icons.restaurant_rounded,
        color: Color(0xFF0B8063),
        description: 'Promos, almuerzos y antojos',
      ),
      PostType.sale => const PostTypeOption(
        type: PostType.sale,
        label: 'Venta',
        icon: Icons.sell_rounded,
        color: Color(0xFFFFA000),
        description: 'Productos o ventas temporales',
      ),
      PostType.traffic => const PostTypeOption(
        type: PostType.traffic,
        label: 'Tráfico',
        icon: Icons.traffic_rounded,
        color: Color(0xFFFFA000),
        description: 'Rutas lentas o congestionadas',
      ),
      PostType.blockade => const PostTypeOption(
        type: PostType.blockade,
        label: 'Bloqueo',
        icon: Icons.block_rounded,
        color: Color(0xFFE53935),
        description: 'Calles o rutas cerradas',
      ),
      PostType.accident => const PostTypeOption(
        type: PostType.accident,
        label: 'Accidente',
        icon: Icons.car_crash_rounded,
        color: Color(0xFFE53935),
        description: 'Choques o incidentes viales',
      ),
      PostType.serviceCut => const PostTypeOption(
        type: PostType.serviceCut,
        label: 'Corte de servicio',
        icon: Icons.power_settings_new_rounded,
        color: Color(0xFF7B61FF),
        description: 'Agua, luz, internet u otros',
      ),
      PostType.security => const PostTypeOption(
        type: PostType.security,
        label: 'Seguridad',
        icon: Icons.shield_outlined,
        color: Color(0xFF0B8063),
        description: 'Zonas de cuidado o apoyo',
      ),
      PostType.lostFound => const PostTypeOption(
        type: PostType.lostFound,
        label: 'Perdido / encontrado',
        icon: Icons.manage_search_rounded,
        color: Color(0xFF1A73E8),
        description: 'Mascotas, documentos u objetos',
      ),
      PostType.other => const PostTypeOption(
        type: PostType.other,
        label: 'Otro',
        icon: Icons.place_rounded,
        color: Color(0xFF607D8B),
        description: 'Algo que no encaja arriba',
      ),
    };
  }
}
