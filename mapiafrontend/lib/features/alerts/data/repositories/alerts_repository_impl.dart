import 'package:mapiafrontend/core/utils/distance_utils.dart';
import 'package:mapiafrontend/features/alerts/data/models/nearby_alert_group_model.dart';
import 'package:mapiafrontend/features/alerts/domain/entities/nearby_alert_group_entity.dart';
import 'package:mapiafrontend/features/alerts/domain/repositories/alerts_repository.dart';
import 'package:mapiafrontend/features/location/domain/entities/location_entity.dart';
import 'package:mapiafrontend/features/posts/data/services/posts_api.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  AlertsRepositoryImpl({PostsApi? postsApi})
    : postsApi = postsApi ?? PostsApi();

  final PostsApi postsApi;

  @override
  Future<List<NearbyAlertGroupEntity>> getNearbyAlertGroups({
    required AppLocationEntity location,
    required double radiusKm,
  }) async {
    final posts = await _nearbyPosts(location: location, radiusKm: radiusKm);
    final groups = <NearbyAlertGroupEntity>[];

    for (final type in PostType.values) {
      final count = posts.where((post) => post.type == type).length;
      if (count == 0) continue;
      groups.add(
        NearbyAlertGroupModel.fromPosts(
          type: type,
          count: count,
          radiusKm: radiusKm,
        ),
      );
    }

    return groups;
  }

  @override
  Future<List<PostEntity>> getNearbyPostsByType({
    required PostType type,
    required AppLocationEntity location,
    required double radiusKm,
  }) async {
    final posts = await _nearbyPosts(location: location, radiusKm: radiusKm);
    return posts.where((post) => post.type == type).toList();
  }

  Future<List<PostEntity>> _nearbyPosts({
    required AppLocationEntity location,
    required double radiusKm,
  }) async {
    final posts = await postsApi.fetchPosts(limit: 200);
    return posts.where((post) {
      final distance = calculateDistanceKm(
        lat1: location.latitude,
        lon1: location.longitude,
        lat2: post.latitude,
        lon2: post.longitude,
      );
      return distance <= radiusKm;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
