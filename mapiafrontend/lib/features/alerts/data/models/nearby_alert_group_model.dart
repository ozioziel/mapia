import 'package:mapiafrontend/features/alerts/domain/entities/nearby_alert_group_entity.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class NearbyAlertGroupModel extends NearbyAlertGroupEntity {
  const NearbyAlertGroupModel({
    required super.type,
    required super.title,
    required super.description,
    required super.count,
    required super.radiusKm,
  });

  factory NearbyAlertGroupModel.fromPosts({
    required PostType type,
    required int count,
    required double radiusKm,
  }) {
    return NearbyAlertGroupModel(
      type: type,
      title: _titleFor(type),
      description: _descriptionFor(type, count),
      count: count,
      radiusKm: radiusKm,
    );
  }

  static String _titleFor(PostType type) {
    return switch (type) {
      PostType.news => 'Noticias',
      PostType.novelty => 'Novedades',
      PostType.party => 'Fiestas / eventos',
      PostType.foodDeal => 'Comida barata',
      PostType.sale => 'Ventas',
      PostType.traffic => 'Trafico',
      PostType.blockade => 'Bloqueos',
      PostType.accident => 'Accidentes',
      PostType.serviceCut => 'Cortes de servicio',
      PostType.security => 'Seguridad',
      PostType.lostFound => 'Perdido / encontrado',
      PostType.other => 'Otros',
    };
  }

  static String _descriptionFor(PostType type, int count) {
    final verb = count == 1 ? 'Hay 1' : 'Hay $count';
    return switch (type) {
      PostType.news => '$verb noticias cerca de tu ubicacion',
      PostType.novelty => '$verb novedades cerca de tu ubicacion',
      PostType.party => '$verb fiestas o eventos cerca de ti',
      PostType.foodDeal => '$verb comidas baratas cerca de tu ubicacion',
      PostType.sale => '$verb ventas cerca de tu ubicacion',
      PostType.traffic => '$verb reportes de trafico cerca de tu ubicacion',
      PostType.blockade => '$verb bloqueos cerca de tu ubicacion',
      PostType.accident => '$verb accidentes cerca de tu ubicacion',
      PostType.serviceCut => '$verb cortes de servicio cerca de tu ubicacion',
      PostType.security => '$verb alertas de seguridad cerca de tu ubicacion',
      PostType.lostFound => '$verb perdidos o encontrados cerca de ti',
      PostType.other => '$verb otros sucesos cerca de tu ubicacion',
    };
  }
}
