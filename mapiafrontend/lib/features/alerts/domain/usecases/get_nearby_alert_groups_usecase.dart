import 'package:mapiafrontend/features/alerts/domain/entities/nearby_alert_group_entity.dart';
import 'package:mapiafrontend/features/alerts/domain/repositories/alerts_repository.dart';
import 'package:mapiafrontend/features/location/domain/entities/location_entity.dart';

class GetNearbyAlertGroupsUsecase {
  const GetNearbyAlertGroupsUsecase(this.repository);

  final AlertsRepository repository;

  Future<List<NearbyAlertGroupEntity>> call({
    required AppLocationEntity location,
    required double radiusKm,
  }) {
    return repository.getNearbyAlertGroups(
      location: location,
      radiusKm: radiusKm,
    );
  }
}
