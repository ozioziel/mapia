import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class NearbyAlertGroupEntity {
  const NearbyAlertGroupEntity({
    required this.type,
    required this.title,
    required this.description,
    required this.count,
    required this.radiusKm,
  });

  final PostType type;
  final String title;
  final String description;
  final int count;
  final double radiusKm;
}
