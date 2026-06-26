import 'package:mapiafrontend/features/alerts/domain/entities/nearby_alert_group_entity.dart';
import 'package:mapiafrontend/features/location/domain/entities/location_entity.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

abstract class AlertsRepository {
  Future<List<NearbyAlertGroupEntity>> getNearbyAlertGroups({
    required AppLocationEntity location,
    required double radiusKm,
  });

  Future<List<PostEntity>> getNearbyPostsByType({
    required PostType type,
    required AppLocationEntity location,
    required double radiusKm,
  });
}
