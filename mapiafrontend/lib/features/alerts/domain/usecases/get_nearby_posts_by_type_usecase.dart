import 'package:mapiafrontend/features/alerts/domain/repositories/alerts_repository.dart';
import 'package:mapiafrontend/features/location/domain/entities/location_entity.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class GetNearbyPostsByTypeUsecase {
  const GetNearbyPostsByTypeUsecase(this.repository);

  final AlertsRepository repository;

  Future<List<PostEntity>> call({
    required PostType type,
    required AppLocationEntity location,
    required double radiusKm,
  }) {
    return repository.getNearbyPostsByType(
      type: type,
      location: location,
      radiusKm: radiusKm,
    );
  }
}
