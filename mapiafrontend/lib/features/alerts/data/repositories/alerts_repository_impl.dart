import 'package:mapiafrontend/features/alerts/data/datasources/alerts_remote_datasource.dart';
import 'package:mapiafrontend/features/alerts/domain/entities/nearby_alert_group_entity.dart';
import 'package:mapiafrontend/features/alerts/domain/repositories/alerts_repository.dart';
import 'package:mapiafrontend/features/location/domain/entities/location_entity.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  const AlertsRepositoryImpl(this.datasource);

  final AlertsRemoteDatasource datasource;

  @override
  Future<List<NearbyAlertGroupEntity>> getNearbyAlertGroups({
    required AppLocationEntity location,
    required double radiusKm,
  }) {
    return datasource.getNearbyAlertGroups(
      location: location,
      radiusKm: radiusKm,
    );
  }

  @override
  Future<List<PostEntity>> getNearbyPostsByType({
    required PostType type,
    required AppLocationEntity location,
    required double radiusKm,
  }) {
    return datasource.getNearbyPostsByType(
      type: type,
      location: location,
      radiusKm: radiusKm,
    );
  }
}
